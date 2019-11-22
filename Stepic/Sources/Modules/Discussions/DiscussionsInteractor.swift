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
    func doSortTypesPresentation(request: Discussions.SortTypesPresentation.Request)
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
    private let presentationContext: Discussions.PresentationContext

    private var currentDiscussionProxy: DiscussionProxy?
    private var currentDiscussions: [Comment] = []
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
        presentationContext: Discussions.PresentationContext,
        presenter: DiscussionsPresenterProtocol,
        provider: DiscussionsProviderProtocol
    ) {
        self.discussionProxyID = discussionProxyID
        self.stepID = stepID
        self.presentationContext = presentationContext
        self.presenter = presenter
        self.provider = provider

        DiscussionsInteractor.logger.info(
            "discussions interactor: did init with presentationContext: \(presentationContext)"
        )

        self.reportOpenedEventToAnalytics()
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
                DiscussionsInteractor.logger.info("discussions interactor: finish fetching discussions")
                DispatchQueue.main.async {
                    strongSelf.presenter.presentDiscussions(response: .init(result: .success(discussionsData)))

                    if case .scrollTo(let discussionID, _) = strongSelf.presentationContext {
                        strongSelf.presenter.presentSelectComment(response: .init(commentID: discussionID))
                    }
                }
            }.catch { error in
                DiscussionsInteractor.logger.error("discussions interactor: failed fetch discussions, error: \(error)")
                DispatchQueue.main.async {
                    strongSelf.presenter.presentDiscussions(response: .init(result: .failure(Error.fetchFailed)))
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

            let idsToLoad = strongSelf.getNextDiscussionsIDsToLoad(direction: request.direction)
            DiscussionsInteractor.logger.info(
                "discussions interactor: start fetching next discussions ids: \(idsToLoad)"
            )

            strongSelf.provider.fetchComments(ids: idsToLoad).done { fetchedComments in
                DiscussionsInteractor.logger.info("discussions interactor: finish fetching next discussions")
                strongSelf.updateDataWithNewComments(fetchedComments)
                DispatchQueue.main.async {
                    strongSelf.presenter.presentNextDiscussions(
                        response: .init(
                            result: .success(strongSelf.makeDiscussionsData()),
                            direction: request.direction
                        )
                    )
                }
            }.catch { error in
                DiscussionsInteractor.logger.error(
                    "discussions interactor: failed fetch next discussions, error: \(error)"
                )
                DispatchQueue.main.async {
                    strongSelf.presenter.presentNextDiscussions(
                        response: .init(result: .failure(Error.fetchFailed), direction: request.direction)
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
        self.presenter.presentNextReplies(response: .init(result: self.makeDiscussionsData()))

        self.fetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            let idsToLoad = strongSelf.getNextReplyIDsToLoad(discussion: discussion)
            DiscussionsInteractor.logger.info("discussions interactor: start fetching next replies ids: \(idsToLoad)")

            strongSelf.provider.fetchComments(ids: idsToLoad).done { fetchedComments in
                DiscussionsInteractor.logger.info("discussions interactor: finish fetching next replies")

                strongSelf.updateDataWithNewComments(fetchedComments)
                strongSelf.discussionsIDsFetchingReplies.remove(discussion.id)

                DispatchQueue.main.async {
                    strongSelf.presenter.presentNextReplies(response: .init(result: strongSelf.makeDiscussionsData()))
                }
            }.catch { error in
                DiscussionsInteractor.logger.error("discussions interactor: failed fetch next replies, error: \(error)")
                strongSelf.discussionsIDsFetchingReplies.remove(discussion.id)
                DispatchQueue.main.async {
                    strongSelf.presenter.presentNextReplies(response: .init(result: strongSelf.makeDiscussionsData()))
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
            guard let commentID = request.commentID else {
                return DiscussionsInteractor.logger.error("discussions interactor: unable to edit comment, id is nil")
            }

            self.presentEditComment(commentID: commentID)
        }
    }

    func doCommentDelete(request: Discussions.CommentDelete.Request) {
        DiscussionsInteractor.logger.info("discussions interactor: start deleting comment by id: \(request.commentID)")
        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        let commentID = request.commentID

        self.provider.deleteComment(id: commentID).done {
            DiscussionsInteractor.logger.info("discussions interactor: deleted comment with id: \(commentID)")

            if let discussionIndex = self.currentDiscussions.firstIndex(where: { $0.id == commentID }) {
                self.currentDiscussions.remove(at: discussionIndex)
                self.currentReplies[commentID] = nil

                self.provider.decrementStepDiscussionsCount(stepID: self.stepID).cauterize()
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
                self.presenter.presentCommentDelete(response: .init(result: .success(self.makeDiscussionsData())))
            }.cauterize()
        }.catch { error in
            DiscussionsInteractor.logger.error(
                "discussions interactor: failed delete comment by id: \(commentID), error: \(error)"
            )
            self.presenter.presentCommentDelete(response: .init(result: .failure(error)))
        }
    }

    // MARK: Like & abuse

    func doCommentLike(request: Discussions.CommentLike.Request) {
        guard let comment = self.getAllComments().first(where: { $0.id == request.commentID }) else {
            return DiscussionsInteractor.logger.error(
                "discussions interactor: unable like comment, can't find comment with id: \(request.commentID)"
            )
        }

        if let voteValue = comment.vote.value {
            let voteValueToSet: VoteValue? = voteValue == .epic ? nil : .epic
            let vote = Vote(id: comment.vote.id, value: voteValueToSet)

            DiscussionsInteractor.logger.info(
                "discussions interactor: start liking vote from \(voteValue) to \(voteValueToSet ??? "null")"
            )

            self.provider.updateVote(vote).done { vote in
                DiscussionsInteractor.logger.info("discussions interactor: finish liking vote")

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
                self.presenter.presentCommentLike(response: .init(result: self.makeDiscussionsData()))
            }.catch { error in
                DiscussionsInteractor.logger.error("discussions interactor: failed like vote, error: \(error)")
            }
        } else {
            DiscussionsInteractor.logger.info("discussions interactor: start liking vote to epic value")

            let vote = Vote(id: comment.vote.id, value: .epic)

            self.provider.updateVote(vote).done { vote in
                DiscussionsInteractor.logger.info("discussions interactor: finish liking vote")
                AnalyticsReporter.reportEvent(AnalyticsEvents.Discussion.liked)

                comment.vote = vote
                comment.epicCount += 1
            }.ensure {
                self.presenter.presentCommentLike(response: .init(result: self.makeDiscussionsData()))
            }.catch { error in
                DiscussionsInteractor.logger.error("discussions interactor: failed like vote, error: \(error)")
            }
        }
    }

    func doCommentAbuse(request: Discussions.CommentAbuse.Request) {
        guard let comment = self.getAllComments().first(where: { $0.id == request.commentID }) else {
            return DiscussionsInteractor.logger.error(
                "discussions interactor: unable abuse comment, can't find comment with id: \(request.commentID)"
            )
        }

        if let voteValue = comment.vote.value {
            let voteValueToSet: VoteValue? = voteValue == .abuse ? nil : .abuse
            let vote = Vote(id: comment.vote.id, value: voteValueToSet)

            DiscussionsInteractor.logger.info(
                "discussions interactor: start abusing vote from \(voteValue) to \(voteValueToSet ??? "null")"
            )

            self.provider.updateVote(vote).done { vote in
                DiscussionsInteractor.logger.info("discussions interactor: finish abusing vote")

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
                self.presenter.presentCommentAbuse(response: .init(result: self.makeDiscussionsData()))
            }.catch { error in
                DiscussionsInteractor.logger.error("discussions interactor: failed abuse vote, error: \(error)")
            }
        } else {
            DiscussionsInteractor.logger.info("discussions interactor: start abusing vote to abuse value")

            let vote = Vote(id: comment.vote.id, value: .abuse)

            self.provider.updateVote(vote).done { vote in
                DiscussionsInteractor.logger.info("discussions interactor: finish abusing vote")
                AnalyticsReporter.reportEvent(AnalyticsEvents.Discussion.abused)

                comment.vote = vote
                comment.abuseCount += 1
            }.ensure {
                self.presenter.presentCommentAbuse(response: .init(result: self.makeDiscussionsData()))
            }.catch { error in
                DiscussionsInteractor.logger.error("discussions interactor: failed abuse vote, error: \(error)")
            }
        }
    }

    // MARK: Sort type

    func doSortTypesPresentation(request: Discussions.SortTypesPresentation.Request) {
        self.presenter.presentSortTypes(
            response: .init(currentSortType: self.currentSortType, availableSortTypes: Discussions.SortType.allCases)
        )
    }

    func doSortTypeUpdate(request: Discussions.SortTypeUpdate.Request) {
        guard let selectedSortType = Discussions.SortType(rawValue: request.uniqueIdentifier),
              self.currentSortType != selectedSortType else {
            return
        }

        self.currentSortType = selectedSortType
        self.presenter.presentSortTypeUpdate(response: .init(result: self.makeDiscussionsData()))
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
                switch self.presentationContext {
                case .fromBeginning:
                    return .value(self.getNextDiscussionsIDsToLoad(direction: .bottom))
                case .scrollTo:
                    return .value(self.getNextDiscussionsIDsToLoad(direction: nil))
                }
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
        let selectedDiscussionID: Comment.IdType? = {
            if case .scrollTo(let discussionID, _) = self.presentationContext {
                return discussionID
            }
            return nil
        }()

        return Discussions.DiscussionsResponseData(
            discussionProxy: self.currentDiscussionProxy.require(),
            discussions: self.currentDiscussions,
            discussionsIDsFetchingMore: self.discussionsIDsFetchingReplies,
            replies: self.currentReplies,
            currentSortType: self.currentSortType,
            discussionsLeftToLoadInLeftHalf: self.getDiscussionsLeftToLoadInLeftHalfCount(),
            discussionsLeftToLoadInRightHalf: self.getDiscussionsLeftToLoadInRightHalfCount(),
            selectedDiscussionID: selectedDiscussionID
        )
    }

    private func getDiscussionsLeftToLoadInLeftHalfCount(discussionsWindow: DiscussionsWindow? = nil) -> Int {
        switch self.presentationContext {
        case .fromBeginning:
            return 0
        case .scrollTo:
            let discussionsWindow = discussionsWindow != nil
                ? discussionsWindow.require()
                : self.getLoadedDiscussionsWindow()
            return discussionsWindow.startIndex == 1 ? 1 : max(discussionsWindow.startIndex - 1, 0)
        }
    }

    private func getDiscussionsLeftToLoadInRightHalfCount(discussionsWindow: DiscussionsWindow? = nil) -> Int {
        let discussionsWindow = discussionsWindow != nil
            ? discussionsWindow.require()
            : self.getLoadedDiscussionsWindow()

        let leftToLoad: Int = {
            if discussionsWindow.endIndex == 0 {
                return self.currentDiscussionsIDs.count - self.currentDiscussions.count
            }
            return self.currentDiscussionsIDs.count - discussionsWindow.endIndex - 1
        }()

        return max(leftToLoad, 0)
    }

    private func getLoadedDiscussionsWindow() -> (startIndex: Int, endIndex: Int) {
        let loadedDiscussionsIDs = Set(self.currentDiscussions.map({ $0.id }))

        switch self.presentationContext {
        case .fromBeginning:
            if loadedDiscussionsIDs.isEmpty {
                return (0, 0)
            }

            for (index, id) in self.currentDiscussionsIDs.reversed().enumerated() {
                if loadedDiscussionsIDs.contains(id) {
                    let reversedIndex = self.currentDiscussionsIDs.count - index - 1
                    return (0, reversedIndex)
                }
            }

            return (0, 0)
        case .scrollTo(let discussionID, _):
            // This could happen when the selected comment was deleted and there are no more comments.
            guard let discussionIndex = self.currentDiscussionsIDs.index(of: discussionID) else {
                return (0, 0)
            }

            if loadedDiscussionsIDs.isEmpty {
                return (discussionIndex, discussionIndex)
            }

            let startIndex: Int = {
                for (index, id) in self.currentDiscussionsIDs.enumerated() {
                    if loadedDiscussionsIDs.contains(id) {
                        return index
                    } else if id == discussionID {
                        return discussionIndex
                    }
                }
                return discussionIndex
            }()

            let endIndex: Int = {
                for (index, id) in self.currentDiscussionsIDs.reversed().enumerated() {
                    if loadedDiscussionsIDs.contains(id) {
                        return self.currentDiscussionsIDs.count - index - 1
                    } else if id == discussionID {
                        return discussionIndex
                    }
                }
                return discussionIndex
            }()

            return (startIndex, endIndex)
        }
    }

    private func getNextDiscussionsIDsToLoad(direction: Discussions.PaginationDirection?) -> [Comment.IdType] {
        let discussionsWindow = self.getLoadedDiscussionsWindow()

        switch direction {
        case .top?:
            if case .scrollTo = self.presentationContext {
                let endIndex = discussionsWindow.startIndex
                let offset = min(
                    self.getDiscussionsLeftToLoadInLeftHalfCount(discussionsWindow: discussionsWindow),
                    DiscussionsInteractor.discussionsLoadingInterval
                )
                let startIndex = max(endIndex - offset, 0)

                return Array(self.currentDiscussionsIDs[startIndex..<endIndex])
            } else {
                assertionFailure("Invalid state")
            }
        case .bottom?:
            let startIndex = discussionsWindow.endIndex == 0 ? 0 : discussionsWindow.endIndex + 1
            let offset = min(
                self.getDiscussionsLeftToLoadInRightHalfCount(discussionsWindow: discussionsWindow),
                DiscussionsInteractor.discussionsLoadingInterval
            )
            let endIndex = startIndex + offset

            return Array(self.currentDiscussionsIDs[startIndex..<endIndex])
        case .none:
            if case .scrollTo(let discussionID, _) = self.presentationContext {
                guard let discussionIndex = self.currentDiscussionsIDs.index(of: discussionID) else {
                    assertionFailure("Discussion must appear in the collection")
                    return []
                }

                let loadingInterval = DiscussionsInteractor.discussionsLoadingInterval / 2

                let leftOffset = min(
                    self.getDiscussionsLeftToLoadInLeftHalfCount(discussionsWindow: discussionsWindow), loadingInterval
                )
                let startIndex = max(discussionIndex - leftOffset, 0)
                let leftHalf = Array(self.currentDiscussionsIDs[startIndex..<discussionIndex])

                let rightOffset = min(
                    self.getDiscussionsLeftToLoadInRightHalfCount(discussionsWindow: discussionsWindow), loadingInterval
                )
                let endIndex = min(discussionIndex + rightOffset, self.currentDiscussionsIDs.count - 1)
                let rightHalf = Array(self.currentDiscussionsIDs[discussionIndex...endIndex])

                return leftHalf + rightHalf
            } else {
                assertionFailure("Invalid state")
            }
        }

        return []
    }

    private func getNextReplyIDsToLoad(discussion: Comment) -> [Comment.IdType] {
        let loadedIDs = Set(self.currentReplies[discussion.id, default: []].map { $0.id })
        var idsToLoad = [Comment.IdType]()

        for replyID in discussion.repliesIDs {
            if !loadedIDs.contains(replyID) {
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
                    } else if replies.contains(where: { $0.id == commentID }) {
                        return discussionID
                    }
                }
                return nil
            }()
        }

        self.presenter.presentWriteComment(
            response: .init(targetID: self.stepID, parentID: parentID, comment: nil, presentationContext: .create)
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
                "discussions interactor: unable edit comment, can't find it by id: \(commentID)"
            )
        }

        self.presenter.presentWriteComment(
            response: .init(
                targetID: self.stepID,
                parentID: unwrappedComment.parentID,
                comment: unwrappedComment,
                presentationContext: .edit
            )
        )
    }

    // MARK: Analytics

    private func reportOpenedEventToAnalytics() {
        let source: AmplitudeAnalyticsEvents.Discussions.DiscussionsSource = {
            switch self.presentationContext {
            case .fromBeginning:
                return .default
            case .scrollTo(_, let replyID):
                if replyID != nil {
                    return .reply
                }
                return .discussion
            }
        }()

        AmplitudeAnalyticsEvents.Discussions.opened(source: source).send()
    }

    // MARK: - Types -

    private typealias DiscussionsWindow = (startIndex: Int, endIndex: Int)

    enum Error: Swift.Error {
        case fetchFailed
    }
}

// MARK: - DiscussionsInteractor: DiscussionsInputProtocol -

extension DiscussionsInteractor: DiscussionsInputProtocol { }

// MARK: - DiscussionsInteractor: WriteCommentOutputProtocol -

extension DiscussionsInteractor: WriteCommentOutputProtocol {
    func handleCommentCreated(_ comment: Comment) {
        if let parentID = comment.parentID,
            let parentIndex = self.currentDiscussions.firstIndex(where: { $0.id == parentID }) {
            self.currentDiscussions[parentIndex].repliesIDs.append(comment.id)
            self.currentReplies[parentID, default: []].append(comment)

            self.presenter.presentCommentCreate(response: .init(result: self.makeDiscussionsData()))
        } else {
            self.presenter.presentWaitingState(response: .init(shouldDismiss: false))
            self.currentDiscussions.append(comment)

            self.provider.fetchDiscussionProxy(id: self.discussionProxyID).done { discussionProxy in
                self.currentDiscussionProxy = discussionProxy
            }.ensure {
                self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
                self.presenter.presentCommentCreate(response: .init(result: self.makeDiscussionsData()))
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

        self.presenter.presentCommentUpdate(response: .init(result: self.makeDiscussionsData()))
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
