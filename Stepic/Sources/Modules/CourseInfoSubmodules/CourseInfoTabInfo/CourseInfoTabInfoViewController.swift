import AVFoundation
import AVKit
import UIKit

protocol CourseInfoTabInfoViewControllerProtocol: AnyObject {
    func displayCourseInfo(viewModel: CourseInfoTabInfo.InfoLoad.ViewModel)
}

final class CourseInfoTabInfoViewController: UIViewController {
    private let interactor: CourseInfoTabInfoInteractorProtocol
    private let analytics: Analytics

    private lazy var infoView = self.view as? CourseInfoTabInfoView

    private var state: CourseInfoTabInfo.ViewControllerState {
        didSet {
            self.updateState()
        }
    }

    private lazy var playerViewController = AVPlayerViewController()

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
        self.analytics.send(.courseDetailVideoTapped)
        self.playerViewController.player?.play()
    }
}

// MARK: - CourseInfoTabInfoViewController: CourseInfoTabInfoViewDelegate -

extension CourseInfoTabInfoViewController: CourseInfoTabInfoViewDelegate {
    func courseInfoTabInfoViewDidClickInstructor(
        _ courseInfoTabInfoView: CourseInfoTabInfoView,
        instructor: CourseInfoTabInfoInstructorViewModel
    ) {
        let assembly = ProfileAssembly(userID: instructor.id)
        self.navigationController?.pushViewController(assembly.makeModule(), animated: true)
    }
}
