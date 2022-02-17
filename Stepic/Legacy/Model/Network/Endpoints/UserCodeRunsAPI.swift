import Alamofire
import Foundation
import PromiseKit
import SwiftyJSON

final class UserCodeRunsAPI: APIEndpoint {
    override class var name: String { "user-code-runs" }

    func retrieve(id: UserCodeRun.IdType) -> Promise<UserCodeRun> {
        self.retrieve.request(requestEndpoint: Self.name, paramName: Self.name, id: id, withManager: self.manager)
    }

    func create(
        userID: User.IdType,
        stepID: Step.IdType,
        languageString: String,
        code: String,
        stdin: String
    ) -> Promise<UserCodeRun> {
        let userCodeRun = UserCodeRun(
            userID: userID,
            stepID: stepID,
            languageString: languageString,
            code: code,
            stdin: stdin
        )

        return self.create.request(
            requestEndpoint: Self.name,
            paramName: Self.name,
            creatingObject: userCodeRun,
            withManager: self.manager
        )
    }
}
