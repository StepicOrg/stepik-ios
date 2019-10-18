import Foundation
import PromiseKit

protocol NewDiscussionsInteractorProtocol {
    func doDiscussionsLoad(request: NewDiscussions.DiscussionsLoad.Request)
}

final class NewDiscussionsInteractor: NewDiscussionsInteractorProtocol {
    private static let discussionsLoadingInterval = 20
    private static let repliesLoadingInterval = 20

    private let presenter: NewDiscussionsPresenterProtocol
    private let provider: NewDiscussionsProviderProtocol

    private let discussionProxyID: DiscussionProxy.IdType

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
    private let currentSortType: NewDiscussions.SortType = .default

    // Semaphore to prevent concurrent fetching
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    private lazy var fetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.NewDiscussionsInteractor.DiscussionsFetch"
    )

    init(
        discussionProxyID: DiscussionProxy.IdType,
        presenter: NewDiscussionsPresenterProtocol,
        provider: NewDiscussionsProviderProtocol
    ) {
        self.discussionProxyID = discussionProxyID
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
            print("new discussions interactor: start fetching discussions")

            strongSelf.fetchDiscussions(discussionProxyID: strongSelf.discussionProxyID).done { discussionsData in
                DispatchQueue.main.async {
                    print("new discussions interactor: finish fetching discussions")
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

    // MARK: - Private API

    private func fetchDiscussions(
        discussionProxyID: DiscussionProxy.IdType
    ) -> Promise<NewDiscussions.DiscussionsLoad.Data> {
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

                let discussionsData = NewDiscussions.DiscussionsLoad.Data(
                    discussionProxy: self.currentDiscussionProxy.require(),
                    discussions: self.currentDiscussions,
                    replies: self.currentReplies,
                    sortType: self.currentSortType
                )

                seal.fulfill(discussionsData)
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

    private func getNextDiscussionsIDsToLoad() -> [Comment.IdType] {
        assert(self.currentDiscussionProxy != nil, "discussion proxy must exists, unexpected behavior")

        let discussionsLeftToLoad = self.currentDiscussionsIDs.count - self.currentDiscussions.count

        let startIndex = self.currentDiscussions.count
        let offset = min(discussionsLeftToLoad, NewDiscussionsInteractor.discussionsLoadingInterval)

        return Array(self.currentDiscussionsIDs[startIndex..<startIndex + offset])
    }

    // MARK: - Types -

    enum Error: Swift.Error {
        case fetchFailed
    }
}
