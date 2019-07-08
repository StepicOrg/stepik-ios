import Foundation
import PromiseKit

protocol DiscussionsView: class {
}

protocol DiscussionsPresenterProtocol: class {
    var discussionProxyId: String { get }
    var stepId: Step.IdType { get }

    func refresh()
}

final class DiscussionsPresenter: DiscussionsPresenterProtocol {
    weak var view: DiscussionsView?

    let discussionProxyId: String
    let stepId: Step.IdType

    private static let discussionsLoadingInterval = 20
    private static let repliesLoadingInterval = 20

    private let discussionProxiesNetworkService: DiscussionProxiesNetworkServiceProtocol
    private let commentsNetworkService: CommentsNetworkServiceProtocol
    private let votesNetworkService: VotesNetworkServiceProtocol

    private var discussionIds = DiscussionIds()
    private var discussions = [Comment]()
    private var replies = Replies()

    private var isReloading = false

    init(
        view: DiscussionsView?,
        discussionProxyId: String,
        stepId: Step.IdType,
        discussionProxiesNetworkService: DiscussionProxiesNetworkServiceProtocol,
        commentsNetworkService: CommentsNetworkServiceProtocol,
        votesNetworkService: VotesNetworkServiceProtocol
    ) {
        self.view = view
        self.discussionProxyId = discussionProxyId
        self.stepId = stepId
        self.discussionProxiesNetworkService = discussionProxiesNetworkService
        self.commentsNetworkService = commentsNetworkService
        self.votesNetworkService = votesNetworkService
    }

    func refresh() {
        //self.emptyDatasetState = .none

        if self.isReloading {
            return
        }

        //self.resetData(reload: false)
        self.isReloading = true

        let queue = DispatchQueue.global(qos: .userInitiated)

        queue.promise {
            self.discussionProxiesNetworkService.fetch(id: self.discussionProxyId)
        }.then(on: queue) { discussionProxy -> Promise<[Int]> in
            self.discussionIds.all = discussionProxy.discussionIds
            return .value(self.getNextDiscussionIdsToLoad())
        }.then(on: queue) { ids -> Promise<[Comment]> in
            self.commentsNetworkService.fetch(ids: ids)
        }.done(on: queue) { comments in
            self.discussionIds.loaded += comments.map { $0.id }

            for comment in comments {
                if let parentId = comment.parentId {
                    self.replies.loaded[parentId] = (self.replies.loaded[parentId, default: []] + [comment]).sorted {
                        $0.time.compare($1.time) == .orderedAscending
                    }
                } else {
                    self.discussions.append(comment)
                }
            }
            
            self.discussions.sort { $0.time.compare($1.time) == .orderedDescending }
        }.ensure {
            self.isReloading = false
        }.catch { error in
            print(error)
        }
    }

    private func getNextDiscussionIdsToLoad() -> [Int] {
        let startIndex = self.discussionIds.loaded.count
        let offset = min(self.discussionIds.leftToLoad, DiscussionsPresenter.discussionsLoadingInterval)
        return Array(self.discussionIds.all[startIndex..<startIndex + offset])
    }
}
