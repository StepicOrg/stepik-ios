import PanModal
import UIKit

protocol TableQuizSelectColumnsViewControllerDelegate: AnyObject {
    func tableQuizSelectColumnsViewController(
        _ controller: TableQuizSelectColumnsViewController,
        didSelectColumn column: TableQuiz.Column
    )
}

final class TableQuizSelectColumnsViewController: UIViewController {
    private let columns: [TableQuiz.Column]
    private var selectedColumnsIDs: Set<UniqueIdentifierType>
    private let isMultipleChoice: Bool

    weak var delegate: TableQuizSelectColumnsViewControllerDelegate?

    var tableQuizSelectColumnsView: TableQuizSelectColumnsView? { self.view as? TableQuizSelectColumnsView }

    init(
        columns: [TableQuiz.Column],
        selectedColumnsIDs: Set<UniqueIdentifierType>,
        isMultipleChoice: Bool
    ) {
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
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    private func setupView() {
        self.tableQuizSelectColumnsView?.set(columns: self.columns, selectedColumnsIDs: self.selectedColumnsIDs)
    }
}

extension TableQuizSelectColumnsViewController: PanModalPresentable {
    var panScrollable: UIScrollView? { nil }

//    var shortFormHeight: PanModalHeight {
//        return isShortFormEnabled ? .contentHeight(300.0) : longFormHeight
//    }
//
//    var scrollIndicatorInsets: UIEdgeInsets {
//        let bottomOffset = presentingViewController?.bottomLayoutGuide.length ?? 0
//        return UIEdgeInsets(top: headerView.frame.size.height, left: 0, bottom: bottomOffset, right: 0)
//    }
//
//    var anchorModalToLongForm: Bool {
//        return false
//    }
//
//    func shouldPrioritize(panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
//        let location = panModalGestureRecognizer.location(in: view)
//        return headerView.frame.contains(location)
//    }
//
//    func willTransition(to state: PanModalPresentationController.PresentationState) {
//        guard isShortFormEnabled, case .longForm = state
//        else { return }
//
//        isShortFormEnabled = false
//        panModalSetNeedsLayoutUpdate()
//    }
}
