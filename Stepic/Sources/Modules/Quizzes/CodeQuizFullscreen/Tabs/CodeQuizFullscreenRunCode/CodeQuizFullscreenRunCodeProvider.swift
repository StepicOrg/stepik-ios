import Foundation
import PromiseKit

protocol CodeQuizFullscreenRunCodeProviderProtocol {
    func fetchUserCodeRun(id: UserCodeRun.IdType) -> Promise<UserCodeRun>
    func runCode(
        stepID: Step.IdType,
        languageString: String,
        code: String,
        stdin: String
    ) -> Promise<UserCodeRun>
}

final class CodeQuizFullscreenRunCodeProvider: CodeQuizFullscreenRunCodeProviderProtocol {
    private let userCodeRunsNetworkService: UserCodeRunsNetworkServiceProtocol
    private let userAccountService: UserAccountServiceProtocol

    init(
        userCodeRunsNetworkService: UserCodeRunsNetworkServiceProtocol,
        userAccountService: UserAccountServiceProtocol
    ) {
        self.userCodeRunsNetworkService = userCodeRunsNetworkService
        self.userAccountService = userAccountService
    }

    func fetchUserCodeRun(id: UserCodeRun.IdType) -> Promise<UserCodeRun> {
        self.userCodeRunsNetworkService.fetch(id: id)
    }

    func runCode(stepID: Step.IdType, languageString: String, code: String, stdin: String) -> Promise<UserCodeRun> {
        guard let userID = self.userAccountService.currentUser?.id else {
            return .init(error: Error.noUser)
        }

        return self.userCodeRunsNetworkService.create(
            userID: userID,
            stepID: stepID,
            languageString: languageString,
            code: code,
            stdin: stdin
        )
    }

    enum Error: Swift.Error {
        case noUser
    }
}
