import UIKit

protocol NewProfileSocialProfilesViewControllerProtocol: AnyObject {
    func displaySocialProfiles(viewModel: NewProfileSocialProfiles.SocialProfilesLoad.ViewModel)
}

final class NewProfileSocialProfilesViewController: UIViewController, ControllerWithStepikPlaceholder {
    private let interactor: NewProfileSocialProfilesInteractorProtocol

    var placeholderContainer = StepikPlaceholderControllerContainer()
    var socialProfilesView: NewProfileSocialProfilesView? { self.view as? NewProfileSocialProfilesView }

    private var state: NewProfileSocialProfiles.ViewControllerState

    init(
        interactor: NewProfileSocialProfilesInteractorProtocol,
        initialState: NewProfileSocialProfiles.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewProfileSocialProfilesView(frame: UIScreen.main.bounds)
        self.view = view
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .tryAgain,
                action: { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.updateState(newState: .loading)
                    strongSelf.interactor.doSocialProfilesLoad(request: .init(forceUpdate: true))
                }
            ),
            for: .connectionError
        )

        self.updateState(newState: self.state)
    }

    private func updateState(newState: NewProfileSocialProfiles.ViewControllerState) {
        defer {
            self.state = newState
        }

        if case .loading = newState {
            self.isPlaceholderShown = false
            self.socialProfilesView?.showLoading()
            return
        }

        if case .loading = self.state {
            self.isPlaceholderShown = false
            self.socialProfilesView?.hideLoading()
        }

        switch newState {
        case .result(let viewModel):
            self.isPlaceholderShown = false
            self.socialProfilesView?.configure(viewModel: viewModel)
        case .error:
            self.showPlaceholder(for: .connectionError)
        case .loading:
            break
        }
    }
}

extension NewProfileSocialProfilesViewController: NewProfileSocialProfilesViewControllerProtocol {
    func displaySocialProfiles(viewModel: NewProfileSocialProfiles.SocialProfilesLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }
}

extension NewProfileSocialProfilesViewController: NewProfileSocialProfilesViewDelegate {
    func newProfileSocialProfilesView(_ view: NewProfileSocialProfilesView, didOpenExternalLink url: URL) {
        UIApplication.shared.open(url, options: [:]) { success in
            if !success {
                WebControllerManager.shared.presentWebControllerWithURL(
                    url,
                    inController: self,
                    withKey: .externalLink,
                    allowsSafari: true,
                    backButtonStyle: .done
                )
            }
        }
    }
}
