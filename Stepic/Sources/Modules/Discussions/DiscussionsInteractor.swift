import Foundation
import Logging
import PromiseKit

// swiftlint:disable file_length
protocol DiscussionsInteractorProtocol {
    func doDiscussionsLoad(request: Discussions.DiscussionsLoad.Request)
    func doNextDiscussionsLoad(request: Discussions.NextDiscussionsLoad.Request)
    func doNextRepliesLoad(request: Discussions.NextRepliesLoad.Request)
    func doWriteCommentPresentation(request: Discussions.WriteCommentPresentation.Request )
    func doCommentDelete(request: Discussions.CommentDelete.Request)
    func doCommentLike(request: Discussions.CommentLike.Request)
    func doCommentAbuse(request: Discussions.CommentAbuse.Request)
    func doSortTypePresentation(request: Discussions.SortTypePresentation.Request)
    func doSortTypeUpdate(request: Discussions.SortTypeUpdate.Request)
}

final class DiscussionsInteractor: DiscussionsInteractorProtocol {
    private static let logger = Logger(label: "com.AlexKarpov.Stepic.DiscussionsInteractor")

    private static let discussionsLoadingInterval = 20
    private static let repliesLoadingInterval = 20

    private let presenter: DiscussionsPresenterProtocol
    private let provider: DiscussionsProviderProtocol

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

    /// A Boolean value that determines whether the fetch of the replies for root discussion is in progress.
    private var discussionsIDsFetchingReplies: Set<Comment.IdType> = []

    // Semaphore to prevent concurrent fetching
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.DiscussionsInteractor.DiscussionsFetch"
    )

    init(
        discussionProxyID: DiscussionProxy.IdType,
        stepID: Step.IdType,
        presenter: DiscussionsPresenterProtocol,
        provider: DiscussionsProviderProtocol
    ) {
        self.discussionProxyID = discussionProxyID
        self.stepID = stepID
        self.presenter = presenter
        self.provider = provider

        // FIXME: analytics dependency
        AmplitudeAnalyticsEvents.Discussions.opened.send()
    }

    // MARK: - DiscussionsInteractorProtocol -

    // MARK: Fetching

    func doDiscussionsLoad(request: Discussions.DiscussionsLoad.Request) {
        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()
            DiscussionsInteractor.logger.info("discussions interactor: start fetching discussions")

            strongSelf.fetchDiscussions(discussionProxyID: strongSelf.discussionProxyID).done { discussionsData in
                DispatchQueue.main.async {
                    DiscussionsInteractor.logger.info("discussions interactor: finish fetching discussions")
                    strongSelf.presenter.presentDiscussions(
                        response: Discussions.DiscussionsLoad.Response(result: .success(discussionsData))
                    )
                }
            }.catch { _ in
                DispatchQueue.main.async {
                    strongSelf.presenter.presentDiscussions(
                        response: Discussions.DiscussionsLoad.Response(result: .failure(Error.fetchFailed))
                    )
                }
            }.finally {
                strongSelf.fetchSemaphore.signal()
            }
        }
    }

    func doNextDiscussionsLoad(request: Discussions.NextDiscussionsLoad.Request) {
        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            let idsToLoad = strongSelf.getNextDiscussionsIDsToLoad()
            DiscussionsInteractor.logger.info(
                "discussions interactor: start fetching next discussions",
                metadata: ["ids": .string("\(idsToLoad)")]
            )

            strongSelf.provider.fetchComments(ids: idsToLoad).done { fetchedComments in
                strongSelf.updateDataWithNewComments(fetchedComments)
                DispatchQueue.main.async {
                    DiscussionsInteractor.logger.info("discussions interactor: finish fetching next discussions")
                    strongSelf.presenter.presentNextDiscussions(
                        response: Discussions.NextDiscussionsLoad.Response(
                            result: .success(strongSelf.makeDiscussionsData())
                        )
                    )
                }
            }.catch { error in
                DiscussionsInteractor.logger.error(
                    "discussions interactor: failed fetching next discussions, error: \(error)"
                )
                DispatchQueue.main.async {
                    strongSelf.presenter.presentNextDiscussions(
                        response: Discussions.NextDiscussionsLoad.Response(result: .failure(Error.fetchFailed))
                    )
                }
            }.finally {
                strongSelf.fetchSemaphore.signal()
            }
        }
    }

    func doNextRepliesLoad(request: Discussions.NextRepliesLoad.Request) {
        guard let discussion = self.currentDiscussions.first(where: { $0.id == request.discussionID }),
              !self.discussionsIDsFetchingReplies.contains(discussion.id) else {
            return
        }

        self.discussionsIDsFetchingReplies.insert(request.discussionID)
        self.presenter.presentNextReplies(
            response: Discussions.NextRepliesLoad.Response(result: self.makeDiscussionsData())
        )

        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            let idsToLoad = strongSelf.getNextReplyIDsToLoad(discussion: discussion)
            DiscussionsInteractor.logger.info(
                "discussions interactor: start fetching next replies",
                metadata: ["ids": .string("\(idsToLoad)")]
            )

            strongSelf.provider.fetchComments(ids: idsToLoad).done { fetchedComments in
                strongSelf.updateDataWithNewComments(fetchedComments)
                strongSelf.discussionsIDsFetchingReplies.remove(discussion.id)
                DispatchQueue.main.async {
                    DiscussionsInteractor.logger.info("discussions interactor: finish fetching next replies")
                    strongSelf.presenter.presentNextReplies(
                        response: Discussions.NextRepliesLoad.Response(result: strongSelf.makeDiscussionsData())
                    )
                }
            }.catch { error in
                DiscussionsInteractor.logger.error(
                    "discussions interactor: failed fetching next replies, error: \(error)"
                )
                strongSelf.discussionsIDsFetchingReplies.remove(discussion.id)
                DispatchQueue.main.async {
                    strongSelf.presenter.presentNextReplies(
                        response: Discussions.NextRepliesLoad.Response(result: strongSelf.makeDiscussionsData())
                    )
                }
            }.finally {
                strongSelf.fetchSemaphore.signal()
            }
        }
    }

    // MARK: Write & delete

    func doWriteCommentPresentation(request: Discussions.WriteCommentPresentation.Request) {
        switch request.presentationContext {
        case .create:
            self.presentWriteComment(commentID: request.commentID)
        case .edit:
            if let commentID = request.commentID {
                self.presentEditComment(commentID: commentID)
            } else {
                DiscussionsInteractor.logger.error(
                    "discussions interactor: attempt to edit comment but comment id is nil"
                )
            }
        }
    }

    func doCommentDelete(request: Discussions.CommentDelete.Request) {
        DiscussionsInteractor.logger.info(
            "discussions interactor: start deleting comment by id: \(request.commentID)"
        )
        self.presenter.presentWaitingState(
            response: Discussions.BlockingWaitingIndicatorUpdate.Response(shouldDismiss: false)
        )

        let commentID = request.commentID

        self.provider.deleteComment(id: commentID).done {
            DiscussionsInteractor.logger.info(
                "discussions interactor: successfully deleted comment with id: \(commentID)"
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
                    response: Discussions.CommentDelete.Response(result: .success(self.makeDiscussionsData()))
                )
            }.cauterize()
        }.catch { error in
            DiscussionsInteractor.logger.info(
                "discussions interactor: failed delete comment with id: \(commentID)"
            )
            self.presenter.presentCommentDeleteResult(
                response: Discussions.CommentDelete.Response(result: .failure(error))
            )
        }
    }

    // MARK: Like & abuse

    func doCommentLike(request: Discussions.CommentLike.Request) {
        guard let comment = self.getAllComments().first(where: { $0.id == request.commentID }) else {
            return DiscussionsInteractor.logger.error(
                "discussions interactor: unable to find comment: \(request.commentID)"
            )
        }

        if let voteValue = comment.vote.value {
            let voteValueToSet: VoteValue? = voteValue == .epic ? nil : .epic
            let vote = Vote(id: comment.vote.id, value: voteValueToSet)

            DiscussionsInteractor.logger.info(
                "discussions interactor: starting update vote from \(voteValue) to \(voteValueToSet ??? "null")"
            )

            self.provider.updateVote(vote).done { vote in
                DiscussionsInteractor.logger.info("discussions interactor: successfully updated vote")

                comment.vote = vote

                switch voteValue {
                case .abuse:
                    AnalyticsReporter.reportEvent(AnalyticsEvents.Discussion.liked)
                    comment.abuseCount -= 1
                    comment.epicCount += 1
                case .epic:
                    AnalyticsReporter.reportEvent(AnalyticsEvents.Discussion.unliked)
                    comment.epicCount -= 1
                }
            }.ensure {
                self.presenter.presentCommentLikeResult(
                    response: Discussions.CommentLike.Response(result: self.makeDiscussionsData())
                )
            }.catch { error in
                DiscussionsInteractor.logger.error(
                    "discussions interactor: failed update vote",
                    metadata: [
                        "error": .string("\(error)"),
                        "commentID": .string("\(request.commentID)"),
                        "voteID": .string("\(vote.id)")
                    ]
                )
            }
        } else {
            DiscussionsInteractor.logger.info("discussions interactor: starting update vote value to epic")

            let vote = Vote(id: comment.vote.id, value: .epic)

            self.provider.updateVote(vote).done { vote in
                DiscussionsInteractor.logger.info("discussions interactor: successfully updated vote")
                AnalyticsReporter.reportEvent(AnalyticsEvents.Discussion.liked)

                comment.vote = vote
                comment.epicCount += 1
            }.ensure {
                self.presenter.presentCommentLikeResult(
                    response: Discussions.CommentLike.Response(result: self.makeDiscussionsData())
                )
            }.catch { error in
                DiscussionsInteractor.logger.error(
                    "discussions interactor: failed update vote",
                    metadata: [
                        "error": .string("\(error)"),
                        "commentID": .string("\(request.commentID)"),
                        "voteID": .string("\(vote.id)")
                    ]
                )
            }
        }
    }

    func doCommentAbuse(request: Discussions.CommentAbuse.Request) {
        guard let comment = self.getAllComments().first(where: { $0.id == request.commentID }) else {
            return DiscussionsInteractor.logger.error(
                "discussions interactor: unable to find comment: \(request.commentID)"
            )
        }

        if let voteValue = comment.vote.value {
            let voteValueToSet: VoteValue? = voteValue == .abuse ? nil : .abuse
            let vote = Vote(id: comment.vote.id, value: voteValueToSet)

            DiscussionsInteractor.logger.info(
                "discussions interactor: starting update vote from \(voteValue) to \(voteValueToSet ??? "null")"
            )

            self.provider.updateVote(vote).done { vote in
                DiscussionsInteractor.logger.info("discussions interactor: successfully updated vote")

                comment.vote = vote

                switch voteValue {
                case .abuse:
                    AnalyticsReporter.reportEvent(AnalyticsEvents.Discussion.unabused)
                    comment.abuseCount -= 1
                case .epic:
                    AnalyticsReporter.reportEvent(AnalyticsEvents.Discussion.abused)
                    comment.epicCount -= 1
                    comment.abuseCount += 1
                }
            }.ensure {
                self.presenter.presentCommentAbuseResult(
                    response: Discussions.CommentAbuse.Response(result: self.makeDiscussionsData())
                )
            }.catch { error in
                DiscussionsInteractor.logger.error(
                    "discussions interactor: failed update vote",
                    metadata: [
                        "error": .string("\(error)"),
                        "commentID": .string("\(request.commentID)"),
                        "voteID": .string("\(vote.id)")
                    ]
                )
            }
        } else {
            DiscussionsInteractor.logger.info("discussions interactor: starting update vote value to abuse")

            let vote = Vote(id: comment.vote.id, value: .abuse)

            self.provider.updateVote(vote).done { vote in
                DiscussionsInteractor.logger.info("discussions interactor: successfully updated vote")
                AnalyticsReporter.reportEvent(AnalyticsEvents.Discussion.abused)

                comment.vote = vote
                comment.abuseCount += 1
            }.ensure {
                self.presenter.presentCommentAbuseResult(
                    response: Discussions.CommentAbuse.Response(result: self.makeDiscussionsData())
                )
            }.catch { error in
                DiscussionsInteractor.logger.error(
                    "discussions interactor: failed update vote",
                    metadata: [
                        "error": .string("\(error)"),
                        "commentID": .string("\(request.commentID)"),
                        "voteID": .string("\(vote.id)")
                    ]
                )
            }
        }
    }

    // MARK: Sort type

    func doSortTypePresentation(request: Discussions.SortTypePresentation.Request) {
        self.presenter.presentSortType(
            response: Discussions.SortTypePresentation.Response(
                currentSortType: self.currentSortType,
                availableSortTypes: Discussions.SortType.allCases
            )
        )
    }

    func doSortTypeUpdate(request: Discussions.SortTypeUpdate.Request) {
        guard let selectedSortType = Discussions.SortType(rawValue: request.uniqueIdentifier),
              self.currentSortType != selectedSortType else {
            return
        }

        self.currentSortType = selectedSortType
        self.presenter.presentSortTypeUpdate(
            response: Discussions.SortTypeUpdate.Response(result: self.makeDiscussionsData())
        )
    }

    // MARK: - Private API

    // MARK: Fetching helpers

    private func fetchDiscussions(
        discussionProxyID: DiscussionProxy.IdType
    ) -> Promise<Discussions.DiscussionsResponseData> {
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

    private func makeDiscussionsData() -> Discussions.DiscussionsResponseData {
        return Discussions.DiscussionsResponseData(
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
        let offset = min(discussionsLeftToLoad, DiscussionsInteractor.discussionsLoadingInterval)

        return Array(self.currentDiscussionsIDs[startIndex..<startIndex + offset])
    }

    private func getNextReplyIDsToLoad(discussion: Comment) -> [Comment.IdType] {
        let loadedRepliesIDs = Set(self.currentReplies[discussion.id, default: []].map { $0.id })
        var idsToLoad = [Comment.IdType]()

        for replyID in discussion.repliesIDs {
            if !loadedRepliesIDs.contains(replyID) {
                idsToLoad.append(replyID)
                if idsToLoad.count == DiscussionsInteractor.repliesLoadingInterval {
                    return idsToLoad
                }
            }
        }

        return idsToLoad
    }

    private func getAllComments() -> [Comment] {
        return self.currentDiscussions + Array(self.currentReplies.values).reduce([], +)
    }

    // MARK: Write & delete helpers

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
            response: Discussions.WriteCommentPresentation.Response(
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
            return DiscussionsInteractor.logger.error(
                "discussions interactor: attempt to edit comment but not able to find it by id"
            )
        }

        self.presenter.presentWriteComment(
            response: Discussions.WriteCommentPresentation.Response(
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

// MARK: - DiscussionsInteractor: WriteCommentOutputProtocol -

extension DiscussionsInteractor: WriteCommentOutputProtocol {
    func handleCommentCreated(_ comment: Comment) {
        if let parentID = comment.parentID,
            let parentIndex = self.currentDiscussions.firstIndex(where: { $0.id == parentID }) {
            self.currentDiscussions[parentIndex].repliesIDs.append(comment.id)
            self.currentReplies[parentID, default: []].append(comment)

            self.presenter.presentCommentCreated(
                response: Discussions.CommentCreated.Response(result: self.makeDiscussionsData())
            )
        } else {
            self.presenter.presentWaitingState(
                response: Discussions.BlockingWaitingIndicatorUpdate.Response(shouldDismiss: false)
            )

            self.currentDiscussions.append(comment)

            self.provider.fetchDiscussionProxy(id: self.discussionProxyID).done { discussionProxy in
                self.currentDiscussionProxy = discussionProxy
            }.ensure {
                self.presenter.presentWaitingState(
                    response: Discussions.BlockingWaitingIndicatorUpdate.Response(shouldDismiss: true)
                )
                self.presenter.presentCommentCreated(
                    response: Discussions.CommentCreated.Response(result: self.makeDiscussionsData())
                )
            }.cauterize()

            self.provider.incrementStepDiscussionsCount(stepID: self.stepID).cauterize()
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
            response: Discussions.CommentUpdated.Response(result: self.makeDiscussionsData())
        )
    }
}

// MARK: - DiscussionsInteractor (UserDefaults) -

extension DiscussionsInteractor {
    private static let discussionsSortTypeKey = "discussionsSortTypeKey"

    private var currentSortType: Discussions.SortType {
        get {
            if let sortTypeKey = UserDefaults.standard.string(forKey: DiscussionsInteractor.discussionsSortTypeKey) {
                return Discussions.SortType(rawValue: sortTypeKey) ?? .last
            }
            return .last
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: DiscussionsInteractor.discussionsSortTypeKey)
        }
    }
}
