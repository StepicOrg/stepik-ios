import Foundation
import Logging
import PromiseKit

protocol NewDiscussionsInteractorProtocol {
    func doDiscussionsLoad(request: NewDiscussions.DiscussionsLoad.Request)
    func doNextDiscussionsLoad(request: NewDiscussions.NextDiscussionsLoad.Request)
    func doNextRepliesLoad(request: NewDiscussions.NextRepliesLoad.Request)
    func doWriteCommentPresentation(request: NewDiscussions.WriteCommentPresentation.Request )
    func doCommentDelete(request: NewDiscussions.CommentDelete.Request)
    func doSortTypePresentation(request: NewDiscussions.SortTypePresentation.Request)
    func doSortTypeUpdate(request: NewDiscussions.SortTypeUpdate.Request)
}

final class NewDiscussionsInteractor: NewDiscussionsInteractorProtocol {
    private static let logger = Logger(label: "com.AlexKarpov.Stepic.NewDiscussionsInteractor")

    private static let discussionsLoadingInterval = 20
    private static let repliesLoadingInterval = 20

    private let presenter: NewDiscussionsPresenterProtocol
    private let provider: NewDiscussionsProviderProtocol

    private let discussionProxyID: DiscussionProxy.IdType
    private let stepID: Step.IdType

    private var currentDiscussionProxy: DiscussionProxy?
    private var currentDiscussions: [Comment] = [] {
        didSet {
            assert(!self.currentDiscussions.contains(where: { $0.parentID != nil }), "Root discussions hasn't parents")
        }
    }
    private var currentReplies: [Comment.IdType: [Comment]] = [:]
    private var currentDiscussionsIDs: [Comment.IdType] {
        guard let discussionProxy = self.currentDiscussionProxy else {
            return []
        }

        switch self.currentSortType {
        case .last:
            return discussionProxy.discussionsIDs
        case .mostLiked:
            return discussionProxy.discussionsIDsMostLiked
        case .mostActive:
            return discussionProxy.discussionsIDsMostActive
        case .recentActivity:
            return discussionProxy.discussionsIDsRecentActivity
        }
    }
    private var currentSortType: NewDiscussions.SortType = .default

    /// A Boolean value that determines whether the fetch of the replies for root discussion is in progress.
    private var discussionsIDsFetchingReplies: Set<Comment.IdType> = []

    // Semaphore to prevent concurrent fetching
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.NewDiscussionsInteractor.DiscussionsFetch"
    )

    init(
        discussionProxyID: DiscussionProxy.IdType,
        stepID: Step.IdType,
        presenter: NewDiscussionsPresenterProtocol,
        provider: NewDiscussionsProviderProtocol
    ) {
        self.discussionProxyID = discussionProxyID
        self.stepID = stepID
        self.presenter = presenter
        self.provider = provider
    }

    // MARK: - NewDiscussionsInteractorProtocol -

    func doDiscussionsLoad(request: NewDiscussions.DiscussionsLoad.Request) {
        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()
            NewDiscussionsInteractor.logger.info("new discussions interactor: start fetching discussions")

            strongSelf.fetchDiscussions(discussionProxyID: strongSelf.discussionProxyID).done { discussionsData in
                DispatchQueue.main.async {
                    NewDiscussionsInteractor.logger.info("new discussions interactor: finish fetching discussions")
                    strongSelf.presenter.presentDiscussions(
                        response: NewDiscussions.DiscussionsLoad.Response(result: .success(discussionsData))
                    )
                }
            }.catch { _ in
                DispatchQueue.main.async {
                    strongSelf.presenter.presentDiscussions(
                        response: NewDiscussions.DiscussionsLoad.Response(result: .failure(Error.fetchFailed))
                    )
                }
            }.finally {
                strongSelf.fetchSemaphore.signal()
            }
        }
    }

    func doNextDiscussionsLoad(request: NewDiscussions.NextDiscussionsLoad.Request) {
        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            let idsToLoad = strongSelf.getNextDiscussionsIDsToLoad()
            NewDiscussionsInteractor.logger.info(
                "new discussions interactor: start fetching next discussions",
                metadata: ["ids": .string("\(idsToLoad)")]
            )

            strongSelf.provider.fetchComments(ids: idsToLoad).done { fetchedComments in
                strongSelf.updateDataWithNewComments(fetchedComments)
                DispatchQueue.main.async {
                    NewDiscussionsInteractor.logger.info("new discussions interactor: finish fetching next discussions")
                    strongSelf.presenter.presentNextDiscussions(
                        response: NewDiscussions.NextDiscussionsLoad.Response(
                            result: .success(strongSelf.makeDiscussionsData())
                        )
                    )
                }
            }.catch { error in
                NewDiscussionsInteractor.logger.error(
                    "new discussions interactor: failed fetching next discussions, error: \(error)"
                )
                DispatchQueue.main.async {
                    strongSelf.presenter.presentNextDiscussions(
                        response: NewDiscussions.NextDiscussionsLoad.Response(result: .failure(Error.fetchFailed))
                    )
                }
            }.finally {
                strongSelf.fetchSemaphore.signal()
            }
        }
    }

    func doNextRepliesLoad(request: NewDiscussions.NextRepliesLoad.Request) {
        guard let discussion = self.currentDiscussions.first(where: { $0.id == request.discussionID }),
              !self.discussionsIDsFetchingReplies.contains(discussion.id) else {
            return
        }

        self.discussionsIDsFetchingReplies.insert(request.discussionID)
        self.presenter.presentNextReplies(
            response: NewDiscussions.NextRepliesLoad.Response(result: self.makeDiscussionsData())
        )

        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            let idsToLoad = strongSelf.getNextReplyIDsToLoad(discussion: discussion)
            NewDiscussionsInteractor.logger.info(
                "new discussions interactor: start fetching next replies",
                metadata: ["ids": .string("\(idsToLoad)")]
            )

            strongSelf.provider.fetchComments(ids: idsToLoad).done { fetchedComments in
                strongSelf.updateDataWithNewComments(fetchedComments)
                strongSelf.discussionsIDsFetchingReplies.remove(discussion.id)
                DispatchQueue.main.async {
                    NewDiscussionsInteractor.logger.info("new discussions interactor: finish fetching next replies")
                    strongSelf.presenter.presentNextReplies(
                        response: NewDiscussions.NextRepliesLoad.Response(result: strongSelf.makeDiscussionsData())
                    )
                }
            }.catch { error in
                NewDiscussionsInteractor.logger.error(
                    "new discussions interactor: failed fetching next replies, error: \(error)"
                )
                strongSelf.discussionsIDsFetchingReplies.remove(discussion.id)
                DispatchQueue.main.async {
                    strongSelf.presenter.presentNextReplies(
                        response: NewDiscussions.NextRepliesLoad.Response(result: strongSelf.makeDiscussionsData())
                    )
                }
            }.finally {
                strongSelf.fetchSemaphore.signal()
            }
        }
    }

    func doWriteCommentPresentation(request: NewDiscussions.WriteCommentPresentation.Request) {
        switch request.presentationContext {
        case .create:
            self.presentWriteComment(commentID: request.commentID)
        case .edit:
            if let commentID = request.commentID {
                self.presentEditComment(commentID: commentID)
            } else {
                NewDiscussionsInteractor.logger.error(
                    "new discussions interactor: attempt to edit comment but comment id is nil"
                )
            }
        }
    }

    func doCommentDelete(request: NewDiscussions.CommentDelete.Request) {
        NewDiscussionsInteractor.logger.info(
            "new discussions interactor: start deleting comment by id: \(request.commentID)"
        )
        self.presenter.presentWaitingState(
            response: NewDiscussions.BlockingWaitingIndicatorUpdate.Response(shouldDismiss: false)
        )

        let commentID = request.commentID

        self.provider.deleteComment(id: commentID).done {
            NewDiscussionsInteractor.logger.info(
                "new discussions interactor: successfully deleted comment with id: \(commentID)"
            )

            if let discussionIndex = self.currentDiscussions.firstIndex(where: { $0.id == commentID }) {
                self.currentDiscussions.remove(at: discussionIndex)
                self.currentReplies[commentID] = nil
            } else {
                for (discussionID, replies) in self.currentReplies {
                    guard let replyIndex = replies.firstIndex(where: { $0.id == commentID }) else {
                        continue
                    }

                    self.currentReplies[discussionID]?.remove(at: replyIndex)
                    if let discussionIndex = self.currentDiscussions.firstIndex(where: { $0.id == discussionID }) {
                        self.currentDiscussions[discussionIndex].repliesIDs.removeAll(where: { $0 == commentID })
                    }
                    break
                }
            }

            self.provider.fetchDiscussionProxy(id: self.discussionProxyID).done { discussionProxy in
                self.currentDiscussionProxy = discussionProxy
            }.ensure {
                self.presenter.presentCommentDeleteResult(
                    response: NewDiscussions.CommentDelete.Response(result: .success(self.makeDiscussionsData()))
                )
            }.cauterize()
        }.catch { error in
            NewDiscussionsInteractor.logger.info(
                "new discussions interactor: failed delete comment with id: \(commentID)"
            )
            self.presenter.presentCommentDeleteResult(
                response: NewDiscussions.CommentDelete.Response(result: .failure(error))
            )
        }
    }

    func doSortTypePresentation(request: NewDiscussions.SortTypePresentation.Request) {
        self.presenter.presentSortType(
            response: NewDiscussions.SortTypePresentation.Response(
                currentSortType: self.currentSortType,
                availableSortTypes: NewDiscussions.SortType.allCases
            )
        )
    }

    func doSortTypeUpdate(request: NewDiscussions.SortTypeUpdate.Request) {
        guard let selectedSortType = NewDiscussions.SortType(rawValue: request.uniqueIdentifier),
              self.currentSortType != selectedSortType else {
            return
        }

        self.currentSortType = selectedSortType
        self.presenter.presentSortTypeUpdate(
            response: NewDiscussions.SortTypeUpdate.Response(result: self.makeDiscussionsData())
        )
    }

    // MARK: - Private API

    private func fetchDiscussions(
        discussionProxyID: DiscussionProxy.IdType
    ) -> Promise<NewDiscussions.DiscussionsResponseData> {
        // Reset data
        self.currentDiscussions = []
        self.currentReplies = [:]

        return Promise { seal in
            firstly {
                self.provider.fetchDiscussionProxy(id: discussionProxyID)
            }.then { discussionProxy -> Promise<[Comment.IdType]> in
                self.currentDiscussionProxy = discussionProxy
                return .value(self.getNextDiscussionsIDsToLoad())
            }.then { ids -> Promise<[Comment]> in
                self.provider.fetchComments(ids: ids)
            }.done { fetchedComments in
                self.updateDataWithNewComments(fetchedComments)
                seal.fulfill(self.makeDiscussionsData())
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    private func updateDataWithNewComments(_ comments: [Comment]) {
        self.currentDiscussions.append(contentsOf: comments.filter({ $0.parentID == nil }))
        self.currentDiscussions = self.currentDiscussions.reordered(
            order: self.currentDiscussionsIDs,
            transform: { $0.id }
        )

        for comment in comments {
            guard let parentID = comment.parentID,
                  let parentDiscussion = self.currentDiscussions.first(where: { $0.id == parentID }) else {
                continue
            }

            self.currentReplies[parentID, default: []].append(comment)
            self.currentReplies[parentID] = self.currentReplies[parentID, default: []].reordered(
                order: parentDiscussion.repliesIDs,
                transform: { $0.id }
            )
        }
    }

    private func makeDiscussionsData() -> NewDiscussions.DiscussionsResponseData {
        return NewDiscussions.DiscussionsResponseData(
            discussionProxy: self.currentDiscussionProxy.require(),
            discussions: self.currentDiscussions,
            discussionsIDsFetchingMore: self.discussionsIDsFetchingReplies,
            replies: self.currentReplies,
            currentSortType: self.currentSortType
        )
    }

    private func getNextDiscussionsIDsToLoad() -> [Comment.IdType] {
        assert(self.currentDiscussionProxy != nil, "discussion proxy must exists, unexpected behavior")

        let discussionsLeftToLoad = self.currentDiscussionsIDs.count - self.currentDiscussions.count

        let startIndex = self.currentDiscussions.count
        let offset = min(discussionsLeftToLoad, NewDiscussionsInteractor.discussionsLoadingInterval)

        return Array(self.currentDiscussionsIDs[startIndex..<startIndex + offset])
    }

    private func getNextReplyIDsToLoad(discussion: Comment) -> [Comment.IdType] {
        let loadedRepliesIDs = Set(self.currentReplies[discussion.id, default: []].map { $0.id })
        var idsToLoad = [Comment.IdType]()

        for replyID in discussion.repliesIDs {
            if !loadedRepliesIDs.contains(replyID) {
                idsToLoad.append(replyID)
                if idsToLoad.count == NewDiscussionsInteractor.repliesLoadingInterval {
                    return idsToLoad
                }
            }
        }

        return idsToLoad
    }

    private func presentWriteComment(commentID: Comment.IdType?) {
        var parentID: Comment.IdType?

        if let commentID = commentID {
            parentID = {
                if self.currentDiscussions.contains(where: { $0.id == commentID }) {
                    return commentID
                }
                for (discussionID, replies) in self.currentReplies {
                    if discussionID == commentID {
                        return discussionID
                    }
                    if replies.contains(where: { $0.id == commentID }) {
                        return discussionID
                    }
                }
                return nil
            }()
        }

        self.presenter.presentWriteComment(
            response: NewDiscussions.WriteCommentPresentation.Response(
                targetID: self.stepID,
                parentID: parentID,
                comment: nil,
                presentationContext: .create
            )
        )
    }

    private func presentEditComment(commentID: Comment.IdType) {
        let comment: Comment? = {
            if let discussion = self.currentDiscussions.first(where: { $0.id == commentID }) {
                return discussion
            }
            for (_, replies) in self.currentReplies {
                if let reply = replies.first(where: { $0.id == commentID }) {
                    return reply
                }
            }
            return nil
        }()

        guard let unwrappedComment = comment else {
            return NewDiscussionsInteractor.logger.error(
                "new discussions interactor: attempt to edit comment but not able to find it by id"
            )
        }

        self.presenter.presentWriteComment(
            response: NewDiscussions.WriteCommentPresentation.Response(
                targetID: self.stepID,
                parentID: unwrappedComment.parentID,
                comment: unwrappedComment,
                presentationContext: .edit
            )
        )
    }

    // MARK: - Types -

    enum Error: Swift.Error {
        case fetchFailed
    }
}

// MARK: - NewDiscussionsInteractor: WriteCommentOutputProtocol -

extension NewDiscussionsInteractor: WriteCommentOutputProtocol {
    func handleCommentCreated(_ comment: Comment) {
        if let parentID = comment.parentID,
            let parentIndex = self.currentDiscussions.firstIndex(where: { $0.id == parentID }) {
            self.currentDiscussions[parentIndex].repliesIDs.append(comment.id)
            self.currentReplies[parentID, default: []].append(comment)

            self.presenter.presentCommentCreated(
                response: NewDiscussions.CommentCreated.Response(result: self.makeDiscussionsData())
            )
        } else {
            self.presenter.presentWaitingState(
                response: NewDiscussions.BlockingWaitingIndicatorUpdate.Response(shouldDismiss: false)
            )

            self.currentDiscussions.append(comment)

            self.provider.fetchDiscussionProxy(id: self.discussionProxyID).done { discussionProxy in
                self.currentDiscussionProxy = discussionProxy
            }.ensure {
                self.presenter.presentWaitingState(
                    response: NewDiscussions.BlockingWaitingIndicatorUpdate.Response(shouldDismiss: true)
                )
                self.presenter.presentCommentCreated(
                    response: NewDiscussions.CommentCreated.Response(result: self.makeDiscussionsData())
                )
            }.cauterize()
        }
    }

    func handleCommentUpdated(_ comment: Comment) {
        if let discussionIndex = self.currentDiscussions.firstIndex(where: { $0.id == comment.id }) {
            self.currentDiscussions[discussionIndex] = comment
        } else {
            for (discussionID, replies) in self.currentReplies {
                guard let replyIndex = replies.firstIndex(where: { $0.id == comment.id }) else {
                    continue
                }

                self.currentReplies[discussionID]?[replyIndex] = comment
                break
            }
        }

        self.presenter.presentCommentUpdated(
            response: NewDiscussions.CommentUpdated.Response(result: self.makeDiscussionsData())
        )
    }
}
