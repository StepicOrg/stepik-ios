import Foundation
import PromiseKit

protocol CodeQuizFullscreenRunCodeInteractorProtocol {
    func doSomeAction(request: CodeQuizFullscreenRunCode.SomeAction.Request)
}

final class CodeQuizFullscreenRunCodeInteractor: CodeQuizFullscreenRunCodeInteractorProtocol {
    weak var moduleOutput: CodeQuizFullscreenRunCodeOutputProtocol?

    private let stepID: Step.IdType
    private let language: CodeLanguage

    private let presenter: CodeQuizFullscreenRunCodePresenterProtocol
    private let provider: CodeQuizFullscreenRunCodeProviderProtocol

    private var currentCode: String = ""
    private var currentSamples: [CodeSamplePlainObject] = []
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
    }

    func doSomeAction(request: CodeQuizFullscreenRunCode.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
}

// MARK: - CodeQuizFullscreenRunCodeInteractor: CodeQuizFullscreenRunCodeInputProtocol -

extension CodeQuizFullscreenRunCodeInteractor: CodeQuizFullscreenRunCodeInputProtocol {
    func update(code: String) {
        self.currentCode = code
    }

    func update(samples: [CodeSamplePlainObject]) {
        self.currentSamples = samples
        self.setDefaultSampleInputIfNeeded()
    }
}
