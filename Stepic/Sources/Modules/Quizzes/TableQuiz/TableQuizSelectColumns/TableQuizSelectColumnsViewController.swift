import PanModal
import UIKit

protocol TableQuizSelectColumnsViewControllerDelegate: AnyObject {
    func tableQuizSelectColumnsViewController(
        _ controller: TableQuizSelectColumnsViewController,
        didSelectColumn column: TableQuiz.Column
    )
}

final class TableQuizSelectColumnsViewController: PanModalPresentableViewController {
    weak var moduleOutput: TableQuizSelectColumnsOutputProtocol?

    private let row: TableQuiz.Row
    private let columns: [TableQuiz.Column]
    private var selectedColumnsIDs: Set<UniqueIdentifierType>
    private let isMultipleChoice: Bool

    weak var delegate: TableQuizSelectColumnsViewControllerDelegate?

    var tableQuizSelectColumnsView: TableQuizSelectColumnsView? { self.view as? TableQuizSelectColumnsView }

    override var panScrollable: UIScrollView? { self.tableQuizSelectColumnsView?.panScrollable }

    init(
        row: TableQuiz.Row,
        columns: [TableQuiz.Column],
        selectedColumnsIDs: Set<UniqueIdentifierType>,
        isMultipleChoice: Bool
    ) {
        self.row = row
        self.columns = columns
        self.selectedColumnsIDs = selectedColumnsIDs
        self.isMultipleChoice = isMultipleChoice

        super.init()
    }

    override func loadView() {
        let view = TableQuizSelectColumnsView(frame: UIScreen.main.bounds)
        self.view = view
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableQuizSelectColumnsView?.prompt = self.isMultipleChoice
            ? NSLocalizedString("MultipleChoiceTableQuizPrompt", comment: "")
            : NSLocalizedString("SingleChoiceTableQuizPrompt", comment: "")
        self.tableQuizSelectColumnsView?.title = self.row.text
        self.tableQuizSelectColumnsView?.set(columns: self.columns, selectedColumnsIDs: self.selectedColumnsIDs)

        self.panModalSetNeedsLayoutUpdate()
    }
}

extension TableQuizSelectColumnsViewController: TableQuizSelectColumnsViewDelegate {
    func tableQuizSelectColumnsView(
        _ view: TableQuizSelectColumnsView,
        didSelectColumn column: TableQuiz.Column,
        isOn: Bool
    ) {
        if self.isMultipleChoice {
            if isOn {
                self.selectedColumnsIDs.insert(column.uniqueIdentifier)
            } else {
                self.selectedColumnsIDs.remove(column.uniqueIdentifier)
            }
        } else {
            assert(self.selectedColumnsIDs.count <= 1, "Sigle choice")
            self.selectedColumnsIDs.removeAll()

            if isOn {
                self.selectedColumnsIDs.insert(column.uniqueIdentifier)
            }
        }

        self.tableQuizSelectColumnsView?.update(selectedColumnsIDs: self.selectedColumnsIDs)
        self.moduleOutput?.handleSelectedColumnsUpdated(for: self.row, selectedColumnsIDs: self.selectedColumnsIDs)
    }

    func tableQuizSelectColumnsViewDidClickClose(_ view: TableQuizSelectColumnsView) {
        self.dismiss(animated: true)
    }
}
