import Foundation
import PromiseKit

protocol WriteCommentProviderProtocol {
    func create(comment: Comment) -> Promise<Comment>
    func update(comment: Comment) -> Promise<Comment>
}

final class WriteCommentProvider: WriteCommentProviderProtocol {
    private let commentsNetworkService: CommentsNetworkServiceProtocol
    private let stepsNetworkService: StepsNetworkServiceProtocol
    private let stepsPersistenceService: StepsPersistenceServiceProtocol

    init(
        commentsNetworkService: CommentsNetworkServiceProtocol,
        stepsNetworkService: StepsNetworkServiceProtocol,
        stepsPersistenceService: StepsPersistenceServiceProtocol
    ) {
        self.commentsNetworkService = commentsNetworkService
        self.stepsNetworkService = stepsNetworkService
        self.stepsPersistenceService = stepsPersistenceService
    }

    func create(comment: Comment) -> Promise<Comment> {
        Promise { seal in
            firstly {
                self.fetchStep(id: comment.targetID)
            }.then { step in
                self.commentsNetworkService.create(comment: comment, blockName: step?.block.name)
            }.done { comment in
                seal.fulfill(comment)
            }.catch { _ in
                seal.reject(Error.networkCreateFailed)
            }
        }
    }

    func update(comment: Comment) -> Promise<Comment> {
        Promise { seal in
            firstly {
                self.fetchStep(id: comment.targetID)
            }.then { step in
                self.commentsNetworkService.update(comment: comment, blockName: step?.block.name)
            }.done { comment in
                seal.fulfill(comment)
            }.catch { _ in
                seal.reject(Error.networkUpdateFailed)
            }
        }
    }

    private func fetchStep(id: Step.IdType) -> Guarantee<Step?> {
        Guarantee { seal in
            firstly {
                self.stepsPersistenceService.fetch(ids: [id])
            }.then { cachedSteps -> Promise<[Step]> in
                if cachedSteps.first != nil {
                    return .value(cachedSteps)
                }
                return self.stepsNetworkService.fetch(ids: [id])
            }.done { steps in
                seal(steps.first)
            }.catch { _ in
                seal(nil)
            }
        }
    }

    enum Error: Swift.Error {
        case networkCreateFailed
        case networkUpdateFailed
    }
}
