import Foundation
import PromiseKit

protocol CodeQuizFullscreenRunCodeInteractorProtocol {
}

final class CodeQuizFullscreenRunCodeInteractor: CodeQuizFullscreenRunCodeInteractorProtocol {
    weak var moduleOutput: CodeQuizFullscreenRunCodeOutputProtocol?

    private let stepID: Step.IdType
    private let language: CodeLanguage

    private let presenter: CodeQuizFullscreenRunCodePresenterProtocol
    private let provider: CodeQuizFullscreenRunCodeProviderProtocol

    private var currentCode: String = ""
    private var currentSamples: [CodeSamplePlainObject] = []
    private var currentTestInput: String?

    private var isSetDefaultSample: Bool = false

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

    // MARK: Private API

    private func setDefaultSampleInputIfNeeded() {
        guard !self.isSetDefaultSample, let sample = self.currentSamples.first else {
            return
        }

        self.isSetDefaultSample = true
        self.currentTestInput = sample.input

        self.presenter.presentSampleInput(response: .init(input: sample.input))
    }
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
