import IntentsUI
import UIKit

protocol ContinueCourseViewControllerProtocol: AnyObject {
    func displayLastCourse(viewModel: ContinueCourse.LastCourseLoad.ViewModel)
    func displayTooltip(viewModel: ContinueCourse.TooltipAvailabilityCheck.ViewModel)
    func displaySiriButton(viewModel: ContinueCourse.SiriButtonAvailabilityCheck.ViewModel)
}

final class ContinueCourseViewController: UIViewController {
    private let interactor: ContinueCourseInteractorProtocol
    private var state: ContinueCourse.ViewControllerState

    lazy var continueCourseView = self.view as? ContinueCourseView
    private lazy var continueLearningTooltip = TooltipFactory.continueLearningWidget

    init(
        interactor: ContinueCourseInteractorProtocol,
        initialState: ContinueCourse.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        let view = ContinueCourseView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateState(newState: self.state)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.interactor.doLastCourseRefresh(request: .init())
    }

    private func updateState(newState: ContinueCourse.ViewControllerState) {
        defer {
            self.state = newState
        }

        self.continueCourseView?.hideLoading()
        self.continueCourseView?.hideEmpty()

        switch newState {
        case .loading:
            self.continueCourseView?.showLoading()
        case .empty:
            self.continueCourseView?.showEmpty()
        case .result(let viewModel):
            self.continueCourseView?.configure(viewModel: viewModel)
            self.interactor.doTooltipAvailabilityCheck(request: .init())
            self.interactor.doSiriButtonAvailabilityCheck(request: .init())
        }
    }
}

// MARK: - ContinueCourseViewController: ContinueCourseViewControllerProtocol -

extension ContinueCourseViewController: ContinueCourseViewControllerProtocol {
    func displayLastCourse(viewModel: ContinueCourse.LastCourseLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayTooltip(viewModel: ContinueCourse.TooltipAvailabilityCheck.ViewModel) {
        guard let continueCourseView = self.continueCourseView,
              let parentView = self.parent?.view else {
            return
        }

        if viewModel.shouldShowTooltip {
            // Cause anchor should be in true position
            DispatchQueue.main.async { [weak self] in
                continueCourseView.setNeedsLayout()
                continueCourseView.layoutIfNeeded()
                self?.continueLearningTooltip.show(
                    direction: .down,
                    in: parentView,
                    from: continueCourseView.tooltipAnchorView
                )
            }
        }
    }

    func displaySiriButton(viewModel: ContinueCourse.SiriButtonAvailabilityCheck.ViewModel) {
        if #available(iOS 12.0, *) {
            if viewModel.shouldShowButton, let userActivity = viewModel.userActivity {
                let contentConfiguration = SiriButtonContentConfiguration(
                    shortcut: INShortcut(userActivity: userActivity),
                    delegate: self
                )
                self.continueCourseView?.configureSiriButton(contentConfiguration: contentConfiguration)
            } else {
                self.continueCourseView?.configureSiriButton(contentConfiguration: nil)
            }
        }
    }
}

// MARK: - ContinueCourseViewController: ContinueCourseViewDelegate -

extension ContinueCourseViewController: ContinueCourseViewDelegate {
    func continueCourseDidClickContinue(_ continueCourseView: ContinueCourseView) {
        self.interactor.doContinueLastCourseAction(request: .init())
    }

    func continueCourseDidClickEmpty(_ continueCourseView: ContinueCourseView) {
        self.interactor.doContinueCourseEmptyAction(request: .init())
    }

    func continueCourseSiriButtonDidClick(_ continueCourseView: ContinueCourseView) {
        self.interactor.doSiriButtonAction(request: .init())
    }
}

// MARK: - ContinueCourseViewController: UIViewController, INUIAddVoiceShortcutButtonDelegate -

@available(iOS 12.0, *)
extension ContinueCourseViewController: INUIAddVoiceShortcutButtonDelegate {
    func present(
        _ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController,
        for addVoiceShortcutButton: INUIAddVoiceShortcutButton
    ) {
        addVoiceShortcutViewController.delegate = self
        self.present(addVoiceShortcutViewController, animated: true)
    }

    func present(
        _ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController,
        for addVoiceShortcutButton: INUIAddVoiceShortcutButton
    ) {
        editVoiceShortcutViewController.delegate = self
        present(editVoiceShortcutViewController, animated: true)
    }
}

// MARK: - ContinueCourseViewController: INUIAddVoiceShortcutViewControllerDelegate -

@available(iOS 12.0, *)
extension ContinueCourseViewController: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(
        _ controller: INUIAddVoiceShortcutViewController,
        didFinishWith voiceShortcut: INVoiceShortcut?,
        error: Error?
    ) {
        print("ContinueCourseViewController :: error adding voice shortcut \(String(describing: error))")
        controller.dismiss(animated: true)
    }

    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true)
    }
}

// MARK: - ContinueCourseViewController: INUIEditVoiceShortcutViewControllerDelegate -

@available(iOS 12.0, *)
extension ContinueCourseViewController: INUIEditVoiceShortcutViewControllerDelegate {
    func editVoiceShortcutViewController(
        _ controller: INUIEditVoiceShortcutViewController,
        didUpdate voiceShortcut: INVoiceShortcut?,
        error: Error?
    ) {
        print("ContinueCourseViewController :: Error editing voice shortcut \(String(describing: error))")
        controller.dismiss(animated: true)
    }

    func editVoiceShortcutViewController(
        _ controller: INUIEditVoiceShortcutViewController,
        didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID
    ) {
        controller.dismiss(animated: true)
    }

    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true)
    }
}
