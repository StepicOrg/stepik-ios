import Foundation
import PromiseKit

protocol NewCodeQuizInteractorProtocol {
    func doReplyUpdate(request: NewCodeQuiz.ReplyConvert.Request)
}

final class NewCodeQuizInteractor: NewCodeQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: NewCodeQuizPresenterProtocol

    private var currentCode: String?
    private var currentLanguage: String?
    private var currentOptions: StepOptions?

    init(presenter: NewCodeQuizPresenterProtocol) {
        self.presenter = presenter
    }

    func doReplyUpdate(request: NewCodeQuiz.ReplyConvert.Request) {
        self.currentCode = request.code
        self.currentLanguage = request.language

        let reply = CodeReply(code: request.code, languageName: request.language)
        self.moduleOutput?.update(reply: reply)
    }

    private func presentNewData() {
        guard let options = self.currentOptions else {
            return
        }

        let codeLimit: NewCodeQuiz.CodeLimit = {
            if let currentLanguage = self.currentLanguage,
               let codeLanguage = CodeLanguage(rawValue: currentLanguage),
               let limit = options.limit(language: codeLanguage) {
                return .init(time: limit.time, memory: limit.memory)
            }
            return .init(time: options.executionTimeLimit, memory: options.executionMemoryLimit)
        }()

        self.presenter.presentReply(
            response: .init(
                samples: options.samples.map { NewCodeQuiz.CodeSample(input: $0.input, output: $0.output) },
                limit: codeLimit,
                languages: options.languages.map { $0.displayName }.sorted()
            )
        )
    }
}

extension NewCodeQuizInteractor: QuizInputProtocol {
    func update(reply: Reply?) {
        defer {
            self.presentNewData()
        }

        guard let reply = reply else {
            return
        }

        self.moduleOutput?.update(reply: reply)

        if let reply = reply as? CodeReply {
            self.currentCode = reply.code
            self.currentLanguage = reply.languageName
            return
        }

        fatalError("Unexpected reply type")
    }

    func update(status: QuizStatus?) {
        print("status :: \(status)")
    }

    func update(dataset: Dataset?) {
        guard let dataset = dataset else {
            return
        }
        print("dataset :: \(dataset)")
    }

    func update(feedback: SubmissionFeedback?) {
        print("feedback: \(feedback)")
    }

    func update(options: StepOptions?) {
        self.currentOptions = options
        print("options :: \(options)")
    }
}
