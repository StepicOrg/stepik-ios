import Foundation
import PromiseKit
import SwiftyJSON

protocol StepicsNetworkServiceProtocol: AnyObject {
    func fetchCurrentUser() -> Promise<User>
}

final class StepicsNetworkService: StepicsNetworkServiceProtocol {
    private let stepicsAPI: StepicsAPI

    init(stepicsAPI: StepicsAPI) {
        self.stepicsAPI = stepicsAPI
    }

    func fetchCurrentUser() -> Promise<User> {
        self.stepicsAPI.retrieveCurrentUser()
    }
}
