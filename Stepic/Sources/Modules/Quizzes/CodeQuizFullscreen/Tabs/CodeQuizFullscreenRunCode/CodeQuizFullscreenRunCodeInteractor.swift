import Foundation
import Logging
import PromiseKit

protocol CodeQuizFullscreenRunCodeInteractorProtocol {
    func doTestInputTextUpdate(request: CodeQuizFullscreenRunCode.TestInputTextUpdate.Request)
    func doRunCode(request: CodeQuizFullscreenRunCode.RunCode.Request)
    func doTestInputSamplesPresentation(request: CodeQuizFullscreenRunCode.TestInputSamplesPresentation.Request)
}

final class CodeQuizFullscreenRunCodeInteractor: CodeQuizFullscreenRunCodeInteractorProtocol {
    private static let logger = Logger(label: "com.AlexKarpov.Stepic.CodeQuizFullscreenRunCodeInteractor")
    private static let pollInterval: TimeInterval = 1.0

    weak var moduleOutput: CodeQuizFullscreenRunCodeOutputProtocol?

    private let stepID: Step.IdType
    private let language: CodeLanguage

    private let presenter: CodeQuizFullscreenRunCodePresenterProtocol
    private let provider: CodeQuizFullscreenRunCodeProviderProtocol

    private var currentUserCodeRun: UserCodeRun
    private var currentSamples: [CodeSamplePlainObject] = []

    private var isSetDefaultTestInput: Bool = false

    init(
        stepID: Step.IdType,
        language: CodeLanguage,
        presenter: CodeQuizFullscreenRunCodePresenterProtocol,
        provider: CodeQuizFullscreenRunCodeProviderProtocol
    ) {
        self.stepID = stepID
        self.language = language
        self.presenter = presenter
        self.provider = provider
        self.currentUserCodeRun = UserCodeRun(
            userID: -1,
            stepID: self.stepID,
            languageString: self.language.rawValue,
            code: "",
            stdin: ""
        )
    }

    // MARK: Protocol Conforming

    func doTestInputTextUpdate(request: CodeQuizFullscreenRunCode.TestInputTextUpdate.Request) {
        self.currentUserCodeRun.stdin = request.input
        self.presentUserCodeRun()
    }

    func doRunCode(request: CodeQuizFullscreenRunCode.RunCode.Request) {
        if self.currentUserCodeRun.status == .evaluation {
            return
        }

        Self.logger.info("CodeQuizFullscreenRunCodeInteractor :: running user code \(self.currentUserCodeRun)")
        self.currentUserCodeRun.status = .evaluation
        self.presentUserCodeRun()

        firstly {
            self.provider.runCode(
                stepID: self.currentUserCodeRun.stepID,
                languageString: self.currentUserCodeRun.languageString,
                code: self.currentUserCodeRun.code,
                stdin: self.currentUserCodeRun.stdin ?? ""
            )
        }.then { userCodeRun -> Promise<UserCodeRun> in
            Self.logger.info("CodeQuizFullscreenRunCodeInteractor :: user code run created \(userCodeRun)")

            self.currentUserCodeRun = userCodeRun
            self.presentUserCodeRun()

            Self.logger.info("CodeQuizFullscreenRunCodeInteractor :: polling user code run \(userCodeRun.id)...")

            return self.pollUserCodeRun(id: userCodeRun.id)
        }.done { userCodeRun in
            Self.logger.info("CodeQuizFullscreenRunCodeInteractor :: done polling user code run \(userCodeRun)")

            self.currentUserCodeRun = userCodeRun
            self.presenter.presentRunCodeResult(
                response: .init(
                    result: .success(
                        .init(userCodeRun: self.currentUserCodeRun, samples: self.currentSamples)
                    )
                )
            )
        }.catch { error in
            Self.logger.error("CodeQuizFullscreenRunCodeInteractor :: error while running user code \(error)")
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
                    Self.logger.error(
                        "CodeQuizFullscreenRunCodeInteractor :: error while polling user code run \(error)"
                    )
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
}

// MARK: - CodeQuizFullscreenRunCodeInteractor: CodeQuizFullscreenRunCodeInputProtocol -

extension CodeQuizFullscreenRunCodeInteractor: CodeQuizFullscreenRunCodeInputProtocol {
    func update(code: String) {
        self.currentUserCodeRun.code = code
        self.presentUserCodeRun()
    }

    func update(samples: [CodeSamplePlainObject]) {
        self.currentSamples = samples
        self.setDefaultTestInputIfNeeded()
        self.presentUserCodeRun()
    }
}
