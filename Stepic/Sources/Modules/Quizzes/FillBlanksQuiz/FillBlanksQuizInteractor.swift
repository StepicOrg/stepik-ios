import Foundation
import PromiseKit

protocol FillBlanksQuizInteractorProtocol {
    func doBlankUpdate(request: FillBlanksQuiz.BlankUpdate.Request)
}

final class FillBlanksQuizInteractor: FillBlanksQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: FillBlanksQuizPresenterProtocol

    private var currentStatus: QuizStatus?
    private var currentDataset: FillBlanksDataset?

    private var currentBlanks = [UniqueIdentifierType: String]()

    init(presenter: FillBlanksQuizPresenterProtocol) {
        self.presenter = presenter
    }

    func doBlankUpdate(request: FillBlanksQuiz.BlankUpdate.Request) {
        self.currentBlanks[request.uniqueIdentifier] = request.blank
        self.updateReplyFromCurrentData()
    }

    // MARK: Private API

    private func presentNewData() {
        guard let currentDataset = self.currentDataset else {
            return
        }

        let components = currentDataset.components.enumerated().map { index, component -> FillBlanksQuiz.Component in
            .init(
                uniqueIdentifier: self.getUniqueIdentifierByComponentIndex(index),
                text: component.text,
                options: component.options,
                blank: self.currentBlanks[self.getUniqueIdentifierByComponentIndex(index)],
                isBlankFillable: component.componentType.isBlankFillable
            )
        }

        self.presenter.presentReply(response: .init(components: components, status: self.currentStatus))
    }

    private func updateReplyFromCurrentData() {
        let blanks = self.currentBlanks.sorted {
            self.getIndexByComponentUniqueIdentifier($0.key) < self.getIndexByComponentUniqueIdentifier($1.key)
        }.map { $0.value }

        self.moduleOutput?.update(reply: FillBlanksReply(blanks: blanks))
    }

    private func getUniqueIdentifierByComponentIndex(_ index: Int) -> UniqueIdentifierType { "\(index)" }

    private func getIndexByComponentUniqueIdentifier(_ uniqueIdentifier: UniqueIdentifierType) -> Int {
        Int(uniqueIdentifier).require()
    }
}

extension FillBlanksQuizInteractor: QuizInputProtocol {
    func update(dataset: Dataset?) {
        guard let fillBlanksDataset = dataset as? FillBlanksDataset else {
            return
        }

        self.currentDataset = fillBlanksDataset
        self.initBlanks()
    }

    func update(feedback: SubmissionFeedback?) {}

    func update(reply: Reply?) {
        defer {
            self.presentNewData()
        }

        guard let reply = reply else {
            return self.initBlanks()
        }

        self.moduleOutput?.update(reply: reply)

        guard let fillBlanksReply = reply as? FillBlanksReply else {
            fatalError("Unexpected reply type")
        }

        guard let currentDataset = self.currentDataset else {
            return
        }

        var blankIndex = 0

        for (index, component) in currentDataset.components.enumerated() where component.componentType.isBlankFillable {
            let blank = fillBlanksReply.blanks[safe: blankIndex] ?? ""
            self.currentBlanks[self.getUniqueIdentifierByComponentIndex(index)] = blank
            blankIndex += 1
        }
    }

    func update(status: QuizStatus?) {
        self.currentStatus = status
        self.presentNewData()
    }

    // MARK: Private Helpers

    private func initBlanks() {
        self.currentBlanks = [:]

        guard let currentDataset = self.currentDataset else {
            return
        }

        for (index, component) in currentDataset.components.enumerated() where component.componentType.isBlankFillable {
            self.currentBlanks[self.getUniqueIdentifierByComponentIndex(index)] = ""
        }
    }
}
