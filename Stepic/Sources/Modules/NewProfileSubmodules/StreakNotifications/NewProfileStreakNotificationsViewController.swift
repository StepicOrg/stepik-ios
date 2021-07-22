import Presentr
import UIKit

protocol NewProfileStreakNotificationsViewControllerProtocol: AnyObject {
    func displayStreakNotifications(viewModel: NewProfileStreakNotifications.StreakNotificationsLoad.ViewModel)
    func displaySelectStreakNotificationsTime(
        viewModel: NewProfileStreakNotifications.SelectStreakNotificationsTimePresentation.ViewModel
    )
    func displayTooltip(viewModel: NewProfileStreakNotifications.TooltipAvailabilityCheck.ViewModel)
}

final class NewProfileStreakNotificationsViewController: UIViewController {
    private let interactor: NewProfileStreakNotificationsInteractorProtocol

    var newProfileStreakNotificationsView: NewProfileStreakNotificationsView? {
        self.view as? NewProfileStreakNotificationsView
    }
    private lazy var streaksTooltip = TooltipFactory.streaksTooltip

    init(interactor: NewProfileStreakNotificationsInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewProfileStreakNotificationsView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactor.doStreakNotificationsLoad(request: .init())
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.streaksTooltip.dismiss()
    }
}

extension NewProfileStreakNotificationsViewController: NewProfileStreakNotificationsViewControllerProtocol {
    func displayStreakNotifications(viewModel: NewProfileStreakNotifications.StreakNotificationsLoad.ViewModel) {
        self.newProfileStreakNotificationsView?.configure(viewModel: viewModel.viewModel)
        self.interactor.doTooltipAvailabilityCheck(request: .init())
    }

    func displaySelectStreakNotificationsTime(
        viewModel: NewProfileStreakNotifications.SelectStreakNotificationsTimePresentation.ViewModel
    ) {
        let viewController = NotificationTimePickerViewController(
            nibName: "PickerViewController", bundle: nil
        ) as NotificationTimePickerViewController
        viewController.startHour = viewModel.startHour
        viewController.selectedBlock = { [weak self] in
            self?.interactor.doStreakNotificationsLoad(request: .init())
        }

        let presentr = Presentr(presentationType: .bottomHalf)
        self.customPresentViewController(presentr, viewController: viewController, animated: true, completion: nil)
    }

    func displayTooltip(viewModel: NewProfileStreakNotifications.TooltipAvailabilityCheck.ViewModel) {
        guard viewModel.shouldShowTooltip else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self,
                  let streakNotificationsView = strongSelf.newProfileStreakNotificationsView else {
                return
            }

            // Cause anchor should be in true position
            streakNotificationsView.setNeedsLayout()
            streakNotificationsView.layoutIfNeeded()

            strongSelf.streaksTooltip.show(
                direction: .up,
                in: streakNotificationsView.superview ?? streakNotificationsView,
                from: streakNotificationsView.streakNotificationsSwitchTooltipAnchorView
            )
        }
    }
}

extension NewProfileStreakNotificationsViewController: NewProfileStreakNotificationsViewDelegate {
    func newProfileStreakNotificationsView(
        _ view: NewProfileStreakNotificationsView,
        didChangeStreakNotificationsPreference isOn: Bool
    ) {
        self.streaksTooltip.dismiss()
        self.interactor.doStreakNotificationsPreferenceUpdate(request: .init(isOn: isOn))
    }

    func newProfileStreakNotificationsViewDidTouchChangeNotificationsTime(_ view: NewProfileStreakNotificationsView) {
        self.interactor.doSelectStreakNotificationsTimePresentation(request: .init())
    }
}
