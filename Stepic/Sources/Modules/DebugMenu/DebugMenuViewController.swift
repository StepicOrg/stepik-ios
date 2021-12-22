import UIKit

protocol DebugMenuViewControllerProtocol: AnyObject {
    func displayDebugData(viewModel: DebugMenu.DebugDataLoad.ViewModel)
    func displayIAPFinishAllTransactionsResult(viewModel: DebugMenu.IAPFinishAllTransactions.ViewModel)
}

final class DebugMenuViewController: UIViewController {
    var debugMenuView: DebugMenuView? { self.view as? DebugMenuView }

    private let interactor: DebugMenuInteractorProtocol
    private let deepLinkRoutingService = DeepLinkRoutingService()

    private var state: DebugMenu.ViewControllerState
    private var formState = FormState()

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
        case flags
        case iap
        case deepLinking

        var title: String {
            switch self {
            case .fcmToken:
                return "FCM Token"
            case .flex:
                return "FLEX"
            case .flags:
                return "Remote & Local Flags"
            case .iap:
                return "IAP"
            case .deepLinking:
                return "Deep Linking"
            }
        }
    }

    private enum Row: String, UniqueIdentifiable {
        case fcmRegistrationToken
        case flexToggleExplorer
        case flexShowMenu
        case flagsSplitTests
        case flagsRemoteConfig
        case iapFinishAllTransactions
        case iapCreateCoursePaymentDelay
        case deepLinkInput
        case deepLinkOpen

        var uniqueIdentifier: UniqueIdentifierType { self.rawValue }

        var title: String {
            switch self {
            case .flexToggleExplorer:
                return "Toggle Explorer"
            case .flexShowMenu:
                return "Show Menu"
            case .flagsSplitTests:
                return "A/B Groups"
            case .flagsRemoteConfig:
                return "Remote Config"
            case .iapFinishAllTransactions:
                return "Finish All Transactions"
            case .iapCreateCoursePaymentDelay:
                return "Create CoursePayment Delay"
            case .deepLinkOpen:
                return "Open deep link"
            default:
                return ""
            }
        }
    }

    private struct FormState {
        var deepLink = ""
    }
}

extension DebugMenuViewController: DebugMenuViewControllerProtocol {
    func displayDebugData(viewModel: DebugMenu.DebugDataLoad.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayIAPFinishAllTransactionsResult(viewModel: DebugMenu.IAPFinishAllTransactions.ViewModel) {
        let alert = UIAlertController(title: nil, message: viewModel.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: Private Helpers

    private func display(newViewModel viewModel: DebugMenuViewModel) {
        var sections = [SettingsTableSectionViewModel]()

        // Firebase
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

        // FLEX
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

        // Remote and Local Flags
        let flagsSplitTestsCell = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Row.flagsSplitTests.uniqueIdentifier,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Row.flagsSplitTests.title),
                    accessoryType: .disclosureIndicator
                )
            )
        )
        let flagsRemoteConfigCell = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Row.flagsRemoteConfig.uniqueIdentifier,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Row.flagsRemoteConfig.title),
                    accessoryType: .disclosureIndicator
                )
            )
        )
        sections.append(
            .init(
                header: .init(title: Section.flags.title),
                cells: [flagsSplitTestsCell, flagsRemoteConfigCell],
                footer: nil
            )
        )

        // IAP
        let iapFinishAllTransactionsCell = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Row.iapFinishAllTransactions.uniqueIdentifier,
            type: .rightDetail(options: .init(title: .init(text: Row.iapFinishAllTransactions.title)))
        )

        let iapCreateCoursePaymentDelayDetailTitle = viewModel.iapCreateCoursePaymentDelay != nil
            ? "\(viewModel.iapCreateCoursePaymentDelay.require())"
            : "nil"
        let iapCreateCoursePaymentDelayCell = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Row.iapCreateCoursePaymentDelay.uniqueIdentifier,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Row.iapCreateCoursePaymentDelay.title),
                    detailType: .label(text: iapCreateCoursePaymentDelayDetailTitle),
                    accessoryType: .disclosureIndicator
                )
            )
        )
        sections.append(
            .init(
                header: .init(title: Section.iap.title),
                cells: [iapFinishAllTransactionsCell, iapCreateCoursePaymentDelayCell],
                footer: nil
            )
        )

        // Deep Linking
        let deepLinkInputCell = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Row.deepLinkInput.rawValue,
            type: .largeInput(
                options: .init(
                    valueText: self.formState.deepLink,
                    placeholderText: "Enter deep link text",
                    maxLength: nil,
                    autocorrectionType: .no,
                    autocapitalizationType: UITextAutocapitalizationType.none,
                    keyboardType: .URL
                )
            )
        )
        let deepLinkOpenCell = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Row.deepLinkOpen.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(
                        text: Row.deepLinkOpen.title,
                        appearance: .init(textColor: .stepikVioletFixed, textAlignment: .left)
                    ),
                    accessoryType: .none
                )
            )
        )
        sections.append(
            .init(
                header: .init(title: Section.deepLinking.title),
                cells: [deepLinkInputCell, deepLinkOpenCell],
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
        case .flagsSplitTests:
            let viewController = EditSplitTestsAssembly().makeModule()
            self.push(module: viewController)
        case .flagsRemoteConfig:
            let viewController = EditRemoteConfigAssembly().makeModule()
            self.push(module: viewController)
        case .iapFinishAllTransactions:
            self.interactor.doIAPFinishAllTransactions(request: .init())
        case .iapCreateCoursePaymentDelay:
            self.promptForCreateCoursePaymentDelayInput()
        case .deepLinkOpen:
            self.handleOpenDeepLink()
        default:
            break
        }
    }

    func settingsCell(
        elementView: UITextView,
        didReportTextChange text: String,
        identifiedBy uniqueIdentifier: UniqueIdentifierType?
    ) {
        self.handleTextField(uniqueIdentifier: uniqueIdentifier, text: text)
    }

    func settingsCell(
        elementView: UITextField,
        didReportTextChange text: String?,
        identifiedBy uniqueIdentifier: UniqueIdentifierType?
    ) {
        self.handleTextField(uniqueIdentifier: uniqueIdentifier, text: text)
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

    private func handleTextField(uniqueIdentifier: UniqueIdentifierType?, text: String?) {
        guard let id = uniqueIdentifier,
              let row = Row(rawValue: id) else {
            return
        }

        switch row {
        case .deepLinkInput:
            self.formState.deepLink = text ?? ""
        default:
            break
        }
    }

    private func handleOpenDeepLink() {
        if let route = DeepLinkRoute(path: self.formState.deepLink) {
            self.deepLinkRoutingService.route(route).catch { error in
                let alert = UIAlertController(
                    title: "Error",
                    message: "Failed to open deep link \"\(self.formState.deepLink)\" with error \"\(error)\".",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))

                self.present(alert, animated: true)
            }
        } else {
            let alert = UIAlertController(
                title: "Error",
                message: "Failed to open deep link \"\(self.formState.deepLink)\".",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))

            self.present(alert, animated: true)
        }
    }

    private func promptForCreateCoursePaymentDelayInput() {
        let alert = UIAlertController(
            title: "Enter create CoursePayment delay in seconds",
            message: nil,
            preferredStyle: .alert
        )
        alert.addTextField()

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: nil
            )
        )

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.interactor.doIAPUpdateCreateCoursePaymentDelay(request: .init(input: nil))
        }
        alert.addAction(deleteAction)

        if case .result(let data) = self.state,
           let iapCreateCoursePaymentDelay = data.iapCreateCoursePaymentDelay {
            alert.textFields?.first?.text = "\(iapCreateCoursePaymentDelay)"
        }

        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            guard let strongSelf = self,
                  let strongAlert = alert else {
                return
            }

            let input = strongAlert.textFields?.first?.text
            strongSelf.interactor.doIAPUpdateCreateCoursePaymentDelay(request: .init(input: input))
        }
        alert.addAction(saveAction)

        self.present(alert, animated: true)
    }
}
