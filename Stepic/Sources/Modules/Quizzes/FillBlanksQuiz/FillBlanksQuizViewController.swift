import Presentr
import UIKit

protocol FillBlanksQuizViewControllerProtocol: AnyObject {
    func displayReply(viewModel: FillBlanksQuiz.ReplyLoad.ViewModel)
}

final class FillBlanksQuizViewController: UIViewController {
    private let interactor: FillBlanksQuizInteractorProtocol

    var fillBlanksQuizView: FillBlanksQuizView? { self.view as? FillBlanksQuizView }

    private var collectionViewAdapter = FillBlanksQuizCollectionViewAdapter()

    init(interactor: FillBlanksQuizInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = FillBlanksQuizView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionViewAdapter.delegate = self
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.fillBlanksQuizView?.invalidateCollectionViewLayout()
    }
}

extension FillBlanksQuizViewController: FillBlanksQuizViewControllerProtocol {
    func displayReply(viewModel: FillBlanksQuiz.ReplyLoad.ViewModel) {
        self.collectionViewAdapter.components = viewModel.data.components
        self.collectionViewAdapter.finalState = viewModel.data.finalState

        self.fillBlanksQuizView?.updateCollectionViewData(
            delegate: self.collectionViewAdapter,
            dataSource: self.collectionViewAdapter
        )
    }
}

extension FillBlanksQuizViewController: FillBlanksQuizCollectionViewAdapterDelegate {
    func fillBlanksQuizCollectionViewAdapter(
        _ adapter: FillBlanksQuizCollectionViewAdapter,
        inputDidChange inputText: String,
        forComponent component: FillBlanksQuiz.Component
    ) {
        guard let index = adapter.components.firstIndex(
            where: { $0.uniqueIdentifier == component.uniqueIdentifier }
        ) else {
            return
        }

        adapter.components[index].blank = inputText
        self.interactor.doBlankUpdate(request: .init(uniqueIdentifier: component.uniqueIdentifier, blank: inputText))

        self.fillBlanksQuizView?.invalidateCollectionViewLayout()
    }

    func fillBlanksQuizCollectionViewAdapter(
        _ adapter: FillBlanksQuizCollectionViewAdapter,
        didSelectComponentAt indexPath: IndexPath
    ) {
        let component = adapter.components[indexPath.row]

        guard component.isBlankFillable && !component.options.isEmpty else {
            return
        }

        let pickerViewController = PickerViewController()
        pickerViewController.data = component.options
        pickerViewController.pickerTitle = NSLocalizedString("FillBlankOptionTitle", comment: "")
        pickerViewController.initialSelectedData = component.blank ?? ""
        pickerViewController.selectedBlock = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            let selectedOption = pickerViewController.selectedData

            strongSelf.interactor.doBlankUpdate(
                request: .init(uniqueIdentifier: component.uniqueIdentifier, blank: selectedOption)
            )

            strongSelf.collectionViewAdapter.components[indexPath.row].blank = selectedOption
            strongSelf.fillBlanksQuizView?.updateCollectionViewData(
                delegate: strongSelf.collectionViewAdapter,
                dataSource: strongSelf.collectionViewAdapter
            )
        }

        let presentr = Presentr(presentationType: .bottomHalf)

        self.customPresentViewController(presentr, viewController: pickerViewController, animated: true)
    }
}
