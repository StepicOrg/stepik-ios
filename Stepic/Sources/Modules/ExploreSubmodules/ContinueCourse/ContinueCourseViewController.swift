import IntentsUI
import UIKit

protocol ContinueCourseViewControllerProtocol: AnyObject {
    func displayLastCourse(viewModel: ContinueCourse.LastCourseLoad.ViewModel)
    func displayTooltip(viewModel: ContinueCourse.TooltipAvailabilityCheck.ViewModel)
    func displaySiriButton(viewModel: ContinueCourse.SiriButtonAvailabilityCheck.ViewModel)
}

final class ContinueCourseViewController: UIViewController {
    private let interactor: ContinueCourseInteractorProtocol
    private var state: ContinueCourse.ViewControllerState {
        didSet {
            self.updateState()
        }
    }

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
        let view = ContinueCourseView(
            frame: UIScreen.main.bounds
        )
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateState()
        self.interactor.doLastCourseRefresh(request: .init())
    }

    private func updateState() {
        if case .loading = self.state {
            self.continueCourseView?.showLoading()
        } else {
            self.continueCourseView?.hideLoading()
        }
    }
}

// MARK: - ContinueCourseViewController: ContinueCourseViewControllerProtocol -

extension ContinueCourseViewController: ContinueCourseViewControllerProtocol {
    func displayLastCourse(viewModel: ContinueCourse.LastCourseLoad.ViewModel) {
        if case .result(let result) = viewModel.state {
            self.continueCourseView?.configure(viewModel: result)
            self.interactor.doTooltipAvailabilityCheck(request: .init())
            self.interactor.doSiriButtonAvailabilityCheck(request: .init())
        }

        self.state = viewModel.state
    }

    func displayTooltip(viewModel: ContinueCourse.TooltipAvailabilityCheck.ViewModel) {
        guard let continueCourseView = self.continueCourseView else {
            return
        }

        if viewModel.shouldShowTooltip {
            // Cause anchor should be in true position
            DispatchQueue.main.async { [weak self] in
                continueCourseView.setNeedsLayout()
                continueCourseView.layoutIfNeeded()
                self?.continueLearningTooltip.show(
                    direction: .up,
                    in: continueCourseView,
                    from: continueCourseView.tooltipAnchorView
                )
            }
        }
    }

    func displaySiriButton(viewModel: ContinueCourse.SiriButtonAvailabilityCheck.ViewModel) {
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

// MARK: - ContinueCourseViewController: ContinueCourseViewDelegate -

extension ContinueCourseViewController: ContinueCourseViewDelegate {
    func continueCourseContinueButtonDidClick(_ continueCourseView: ContinueCourseView) {
        self.interactor.doContinueLastCourseAction(request: .init())
    }

    func continueCourseSiriButtonDidClick(_ continueCourseView: ContinueCourseView) {
        self.interactor.doSiriButtonAction(request: .init())
    }
}

// MARK: - ContinueCourseViewController: UIViewController, INUIAddVoiceShortcutButtonDelegate -

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
