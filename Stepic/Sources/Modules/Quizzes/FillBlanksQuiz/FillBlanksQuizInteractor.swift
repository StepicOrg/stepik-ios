import Foundation
import PromiseKit

protocol FillBlanksQuizInteractorProtocol {
    func doReplyUpdate(request: FillBlanksQuiz.ReplyConvert.Request)
}

final class FillBlanksQuizInteractor: FillBlanksQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: FillBlanksQuizPresenterProtocol

    private var currentStatus: QuizStatus?
    private var currentDataset: FillBlanksDataset?

    private var currentBlanks = [String]()

    init(presenter: FillBlanksQuizPresenterProtocol) {
        self.presenter = presenter
    }

    func doReplyUpdate(request: FillBlanksQuiz.ReplyConvert.Request) {
        self.currentBlanks = request.blanks

        let reply = FillBlanksReply(blanks: request.blanks)
        self.moduleOutput?.update(reply: reply)
    }

    private func presentNewData() {
        guard let currentDataset = self.currentDataset else {
            return
        }

        var components = [FillBlanksQuiz.Component]()
        var blankIndex = 0

        for component in currentDataset.components {
            let blank = component.componentType.isBlankFillable ? self.currentBlanks[safe: blankIndex] : nil
            blankIndex += 1

            components.append(
                .init(
                    text: component.text,
                    options: component.options,
                    blank: blank,
                    isBlankFillable: component.componentType.isBlankFillable
                )
            )
        }

        self.presenter.presentReply(
            response: .init(
                components: components,
                status: self.currentStatus
            )
        )
    }
}

extension FillBlanksQuizInteractor: QuizInputProtocol {
    func update(reply: Reply?) {
        defer {
            self.presentNewData()
        }

        guard let reply = reply else {
            self.currentBlanks = []
            return
        }

        self.moduleOutput?.update(reply: reply)

        guard let fillBlanksReply = reply as? FillBlanksReply else {
            fatalError("Unexpected reply type")
        }

        self.currentBlanks = fillBlanksReply.blanks
    }

    func update(status: QuizStatus?) {
        self.currentStatus = status
        self.presentNewData()
    }

    func update(dataset: Dataset?) {
        guard let fillBlanksDataset = dataset as? FillBlanksDataset else {
            return
        }

        self.currentDataset = fillBlanksDataset
        self.currentBlanks = []
    }

    func update(feedback: SubmissionFeedback?) {
        print(#function)
        print(feedback)
    }

    func update(quizTitleVisibility isVisible: Bool) {
        print(#function)
    }
}
