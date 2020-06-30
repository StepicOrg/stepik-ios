import UIKit

protocol NewProfileActivityViewControllerProtocol: AnyObject {
    func displayUserActivity(viewModel: NewProfileActivity.ActivityLoad.ViewModel)
}

final class NewProfileActivityViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: NewProfileActivityInteractorProtocol

    var placeholderContainer = StepikPlaceholderControllerContainer()
    var newProfileActivityView: NewProfileActivityView? { self.view as? NewProfileActivityView }

    init(interactor: NewProfileActivityInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewProfileActivityView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .tryAgain,
                action: { [weak self] in
                    self?.interactor.doUserActivityFetch(request: .init())
                }
            ),
            for: .connectionError
        )
    }

    private func updateState(newState: NewProfileActivity.ViewControllerState) {
        switch newState {
        case .error:
            self.showPlaceholder(for: .connectionError)
        case .result(data: let viewModel):
            self.isPlaceholderShown = false
            self.newProfileActivityView?.configure(viewModel: viewModel)
        }
    }
}

extension NewProfileActivityViewController: NewProfileActivityViewControllerProtocol {
    func displayUserActivity(viewModel: NewProfileActivity.ActivityLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }
}
