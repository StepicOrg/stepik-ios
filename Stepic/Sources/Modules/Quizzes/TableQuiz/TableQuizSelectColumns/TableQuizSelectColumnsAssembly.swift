import UIKit

final class TableQuizSelectColumnsAssembly: Assembly {
    private weak var moduleOutput: TableQuizSelectColumnsOutputProtocol?

    private let row: TableQuiz.Row
    private let columns: [TableQuiz.Column]
    private var selectedColumnsIDs: Set<UniqueIdentifierType>
    private let isMultipleChoice: Bool

    init(
        row: TableQuiz.Row,
        columns: [TableQuiz.Column],
        selectedColumnsIDs: Set<UniqueIdentifierType>,
        isMultipleChoice: Bool,
        output: TableQuizSelectColumnsOutputProtocol? = nil
    ) {
        self.row = row
        self.columns = columns
        self.selectedColumnsIDs = selectedColumnsIDs
        self.isMultipleChoice = isMultipleChoice
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let viewController = TableQuizSelectColumnsViewController(
            row: self.row,
            columns: self.columns,
            selectedColumnsIDs: self.selectedColumnsIDs,
            isMultipleChoice: self.isMultipleChoice
        )
        viewController.moduleOutput = self.moduleOutput
        return viewController
    }
}
