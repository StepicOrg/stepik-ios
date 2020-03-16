import Foundation
import PromiseKit

protocol CodeQuizFullscreenRunCodeInteractorProtocol {
    func doTestInputTextUpdate(request: CodeQuizFullscreenRunCode.TestInputTextUpdate.Request)
    func doRunCode(request: CodeQuizFullscreenRunCode.RunCode.Request)
    func doTestInputSamplesPresentation(request: CodeQuizFullscreenRunCode.TestInputSamplesPresentation.Request)
}

final class CodeQuizFullscreenRunCodeInteractor: CodeQuizFullscreenRunCodeInteractorProtocol {
    private static let pollInterval: TimeInterval = 1.0
    private static let invalidUserID: User.IdType = -1

    private let stepID: Step.IdType
    private let language: CodeLanguage

    private let presenter: CodeQuizFullscreenRunCodePresenterProtocol
    private let provider: CodeQuizFullscreenRunCodeProviderProtocol
    private let userAccountService: UserAccountServiceProtocol

    private var currentUserCodeRun: UserCodeRun
    private var currentSamples: [CodeSamplePlainObject] = []

    private var isSetDefaultTestInput: Bool = false

    init(
        stepID: Step.IdType,
        language: CodeLanguage,
        presenter: CodeQuizFullscreenRunCodePresenterProtocol,
        provider: CodeQuizFullscreenRunCodeProviderProtocol,
        userAccountService: UserAccountServiceProtocol
    ) {
        self.stepID = stepID
        self.language = language
        self.presenter = presenter
        self.provider = provider
        self.userAccountService = userAccountService
        self.currentUserCodeRun = UserCodeRun(
            userID: userAccountService.currentUser?.id ?? Self.invalidUserID,
            stepID: self.stepID,
            languageString: self.language.rawValue,
            code: "",
            stdin: ""
        )
    }

    // MARK: Protocol Conforming

    func doTestInputTextUpdate(request: CodeQuizFullscreenRunCode.TestInputTextUpdate.Request) {
        if self.currentUserCodeRun.stdin != request.input {
            self.currentUserCodeRun.stdin = request.input
            self.currentUserCodeRun.status = nil
            self.presentUserCodeRun()
        }
    }

    func doRunCode(request: CodeQuizFullscreenRunCode.RunCode.Request) {
        guard self.currentUserCodeRun.userID != Self.invalidUserID else {
            return self.presenter.presentRunCodeResult(response: .init(result: .failure(Error.invalidUserID)))
        }

        guard self.currentUserCodeRun.status != .evaluation else {
            return
        }

        print("CodeQuizFullscreenRunCodeInteractor :: running user code \(self.currentUserCodeRun)")
        self.currentUserCodeRun.status = .evaluation
        self.presentUserCodeRun()

        // FIXME: analytics dependency
        AmplitudeAnalyticsEvents.RunCode.launched(stepID: self.stepID).send()

        firstly {
            self.provider.runCode(
                userID: self.currentUserCodeRun.userID,
                stepID: self.currentUserCodeRun.stepID,
                languageString: self.currentUserCodeRun.languageString,
                code: self.currentUserCodeRun.code,
                stdin: self.currentUserCodeRun.stdin ?? ""
            )
        }.then { userCodeRun -> Promise<UserCodeRun> in
            print("CodeQuizFullscreenRunCodeInteractor :: user code run created \(userCodeRun)")

            self.currentUserCodeRun = userCodeRun
            self.presentUserCodeRun()

            print("CodeQuizFullscreenRunCodeInteractor :: polling user code run \(userCodeRun.id)...")

            return self.pollUserCodeRun(id: userCodeRun.id)
        }.done { userCodeRun in
            print("CodeQuizFullscreenRunCodeInteractor :: done polling user code run \(userCodeRun)")

            self.currentUserCodeRun = userCodeRun
            self.presenter.presentRunCodeResult(
                response: .init(
                    result: .success(
                        .init(userCodeRun: self.currentUserCodeRun, samples: self.currentSamples)
                    )
                )
            )
        }.catch { error in
            print("CodeQuizFullscreenRunCodeInteractor :: error while running user code \(error)")
            self.presenter.presentRunCodeResult(response: .init(result: .failure(error)))
            self.currentUserCodeRun.status = nil
            self.presentUserCodeRun()
        }
    }

    func doTestInputSamplesPresentation(request: CodeQuizFullscreenRunCode.TestInputSamplesPresentation.Request) {
        self.presenter.presentTestInputSamples(response: .init(samples: self.currentSamples))
    }

    // MARK: Private API

    private func pollUserCodeRun(id: UserCodeRun.IdType) -> Promise<UserCodeRun> {
        Promise { seal in
            func poll(retryCount: Int) {
                after(seconds: TimeInterval(retryCount) * Self.pollInterval).then { _ -> Promise<UserCodeRun> in
                    self.provider.fetchUserCodeRun(id: id)
                }.done { userCodeRun in
                    if userCodeRun.status == .evaluation {
                        poll(retryCount: retryCount + 1)
                    } else {
                        seal.fulfill(userCodeRun)
                    }
                }.catch { error in
                    print("CodeQuizFullscreenRunCodeInteractor :: error while polling user code run \(error)")
                    seal.reject(error)
                }
            }

            poll(retryCount: 1)
        }
    }

    private func presentUserCodeRun() {
        self.presenter.presentContentUpdate(
            response: .init(data: .init(userCodeRun: self.currentUserCodeRun, samples: self.currentSamples))
        )
    }

    private func setDefaultTestInputIfNeeded() {
        guard !self.isSetDefaultTestInput, let sample = self.currentSamples.first else {
            return
        }

        self.isSetDefaultTestInput = true
        self.currentUserCodeRun.stdin = sample.input

        self.presenter.presentTestInputSetDefault(response: .init(input: sample.input))
    }

    // MARK: Inner Types

    enum Error: Swift.Error {
        case invalidUserID
    }
}

// MARK: - CodeQuizFullscreenRunCodeInteractor: CodeQuizFullscreenRunCodeInputProtocol -

extension CodeQuizFullscreenRunCodeInteractor: CodeQuizFullscreenRunCodeInputProtocol {
    func update(code: String) {
        self.currentUserCodeRun.code = code
        self.currentUserCodeRun.status = nil
        self.presentUserCodeRun()
    }

    func update(samples: [CodeSamplePlainObject]) {
        self.currentSamples = samples
        self.setDefaultTestInputIfNeeded()
        self.presentUserCodeRun()
    }
}
