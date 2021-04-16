import UIKit

protocol DebugMenuViewControllerProtocol: AnyObject {
    func displayDebugData(viewModel: DebugMenu.DebugDataLoad.ViewModel)
}

final class DebugMenuViewController: UIViewController {
    var debugMenuView: DebugMenuView? { self.view as? DebugMenuView }

    private let interactor: DebugMenuInteractorProtocol
    private var state: DebugMenu.ViewControllerState

    init(
        interactor: DebugMenuInteractorProtocol,
        initialState state: DebugMenu.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = state

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = DebugMenuView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Debug"
        self.updateState(newState: self.state)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.interactor.doDebugDataLoad(request: .init())
    }

    // MARK: Private API

    private func updateState(newState: DebugMenu.ViewControllerState) {
        defer {
            self.state = newState
        }

        switch newState {
        case .loading:
            self.debugMenuView?.startLoading()
        case .result(let data):
            self.debugMenuView?.endLoading()
            self.display(newViewModel: data)
        }
    }

    // MARK: Types

    private enum Section {
        case fcmToken
        case flex

        var title: String {
            switch self {
            case .fcmToken:
                return "FCM Token"
            case .flex:
                return "FLEX"
            }
        }
    }

    private enum Row: String, UniqueIdentifiable {
        case fcmRegistrationToken
        case flexToggleExplorer
        case flexShowMenu

        var uniqueIdentifier: UniqueIdentifierType { self.rawValue }

        var title: String {
            switch self {
            case .flexToggleExplorer:
                return "Toggle Explorer"
            case .flexShowMenu:
                return "Show Menu"
            default:
                return ""
            }
        }
    }
}

extension DebugMenuViewController: DebugMenuViewControllerProtocol {
    func displayDebugData(viewModel: DebugMenu.DebugDataLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    // MARK: Private Helpers

    private func display(newViewModel viewModel: DebugMenuViewModel) {
        var sections = [SettingsTableSectionViewModel]()

        let fcmTokenCell = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Row.fcmRegistrationToken.uniqueIdentifier,
            type: .rightDetail(
                options: .init(
                    title: .init(text: viewModel.fcmRegistrationToken),
                    accessoryType: .disclosureIndicator
                )
            )
        )
        sections.append(.init(header: .init(title: Section.fcmToken.title), cells: [fcmTokenCell], footer: nil))

        let flexToggleExplorerCell = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Row.flexToggleExplorer.uniqueIdentifier,
            type: .rightDetail(options: .init(title: .init(text: Row.flexToggleExplorer.title)))
        )
        let flexShowMenuCell = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Row.flexShowMenu.uniqueIdentifier,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Row.flexShowMenu.title),
                    accessoryType: .disclosureIndicator
                )
            )
        )
        sections.append(
            .init(
                header: .init(title: Section.flex.title),
                cells: [flexToggleExplorerCell, flexShowMenuCell],
                footer: nil
            )
        )

        self.debugMenuView?.configure(viewModel: SettingsTableViewModel(sections: sections))
    }
}

extension DebugMenuViewController: DebugMenuViewDelegate {
    func settingsTableViewRefreshControlDidRefresh(_ tableView: SettingsTableView) {
        self.interactor.doDebugDataLoad(request: .init())
    }

    func settingsTableView(
        _ tableView: SettingsTableView,
        didSelectCell cell: SettingsTableSectionViewModel.Cell,
        at indexPath: IndexPath
    ) {
        guard case .result(let data) = self.state,
              let selectedRow = Row(rawValue: cell.uniqueIdentifier) else {
            return
        }

        let sourceView = tableView.cellForRow(at: indexPath) ?? tableView

        switch selectedRow {
        case .fcmRegistrationToken:
            self.shareContent(activityItems: [data.fcmRegistrationToken], sourceView: sourceView)
        case .flexShowMenu:
            if let menuViewController = FLEXManager.makeMenuViewController() {
                self.push(module: menuViewController)
            }
        case .flexToggleExplorer:
            FLEXManager.toggleExplorer()
        }
    }

    // MARK: Private Helpers

    private func shareContent(activityItems: [Any], sourceView: UIView) {
        let activityViewController = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )

        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = sourceView.bounds
        }

        self.present(module: activityViewController)
    }
}
