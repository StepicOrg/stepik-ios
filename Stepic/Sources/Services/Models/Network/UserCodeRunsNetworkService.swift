import Foundation
import PromiseKit

protocol UserCodeRunsNetworkServiceProtocol: AnyObject {
    func fetch(id: UserCodeRun.IdType) -> Promise<UserCodeRun>
    func create(
        userID: User.IdType,
        stepID: Step.IdType,
        languageString: String,
        code: String,
        stdin: String
    ) -> Promise<UserCodeRun>
}

final class UserCodeRunsNetworkService: UserCodeRunsNetworkServiceProtocol {
    private let userCodeRunsAPI: UserCodeRunsAPI

    init(userCodeRunsAPI: UserCodeRunsAPI) {
        self.userCodeRunsAPI = userCodeRunsAPI
    }

    func fetch(id: UserCodeRun.IdType) -> Promise<UserCodeRun> {
        self.userCodeRunsAPI.retrieve(id: id)
    }

    func create(
        userID: User.IdType,
        stepID: Step.IdType,
        languageString: String,
        code: String,
        stdin: String
    ) -> Promise<UserCodeRun> {
        self.userCodeRunsAPI.create(
            userID: userID,
            stepID: stepID,
            languageString: languageString,
            code: code,
            stdin: stdin
        )
    }
}
