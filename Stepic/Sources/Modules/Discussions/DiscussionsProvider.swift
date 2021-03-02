import Foundation
import PromiseKit

protocol DiscussionsProviderProtocol {
    func fetchDiscussionProxy(id: DiscussionProxy.IdType) -> Promise<DiscussionProxy>
    func fetchComments(ids: [Comment.IdType], stepID: Step.IdType) -> Promise<[Comment]>
    func deleteComment(id: Comment.IdType) -> Promise<Void>
    func updateVote(_ vote: Vote) -> Promise<Vote>
    func incrementStepDiscussionsCount(stepID: Step.IdType) -> Promise<Void>
    func decrementStepDiscussionsCount(stepID: Step.IdType) -> Promise<Void>
    func fetchCachedStep(stepID: Step.IdType) -> Guarantee<Step?>
}

final class DiscussionsProvider: DiscussionsProviderProtocol {
    private let discussionProxiesNetworkService: DiscussionProxiesNetworkServiceProtocol
    private let commentsNetworkService: CommentsNetworkServiceProtocol
    private let votesNetworkService: VotesNetworkServiceProtocol
    private let stepsNetworkService: StepsNetworkServiceProtocol
    private let stepsPersistenceService: StepsPersistenceServiceProtocol

    init(
        discussionProxiesNetworkService: DiscussionProxiesNetworkServiceProtocol,
        commentsNetworkService: CommentsNetworkServiceProtocol,
        votesNetworkService: VotesNetworkServiceProtocol,
        stepsNetworkService: StepsNetworkServiceProtocol,
        stepsPersistenceService: StepsPersistenceServiceProtocol
    ) {
        self.discussionProxiesNetworkService = discussionProxiesNetworkService
        self.commentsNetworkService = commentsNetworkService
        self.votesNetworkService = votesNetworkService
        self.stepsNetworkService = stepsNetworkService
        self.stepsPersistenceService = stepsPersistenceService
    }

    func fetchDiscussionProxy(id: DiscussionProxy.IdType) -> Promise<DiscussionProxy> {
        Promise { seal in
            self.discussionProxiesNetworkService.fetch(id: id).done {
                seal.fulfill($0)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchComments(ids: [Comment.IdType], stepID: Step.IdType) -> Promise<[Comment]> {
        Promise { seal in
            firstly {
                self.stepsPersistenceService.fetch(ids: [stepID])
            }.then { cachedSteps -> Promise<[Step]> in
                if cachedSteps.first != nil {
                    return .value(cachedSteps)
                }

                return self.stepsNetworkService.fetch(ids: [stepID])
            }.then { steps -> Promise<[Comment]> in
                guard let step = steps.first else {
                    throw Error.fetchFailed
                }

                return self.commentsNetworkService.fetch(ids: ids, blockName: step.block.name)
            }.done { comments in
                seal.fulfill(comments)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func deleteComment(id: Comment.IdType) -> Promise<Void> {
        Promise { seal in
            self.commentsNetworkService.delete(id: id).done {
                seal.fulfill(())
            }.catch { _ in
                seal.reject(Error.commentDeleteFailed)
            }
        }
    }

    func updateVote(_ vote: Vote) -> Promise<Vote> {
        Promise { seal in
            self.votesNetworkService.update(vote: vote).done { vote in
                seal.fulfill(vote)
            }.catch { _ in
                seal.reject(Error.voteUpdateFailed)
            }
        }
    }

    func incrementStepDiscussionsCount(stepID: Step.IdType) -> Promise<Void> {
        Promise { seal in
            self.stepsPersistenceService.fetch(ids: [stepID]).done { steps in
                if let step = steps.first {
                    step.discussionsCount? += 1
                }
                CoreDataHelper.shared.save()
            }.catch { _ in
                seal.reject(Error.stepDiscussionsIncrementFailed)
            }
        }
    }

    func decrementStepDiscussionsCount(stepID: Step.IdType) -> Promise<Void> {
        Promise { seal in
            self.stepsPersistenceService.fetch(ids: [stepID]).done { steps in
                if let step = steps.first {
                    step.discussionsCount? -= 1
                }
                CoreDataHelper.shared.save()
            }.catch { _ in
                seal.reject(Error.stepDiscussionsDecrementFailed)
            }
        }
    }

    func fetchCachedStep(stepID: Step.IdType) -> Guarantee<Step?> {
        Guarantee { seal in
            self.stepsPersistenceService.fetch(id: stepID).done { step in
                seal(step)
            }.catch { _ in
                seal(nil)
            }
        }
    }

    enum Error: Swift.Error {
        case fetchFailed
        case commentDeleteFailed
        case voteUpdateFailed
        case stepDiscussionsIncrementFailed
        case stepDiscussionsDecrementFailed
    }
}
