import PanModal
import UIKit

protocol TableQuizSelectColumnsViewControllerDelegate: AnyObject {
    func tableQuizSelectColumnsViewController(
        _ controller: TableQuizSelectColumnsViewController,
        didSelectColumn column: TableQuiz.Column
    )
}

final class TableQuizSelectColumnsViewController: UIViewController {
    private let row: TableQuiz.Row
    private let columns: [TableQuiz.Column]
    private var selectedColumnsIDs: Set<UniqueIdentifierType>
    private let isMultipleChoice: Bool

    weak var delegate: TableQuizSelectColumnsViewControllerDelegate?

    var tableQuizSelectColumnsView: TableQuizSelectColumnsView? { self.view as? TableQuizSelectColumnsView }

    private var isShortFormEnabled = true

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

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = TableQuizSelectColumnsView(frame: UIScreen.main.bounds)
        self.view = view
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    private func setupView() {
        self.tableQuizSelectColumnsView?.prompt = self.isMultipleChoice
            ? NSLocalizedString("MultipleChoiceTableQuizPrompt", comment: "")
            : NSLocalizedString("SingleChoiceTableQuizPrompt", comment: "")
        self.tableQuizSelectColumnsView?.title = self.row.text
        self.tableQuizSelectColumnsView?.set(columns: self.columns, selectedColumnsIDs: self.selectedColumnsIDs)
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
    }
}

extension TableQuizSelectColumnsViewController: PanModalPresentable {
    var panScrollable: UIScrollView? { nil }

    var shortFormHeight: PanModalHeight {
        self.isShortFormEnabled
            ? .contentHeight(floor(UIScreen.main.bounds.height / 3))
            : self.longFormHeight
    }

    var anchorModalToLongForm: Bool { false }

    func willTransition(to state: PanModalPresentationController.PresentationState) {
        guard self.isShortFormEnabled, case .longForm = state else {
            return
        }

        self.isShortFormEnabled = false
        self.panModalSetNeedsLayoutUpdate()
    }
}
