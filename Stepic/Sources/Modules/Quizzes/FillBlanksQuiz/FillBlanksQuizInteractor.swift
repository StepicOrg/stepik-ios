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
    private var currentFillBlanksFeedback = [UniqueIdentifierType: Bool]()

    private var currentComponentsByUIDs: [UniqueIdentifierType: FillBlanksComponent] {
        guard let currentDataset = self.currentDataset else {
            return [:]
        }

        let componentsMap = currentDataset.components.enumerated()
            .map { (self.getUIDByComponentIndex($0), $1) }

        return Dictionary(uniqueKeysWithValues: componentsMap)
    }
    private var currentBlanksUIDs: [UniqueIdentifierType] {
        self.currentComponentsByUIDs
            .filter { $0.value.componentType.isBlankFillable }
            .keys
            .sorted { self.getIndexByComponentUID($0) < self.getIndexByComponentUID($1) }
    }

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
                uniqueIdentifier: self.getUIDByComponentIndex(index),
                text: component.text,
                options: component.options,
                blank: self.currentBlanks[self.getUIDByComponentIndex(index)],
                isBlankFillable: component.componentType.isBlankFillable,
                isCorrect: self.currentFillBlanksFeedback[self.getUIDByComponentIndex(index)]
            )
        }

        self.presenter.presentReply(response: .init(components: components, status: self.currentStatus))
    }

    private func updateReplyFromCurrentData() {
        let blanks = self.currentBlanks
            .sorted { self.getIndexByComponentUID($0.key) < self.getIndexByComponentUID($1.key) }
            .map { $0.value }
        self.moduleOutput?.update(reply: FillBlanksReply(blanks: blanks))
    }

    private func getUIDByComponentIndex(_ index: Int) -> UniqueIdentifierType { "\(index)" }

    private func getIndexByComponentUID(_ uniqueIdentifier: UniqueIdentifierType) -> Int {
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

    func update(feedback: SubmissionFeedback?) {
        guard let fillBlanksFeedback = feedback as? FillBlanksFeedback else {
            self.currentFillBlanksFeedback = [:]
            return
        }

        for (feedback, uid) in zip(fillBlanksFeedback.blanksCorrectness, self.currentBlanksUIDs) {
            self.currentFillBlanksFeedback[uid] = feedback
        }
    }

    func update(reply: Reply?) {
        defer {
            self.presentNewData()
        }

        guard let reply = reply else {
            self.initBlanks()
            self.updateReplyFromCurrentData()
            return
        }

        self.moduleOutput?.update(reply: reply)

        guard let fillBlanksReply = reply as? FillBlanksReply else {
            fatalError("Unexpected reply type")
        }

        for (blank, uid) in zip(fillBlanksReply.blanks, self.currentBlanksUIDs) {
            self.currentBlanks[uid] = blank
        }
    }

    func update(status: QuizStatus?) {
        self.currentStatus = status
        self.presentNewData()
    }

    // MARK: Private Helpers

    private func initBlanks() {
        self.currentBlanks = [:]
        self.currentBlanksUIDs.forEach { self.currentBlanks[$0] = "" }
    }
}
