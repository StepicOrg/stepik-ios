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

    private var currentChoices: [Bool]?
    private var currentChoicesFeedback: [String?]?

    private var isQuizTitleVisible = true

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

        let feedbackOptions = self.currentChoicesFeedback ?? Array(repeating: nil, count: dataset.options.count)

        self.presenter.presentReply(
            response: .init(
                isMultipleChoice: dataset.isMultipleChoice,
                choices: zip(dataset.options, zip(choices, feedbackOptions)).map { result in
                    let (text, (isSelected, hint)) = result
                    return NewChoiceQuiz.Choice(text: text, isSelected: isSelected, hint: hint)
                },
                status: self.currentStatus,
                isQuizTitleVisible: self.isQuizTitleVisible
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
            if self.currentDataset?.isMultipleChoice ?? false {
                self.moduleOutput?.update(reply: ChoiceReply(choices: self.currentChoices ?? []))
            }
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

    func update(feedback: SubmissionFeedback?) {
        if let choiceFeedback = feedback as? ChoiceSubmissionFeedback {
            self.currentChoicesFeedback = choiceFeedback.options
        }
    }

    func update(quizTitleVisibility isVisible: Bool) {
        self.isQuizTitleVisible = isVisible
    }
}
