import Foundation
import PromiseKit

protocol DiscussionsPresenterProtocol: class {
    var discussionProxyId: String { get }
    var stepId: Step.IdType { get }

    func refresh()
    func selectViewData(_ viewData: DiscussionsViewData)
    func writeComment(_ comment: Comment)
    func likeComment(_ comment: Comment)
    func abuseComment(_ comment: Comment)
}

final class DiscussionsPresenter: DiscussionsPresenterProtocol {
    private static let discussionsLoadingInterval = 20
    private static let repliesLoadingInterval = 20

    weak var view: DiscussionsView?

    let discussionProxyId: String
    let stepId: Step.IdType

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
        if self.isReloading {
            return
        }
        self.isReloading = true

        self.discussionIds = DiscussionIds()
        self.replies = Replies()
        self.discussions = [Comment]()

        let queue = DispatchQueue.global(qos: .userInitiated)

        queue.promise {
            self.discussionProxiesNetworkService.fetch(id: self.discussionProxyId)
        }.then(on: queue) { discussionProxy -> Promise<[Int]> in
            self.discussionIds.all = discussionProxy.discussionIds
            return .value(self.getNextDiscussionIdsToLoad())
        }.then(on: queue) { ids in
            self.fetchComments(ids: ids)
        }.done {
            self.reloadViewData()
        }.ensure {
            self.isReloading = false
        }.catch { error in
            print("DiscussionsPresenter :: error :: \(error)")
            self.view?.displayError(error)
        }
    }

    func writeComment(_ comment: Comment) {
        if let parentId = comment.parentId {
            if let parentIdx = self.discussions.index(where: { $0.id == parentId }) {
                self.discussions[parentIdx].repliesIds += [comment.id]
                self.replies.loaded[parentId, default: []] += [comment]
            }
        } else {
            self.discussionIds.all.insert(comment.id, at: 0)
            self.discussionIds.loaded.insert(comment.id, at: 0)
            self.discussions.insert(comment, at: 0)

            // TODO: increment discussions count
            //self.step?.discussionsCount? += 1
        }
        self.reloadViewData()
    }

    func selectViewData(_ viewData: DiscussionsViewData) {
        if let comment = viewData.comment {
            self.view?.displayDiscussionAlert(comment: comment)
        } else if let loadRepliesFor = viewData.loadRepliesFor {
            let idsToLoad = self.getNextReplyIdsToLoad(discussion: loadRepliesFor)
            self.fetchComments(ids: idsToLoad).done {
                self.reloadViewData()
            }.catch { error in
                self.view?.displayError(error)
            }
        } else if viewData.loadDiscussions {
            let idsToLoad = self.getNextDiscussionIdsToLoad()
            self.fetchComments(ids: idsToLoad).done {
                self.reloadViewData()
            }.catch { error in
                self.view?.displayError(error)
            }
        }

//        if let loadRepliesFor = self.cellsInfo[indexPath.row].loadRepliesFor {
//            let idsToLoad = self.getNextReplyIdsToLoad(discussion: loadRepliesFor)
//            if let cell = tableView.cellForRow(at: indexPath) as? LoadMoreTableViewCell {
//                cell.isUpdating = true
//                self.loadDiscussions(ids: idsToLoad, success: { [weak self, weak cell] in
//                    DispatchQueue.main.async {
//                        self?.reloadTableData()
//                        cell?.isUpdating = false
//                    }
//                })
//            }
//        }

//        if self.cellsInfo[indexPath.row].loadDiscussions != nil {
//            let idsToLoad = self.getNextDiscussionIdsToLoad()
//            if let cell = tableView.cellForRow(at: indexPath) as? LoadMoreTableViewCell {
//                cell.isUpdating = true
//                self.loadDiscussions(ids: idsToLoad, success: { [weak self, weak cell] in
//                    DispatchQueue.main.async {
//                        self?.reloadTableData()
//                        cell?.isUpdating = false
//                    }
//                })
//            }
//        }
    }

    func likeComment(_ comment: Comment) {
        if let voteValue = comment.vote.value {
            let voteValueToSet: VoteValue? = voteValue == .epic ? nil : .epic
            let vote = Vote(id: comment.vote.id, value: voteValueToSet)

            self.votesNetworkService.update(vote: vote).done { [weak self] vote in
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
                self?.reloadViewData()
            }.catch { error in
                print("DiscussionsPresenter :: \(#function) :: \(error)")
            }
        } else {
            let vote = Vote(id: comment.vote.id, value: .epic)
            self.votesNetworkService.update(vote: vote).done { [weak self] vote in
                AnalyticsReporter.reportEvent(AnalyticsEvents.Discussion.liked)
                comment.vote = vote
                comment.epicCount += 1
                self?.reloadViewData()
            }.catch { error in
                print("DiscussionsPresenter :: \(#function) :: \(error)")
            }
        }
    }

    func abuseComment(_ comment: Comment) {
        if let voteValue = comment.vote.value {
            let vote = Vote(id: comment.vote.id, value: .abuse)
            self.votesNetworkService.update(vote: vote).done { [weak self] vote in
                comment.vote = vote
                switch voteValue {
                case .abuse:
                    break
                case .epic:
                    AnalyticsReporter.reportEvent(AnalyticsEvents.Discussion.abused)
                    comment.epicCount -= 1
                    comment.abuseCount += 1
                    self?.reloadViewData()
                }
            }.catch { error in
                print("DiscussionsPresenter :: \(#function) :: \(error)")
            }
        } else {
            let vote = Vote(id: comment.vote.id, value: .abuse)
            self.votesNetworkService.update(vote: vote).done { vote in
                AnalyticsReporter.reportEvent(AnalyticsEvents.Discussion.abused, parameters: nil)
                comment.vote = vote
                comment.abuseCount += 1
            }.catch { error in
                print("DiscussionsPresenter :: \(#function) :: \(error)")
            }
        }
    }
    
    private func getNextDiscussionIdsToLoad() -> [Int] {
        let startIndex = self.discussionIds.loaded.count
        let offset = min(self.discussionIds.leftToLoad, DiscussionsPresenter.discussionsLoadingInterval)
        return Array(self.discussionIds.all[startIndex..<startIndex + offset])
    }

    private func getNextReplyIdsToLoad(discussion: Comment) -> [Int] {
        let loadedReplies = Set(replies.loaded[discussion.id, default: []].map { $0.id })
        var idsToLoad = [Int]()

        for replyId in discussion.repliesIds {
            if !loadedReplies.contains(replyId) {
                idsToLoad.append(replyId)
                if idsToLoad.count == DiscussionsPresenter.repliesLoadingInterval {
                    return idsToLoad
                }
            }
        }

        return idsToLoad
    }

    private func fetchComments(ids: [Comment.IdType]) -> Promise<Void> {
        return self.commentsNetworkService.fetch(ids: ids).done(on: .global(qos: .userInitiated)) { comments in
            self.discussionIds.loaded += ids

            self.discussions += comments
                .filter { $0.parentId == nil }
                .reordered(order: ids, transform: { $0.id })
            self.discussions.sort { $0.time.compare($1.time) == .orderedDescending }

            var commentIdsWithReplies = Set<Int>()
            for comment in comments where comment.parentId != nil {
                self.replies.loaded[comment.parentId!, default: []] += [comment]
                commentIdsWithReplies.insert(comment.parentId!)
            }

            for id in commentIdsWithReplies {
                guard let idx = self.discussions.firstIndex(where: { $0.id == id }) else {
                    continue
                }

                self.replies.loaded[id] = self.replies.loaded[id, default: []]
                    .reordered(order: self.discussions[idx].repliesIds, transform: { $0.id })
                    .sorted { $0.time.compare($1.time) == .orderedAscending }
            }
        }
    }

    private func reloadViewData() {
        var viewData = [DiscussionsViewData]()

        for discussion in self.discussions {
            viewData.append(DiscussionsViewData(comment: discussion, separatorType: .small))

            for reply in self.replies.loaded[discussion.id, default: []] {
                viewData.append(DiscussionsViewData(comment: reply, separatorType: .small))
            }

            let leftToLoad = self.replies.leftToLoad(discussion)
            if leftToLoad > 0 {
                viewData.append(DiscussionsViewData(loadRepliesFor: discussion))
            } else {
                viewData[viewData.count - 1].separatorType = .big
            }
        }

        if self.discussionIds.leftToLoad > 0 {
            viewData.append(DiscussionsViewData(loadDiscussions: true))
        }

        self.view?.setViewData(viewData)
    }

    // MARK: Inner structs

    private struct DiscussionIds {
        var all = [Int]()
        var loaded = [Int]()

        var leftToLoad: Int {
            return self.all.count - self.loaded.count
        }
    }

    private struct Replies {
        var loaded = [Int: [Comment]]()

        func leftToLoad(_ comment: Comment) -> Int {
            if let loadedCount = self.loaded[comment.id]?.count {
                return comment.repliesIds.count - loadedCount
            } else {
                return comment.repliesIds.count
            }
        }
    }
}
