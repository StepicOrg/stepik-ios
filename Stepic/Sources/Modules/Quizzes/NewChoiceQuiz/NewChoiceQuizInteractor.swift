import Foundation
import PromiseKit

protocol NewChoiceQuizInteractorProtocol {
    func doReplyUpdate(request: NewChoiceQuiz.ReplyConvert.Request)
}

final class NewChoiceQuizInteractor: NewChoiceQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: NewChoiceQuizPresenterProtocol

    private var currentStatus: QuizStatus?
    private var currentDataset: ChoiceDataset?
    // swiftlint:disable:next discouraged_optional_collection
    private var currentChoices: [Bool]?

    init(presenter: NewChoiceQuizPresenterProtocol) {
        self.presenter = presenter
    }

    func doReplyUpdate(request: NewChoiceQuiz.ReplyConvert.Request) {
        self.currentChoices = request.choices

        let reply = ChoiceReply(choices: request.choices)
        self.moduleOutput?.update(reply: reply)
    }

    private func presentNewData() {
        guard let dataset = self.currentDataset else {
            return
        }

        guard let choices = self.currentChoices else {
            return
        }

        self.presenter.presentReply(
            response: .init(
                isMultipleChoice: dataset.isMultipleChoice,
                choices: zip(dataset.options, choices).map {
                    NewChoiceQuiz.Choice(text: $0, isSelected: $1, hint: nil)
                },
                status: self.currentStatus
            )
        )
    }
}

extension NewChoiceQuizInteractor: QuizInputProtocol {
    func update(reply: Reply?) {
        defer {
            self.presentNewData()
        }
        
        guard let reply = reply else {
            self.currentChoices = Array(repeating: false, count: self.currentDataset?.options.count ?? 0)
            return
        }

        self.moduleOutput?.update(reply: reply)

        if let reply = reply as? ChoiceReply {
            self.currentChoices = reply.choices
            return
        }

        fatalError("Unexpected reply type")
    }

    func update(status: QuizStatus?) {
        self.currentStatus = status
        self.presentNewData()
    }

    func update(dataset: Dataset?) {
        guard let dataset = dataset as? ChoiceDataset else {
            return
        }

        self.currentDataset = dataset
        self.currentChoices = Array(repeating: false, count: dataset.options.count)
    }
}
