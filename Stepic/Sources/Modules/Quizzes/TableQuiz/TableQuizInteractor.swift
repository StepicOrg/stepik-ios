import Foundation
import PromiseKit

protocol TableQuizInteractorProtocol {}

final class TableQuizInteractor: TableQuizInteractorProtocol {
    weak var moduleOutput: QuizOutputProtocol?

    private let presenter: TableQuizPresenterProtocol

    private var currentStatus: QuizStatus?
    private var currentDataset: TableDataset?
    private var currentRows = [TableQuiz.Row]()

    init(presenter: TableQuizPresenterProtocol) {
        self.presenter = presenter
    }

    // MARK: Private API

    private func presentNewData() {
        guard let currentDataset = self.currentDataset else {
            return
        }

        self.presenter.presentReply(
            response: .init(
                rows: self.currentRows,
                columns: currentDataset.columns.map {
                    TableQuiz.Column(text: $0, uniqueIdentifier: self.getUniqueIdentifierByColumn($0))
                },
                isMultipleChoice: currentDataset.isCheckbox,
                status: self.currentStatus
            )
        )
    }

    private func updateReplyFromCurrentData() {
        guard let currentDataset = self.currentDataset else {
            return
        }

        let choices = self.currentRows.map { row in
            TableReplyChoice(
                rowName: row.text,
                columns: currentDataset.columns.map { column in
                    TableReplyChoice.Column(
                        name: column,
                        answer: row.answers.contains(where: { $0.text == column })
                    )
                }
            )
        }
        let reply = TableReply(choices: choices)

        self.moduleOutput?.update(reply: reply)
    }
}

extension TableQuizInteractor: QuizInputProtocol {
    func update(dataset: Dataset?) {
        guard let tableDataset = dataset as? TableDataset else {
            return
        }

        self.currentDataset = tableDataset
        self.initRows()
    }

    func update(reply: Reply?) {
        defer {
            self.presentNewData()
        }

        guard let reply = reply else {
            self.initRows()
            self.updateReplyFromCurrentData()
            return
        }

        self.moduleOutput?.update(reply: reply)

        guard let tableReply = reply as? TableReply else {
            fatalError("Unexpected reply type")
        }

        for choice in tableReply.choices {
            guard let rowIndex = self.currentRows.firstIndex(
                    where: { $0.uniqueIdentifier == self.getUniqueIdentifierByRow(choice.rowName) }
            ) else {
                continue
            }

            var answers = [TableQuiz.Column]()
            for column in choice.columns where column.answer == true {
                answers.append(
                    TableQuiz.Column(
                        text: column.name,
                        uniqueIdentifier: self.getUniqueIdentifierByColumn(column.name)
                    )
                )
            }

            let oldRow = self.currentRows[rowIndex]
            let newRow = TableQuiz.Row(
                text: oldRow.text,
                answers: answers,
                uniqueIdentifier: oldRow.uniqueIdentifier
            )

            self.currentRows[rowIndex] = newRow
        }
    }

    func update(status: QuizStatus?) {
        self.currentStatus = status
        self.presenter.presentQuizStatusUpdateResult(response: .init(status: self.currentStatus))
    }

    // MARK: Private Helpers

    private func initRows() {
        self.currentRows = []

        guard let currentDataset = self.currentDataset else {
            return
        }

        self.currentRows = currentDataset.rows.map { row in
            TableQuiz.Row(text: row, answers: [], uniqueIdentifier: self.getUniqueIdentifierByRow(row))
        }
    }

    private func getUniqueIdentifierByRow(_ row: String) -> UniqueIdentifierType { "\(row.hashValue)" }

    private func getUniqueIdentifierByColumn(_ column: String) -> UniqueIdentifierType { "\(column.hashValue)" }
}

extension TableQuizInteractor: TableQuizSelectColumnsOutputProtocol {
    func handleSelectedColumnsUpdated(for row: TableQuiz.Row, selectedColumnsIDs: Set<UniqueIdentifierType>) {
        guard let currentDataset = self.currentDataset else {
            return
        }

        guard let rowIndex = self.currentRows.firstIndex(where: { $0.uniqueIdentifier == row.uniqueIdentifier }) else {
            return
        }

        let answers = currentDataset.columns
            .filter { selectedColumnsIDs.contains(self.getUniqueIdentifierByColumn($0)) }
            .map { TableQuiz.Column(text: $0, uniqueIdentifier: self.getUniqueIdentifierByColumn($0)) }

        let oldRow = self.currentRows[rowIndex]
        let newRow = TableQuiz.Row(
            text: oldRow.text,
            answers: answers,
            uniqueIdentifier: oldRow.uniqueIdentifier
        )

        self.currentRows[rowIndex] = newRow

        self.updateReplyFromCurrentData()
        self.presenter.presentRowChoiceUpdateResult(response: .init(row: newRow))
    }
}
