import UIKit

final class TableQuizSelectColumnsAssembly: Assembly {
    private let columns: [TableQuiz.Column]
    private var selectedColumnsIDs: Set<UniqueIdentifierType>
    private let isMultipleChoice: Bool

    init(
        columns: [TableQuiz.Column],
        selectedColumnsIDs: Set<UniqueIdentifierType>,
        isMultipleChoice: Bool
    ) {
        self.columns = columns
        self.selectedColumnsIDs = selectedColumnsIDs
        self.isMultipleChoice = isMultipleChoice
    }

    func makeModule() -> UIViewController {
        let viewController = TableQuizSelectColumnsViewController(
            columns: self.columns,
            selectedColumnsIDs: self.selectedColumnsIDs,
            isMultipleChoice: self.isMultipleChoice
        )
        return viewController
    }
}
