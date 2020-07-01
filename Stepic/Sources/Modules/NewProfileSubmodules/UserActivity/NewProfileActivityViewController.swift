import UIKit

protocol NewProfileUserActivityViewControllerProtocol: AnyObject {
    func displayUserActivity(viewModel: NewProfileUserActivity.ActivityLoad.ViewModel)
}

final class NewProfileUserActivityViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: NewProfileUserActivityInteractorProtocol

    var placeholderContainer = StepikPlaceholderControllerContainer()
    var newProfileUserActivityView: NewProfileUserActivityView? { self.view as? NewProfileUserActivityView }

    init(interactor: NewProfileUserActivityInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewProfileUserActivityView(frame: UIScreen.main.bounds)
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

    private func updateState(newState: NewProfileUserActivity.ViewControllerState) {
        switch newState {
        case .error:
            self.showPlaceholder(for: .connectionError)
        case .result(data: let viewModel):
            self.isPlaceholderShown = false
            self.newProfileUserActivityView?.configure(viewModel: viewModel)
        }
    }
}

extension NewProfileUserActivityViewController: NewProfileUserActivityViewControllerProtocol {
    func displayUserActivity(viewModel: NewProfileUserActivity.ActivityLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }
}
