import Foundation
import PromiseKit

protocol SubmissionsProviderProtocol {
    func fetchSubmissions(stepID: Step.IdType, page: Int) -> Promise<([Submission], Meta)>
    func fetchAttempts(ids: [Attempt.IdType], stepID: Step.IdType) -> Promise<[Attempt]>
    func fetchCurrentUser() -> Guarantee<User?>
}

final class SubmissionsProvider: SubmissionsProviderProtocol {
    private let submissionsNetworkService: SubmissionsNetworkServiceProtocol
    private let attemptsNetworkService: AttemptsNetworkServiceProtocol
    private let userAccountService: UserAccountServiceProtocol
    private let stepsNetworkService: StepsNetworkServiceProtocol
    private let stepsPersistenceService: StepsPersistenceServiceProtocol

    init(
        submissionsNetworkService: SubmissionsNetworkServiceProtocol,
        attemptsNetworkService: AttemptsNetworkServiceProtocol,
        userAccountService: UserAccountServiceProtocol,
        stepsNetworkService: StepsNetworkServiceProtocol,
        stepsPersistenceService: StepsPersistenceServiceProtocol
    ) {
        self.submissionsNetworkService = submissionsNetworkService
        self.attemptsNetworkService = attemptsNetworkService
        self.userAccountService = userAccountService
        self.stepsNetworkService = stepsNetworkService
        self.stepsPersistenceService = stepsPersistenceService
    }

    // MARK: Protocol Conforming

    func fetchSubmissions(stepID: Step.IdType, page: Int) -> Promise<([Submission], Meta)> {
        Promise { seal in
            firstly {
                self.fetchCurrentUser()
            }.then { currentUser -> Promise<User> in
                guard let currentUser = currentUser else {
                    throw Error.fetchFailed
                }

                return .value(currentUser)
            }.then { currentUser -> Promise<(User, Step?)> in
                self.fetchStep(id: stepID).map { (currentUser, $0) }
            }.then { currentUser, step -> Promise<([Submission], Meta)> in
                guard let step = step else {
                    throw Error.fetchFailed
                }

                return self.submissionsNetworkService.fetch(
                    stepID: step.id,
                    blockName: step.block.name,
                    userID: currentUser.id,
                    page: page
                )
            }.done { fetchResult in
                seal.fulfill((fetchResult.0, fetchResult.1))
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchAttempts(ids: [Attempt.IdType], stepID: Step.IdType) -> Promise<[Attempt]> {
        Promise { seal in
            firstly {
                self.fetchStep(id: stepID)
            }.then { step -> Promise<([Attempt], Meta)> in
                guard let step = step else {
                    throw Error.fetchFailed
                }

                return self.attemptsNetworkService.fetch(ids: ids, blockName: step.block.name)
            }.done { attempts, _ in
                seal.fulfill(attempts)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    func fetchCurrentUser() -> Guarantee<User?> {
        Guarantee { seal in
            seal(self.userAccountService.currentUser)
        }
    }

    // MARK: Private API

    private func fetchStep(id: Step.IdType) -> Promise<Step?> {
        Promise { seal in
            firstly {
                self.stepsPersistenceService.fetch(ids: [id])
            }.then { cachedSteps -> Promise<[Step]> in
                if !cachedSteps.isEmpty {
                    return .value(cachedSteps)
                }
                return self.stepsNetworkService.fetch(ids: [id])
            }.done { steps in
                seal.fulfill(steps.first)
            }.catch { _ in
                seal.reject(Error.fetchFailed)
            }
        }
    }

    // MARK: Types

    enum Error: Swift.Error {
        case noUser
        case fetchFailed
    }
}
