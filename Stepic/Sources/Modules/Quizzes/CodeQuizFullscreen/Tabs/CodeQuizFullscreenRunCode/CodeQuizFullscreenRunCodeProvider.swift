import Foundation
import PromiseKit

protocol CodeQuizFullscreenRunCodeProviderProtocol {
    func fetchUserCodeRun(id: UserCodeRun.IdType) -> Promise<UserCodeRun>
    func runCode(
        userID: User.IdType,
        stepID: Step.IdType,
        languageString: String,
        code: String,
        stdin: String
    ) -> Promise<UserCodeRun>
}

final class CodeQuizFullscreenRunCodeProvider: CodeQuizFullscreenRunCodeProviderProtocol {
    private let userCodeRunsNetworkService: UserCodeRunsNetworkServiceProtocol

    init(userCodeRunsNetworkService: UserCodeRunsNetworkServiceProtocol) {
        self.userCodeRunsNetworkService = userCodeRunsNetworkService
    }

    func fetchUserCodeRun(id: UserCodeRun.IdType) -> Promise<UserCodeRun> {
        self.userCodeRunsNetworkService.fetch(id: id)
    }

    func runCode(
        userID: User.IdType,
        stepID: Step.IdType,
        languageString: String,
        code: String,
        stdin: String
    ) -> Promise<UserCodeRun> {
        self.userCodeRunsNetworkService.create(
            userID: userID,
            stepID: stepID,
            languageString: languageString,
            code: code,
            stdin: stdin
        )
    }
}
