import UIKit

protocol WishlistWidgetViewControllerProtocol: AnyObject {
    func displayWishlist(viewModel: WishlistWidget.WishlistLoad.ViewModel)
    func displayFullscreenCourseList(viewModel: WishlistWidget.FullscreenCourseListModulePresentation.ViewModel)
}

final class WishlistWidgetViewController: UIViewController {
    private let interactor: WishlistWidgetInteractorProtocol
    private let analytics: Analytics

    var wishlistWidgetView: WishlistWidgetView? { self.view as? WishlistWidgetView }

    private var state: WishlistWidget.ViewControllerState

    init(
        interactor: WishlistWidgetInteractorProtocol,
        analytics: Analytics,
        initialState: WishlistWidget.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.analytics = analytics
        self.state = initialState

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = WishlistWidgetView(frame: UIScreen.main.bounds)
        self.view = view
        view.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateState(newState: self.state)
    }

    private func updateState(newState: WishlistWidget.ViewControllerState) {
        switch newState {
        case .loading:
            self.wishlistWidgetView?.showLoading()
        case .result(let viewModel):
            self.wishlistWidgetView?.hideLoading()
            self.wishlistWidgetView?.configure(viewModel: viewModel)
        }

        self.state = newState
    }
}

extension WishlistWidgetViewController: WishlistWidgetViewControllerProtocol {
    func displayWishlist(viewModel: WishlistWidget.WishlistLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayFullscreenCourseList(viewModel: WishlistWidget.FullscreenCourseListModulePresentation.ViewModel) {
        self.analytics.send(.wishlistScreenOpened)

        let assembly = FullscreenCourseListAssembly(
            presentationDescription: .init(title: NSLocalizedString("WishlistWidgetTitle", comment: "")),
            courseListType: WishlistCourseListType(),
            courseViewSource: .wishlist
        )

        self.push(module: assembly.makeModule())
    }
}

extension WishlistWidgetViewController: WishlistWidgetViewDelegate {
    func wishlistWidgetViewDidClick(_ view: WishlistWidgetView) {
        self.interactor.doFullscreenCourseListPresentation(request: .init())
    }
}
