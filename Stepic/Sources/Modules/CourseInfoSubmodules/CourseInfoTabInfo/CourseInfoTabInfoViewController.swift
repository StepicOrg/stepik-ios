import AVFoundation
import AVKit
import UIKit

protocol CourseInfoTabInfoViewControllerProtocol: class {
    func displayCourseInfo(viewModel: CourseInfoTabInfo.InfoLoad.ViewModel)
}

final class CourseInfoTabInfoViewController: UIViewController {
    private let interactor: CourseInfoTabInfoInteractorProtocol

    private lazy var infoView = self.view as? CourseInfoTabInfoView

    private var state: CourseInfoTabInfo.ViewControllerState {
        didSet {
            self.updateState()
        }
    }

    private var playerVideoBoundsObservation: NSKeyValueObservation?

    @objc private dynamic lazy var playerViewController: AVPlayerViewController = {
        let playerViewController = AVPlayerViewController()
        self.playerVideoBoundsObservation = playerViewController.observe(
            \.videoBounds,
            options: [.old, .new]
        ) { _, change in
            guard let oldValue = change.oldValue,
                  let newValue = change.newValue else {
                return
            }

            if newValue.size.height != oldValue.size.height {
                UIApplication.shared.isStatusBarHidden = false
            }
        }
        return playerViewController
    }()

    // MARK: Init

    init(
        interactor: CourseInfoTabInfoInteractorProtocol,
        initialState: CourseInfoTabInfo.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.playerVideoBoundsObservation = nil
        self.playerViewController.player?.pause()
        self.playerViewController.willMove(toParent: nil)
        self.playerViewController.view.removeFromSuperview()
        self.playerViewController.removeFromParent()
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        self.view = CourseInfoTabInfoView(videoViewDelegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateState()
        self.interactor.doCourseInfoRefresh(request: .init())
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.playerViewController.player?.pause()
    }

    // MARK: Private helpers

    private func updateState() {
        if case .loading = self.state {
            self.infoView?.showLoading()
        } else {
            self.infoView?.hideLoading()
        }
    }
}

// MARK: - CourseInfoTabInfoViewController: CourseInfoTabInfoViewControllerProtocol -

extension CourseInfoTabInfoViewController: CourseInfoTabInfoViewControllerProtocol {
    func displayCourseInfo(viewModel: CourseInfoTabInfo.InfoLoad.ViewModel) {
        self.display(newState: viewModel.state)
    }

    private func display(newState: CourseInfoTabInfo.ViewControllerState) {
        if case .result(let viewModel) = newState {
            self.infoView?.configure(viewModel: viewModel)
        }

        self.state = newState
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
        self.playerViewController.player?.play()
    }
}
