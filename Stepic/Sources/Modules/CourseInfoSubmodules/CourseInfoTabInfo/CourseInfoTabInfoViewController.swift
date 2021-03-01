import AVFoundation
import AVKit
import UIKit

protocol CourseInfoTabInfoViewControllerProtocol: AnyObject {
    func displayCourseInfo(viewModel: CourseInfoTabInfo.InfoLoad.ViewModel)
    func displayCourseInfoDidAppear(viewModel: CourseInfoTabInfo.ControllerAppearance.ViewModel)
}

final class CourseInfoTabInfoViewController: UIViewController {
    private let interactor: CourseInfoTabInfoInteractorProtocol
    private let analytics: Analytics

    private lazy var infoView = self.view as? CourseInfoTabInfoView
    private lazy var playerViewController = AVPlayerViewController()

    private var state: CourseInfoTabInfo.ViewControllerState

    // MARK: Init

    init(
        interactor: CourseInfoTabInfoInteractorProtocol,
        analytics: Analytics,
        initialState: CourseInfoTabInfo.ViewControllerState = .loading
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

    deinit {
        self.playerViewController.player?.pause()
        self.playerViewController.willMove(toParent: nil)
        self.playerViewController.view.removeFromSuperview()
        self.playerViewController.removeFromParent()
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        self.view = CourseInfoTabInfoView(delegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateState(newState: self.state)
        self.interactor.doCourseInfoRefresh(request: .init())
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.playerViewController.player?.pause()
    }

    // MARK: Private helpers

    private func updateState(newState: CourseInfoTabInfo.ViewControllerState) {
        switch newState {
        case .loading:
            self.infoView?.showLoading()
        case .result(let data):
            self.infoView?.hideLoading()
            self.infoView?.configure(viewModel: data)
        }

        self.state = newState
    }
}

// MARK: - CourseInfoTabInfoViewController: CourseInfoTabInfoViewControllerProtocol -

extension CourseInfoTabInfoViewController: CourseInfoTabInfoViewControllerProtocol {
    func displayCourseInfo(viewModel: CourseInfoTabInfo.InfoLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayCourseInfoDidAppear(viewModel: CourseInfoTabInfo.ControllerAppearance.ViewModel) {
        switch self.state {
        case .loading:
            self.updateState(newState: .loading)
        default:
            break
        }
    }
}

// MARK: - CourseInfoTabInfoViewController: CourseInfoTabInfoIntroVideoBlockViewDelegate -

extension CourseInfoTabInfoViewController: CourseInfoTabInfoIntroVideoBlockViewDelegate {
    func courseInfoTabInfoIntroVideoBlockViewRequestsVideoView(
        _ courseInfoTabInfoIntroVideoBlockView: CourseInfoTabInfoIntroVideoBlockView
    ) -> UIView {
        self.addChild(self.playerViewController)
        return self.playerViewController.view
    }

    func courseInfoTabInfoIntroVideoBlockViewDidAddVideoView(
        _ courseInfoTabInfoIntroVideoBlockView: CourseInfoTabInfoIntroVideoBlockView
    ) {
        self.playerViewController.didMove(toParent: self)
    }

    func courseInfoTabInfoIntroVideoBlockViewDidReceiveVideoURL(
        _ courseInfoTabInfoIntroVideoBlockView: CourseInfoTabInfoIntroVideoBlockView,
        url: URL
    ) {
        if self.playerViewController.player == nil {
            self.playerViewController.player = AVPlayer(url: url)
        }
    }

    func courseInfoTabInfoIntroVideoBlockViewPlayClicked(
        _ courseInfoTabInfoIntroVideoBlockView: CourseInfoTabInfoIntroVideoBlockView
    ) {
        self.analytics.send(.courseDetailVideoTapped)
        self.playerViewController.player?.play()
    }
}

// MARK: - CourseInfoTabInfoViewController: CourseInfoTabInfoViewDelegate -

extension CourseInfoTabInfoViewController: CourseInfoTabInfoViewDelegate {
    func courseInfoTabInfoViewDidLoadContent(_ view: CourseInfoTabInfoView) {}

    func courseInfoTabInfoView(_ view: CourseInfoTabInfoView, didOpenURL url: URL) {
        if let deepLinkRoute = DeepLinkRoute(path: url.absoluteString) {
            DeepLinkRoutingService().route(deepLinkRoute, fallbackPath: url.absoluteString, from: self)
        } else {
            WebControllerManager.shared.presentWebControllerWithURL(
                url,
                inController: self,
                withKey: .externalLink,
                allowsSafari: true,
                backButtonStyle: .done
            )
        }
    }

    func courseInfoTabInfoView(_ view: CourseInfoTabInfoView, didOpenImageURL url: URL) {
        FullscreenImageViewer.show(url: url, from: self)
    }

    func courseInfoTabInfoView(_ view: CourseInfoTabInfoView, didOpenImage image: UIImage) {
        FullscreenImageViewer.show(image: image, from: self)
    }

    func courseInfoTabInfoView(_ view: CourseInfoTabInfoView, didOpenUserProfileWithID userID: User.IdType) {
        let assembly = NewProfileAssembly(otherUserID: userID)
        self.push(module: assembly.makeModule())
    }
}
