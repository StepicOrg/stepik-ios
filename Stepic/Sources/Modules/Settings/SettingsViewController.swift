import SVProgressHUD
import UIKit

// swiftlint:disable file_length
// MARK: SettingsViewControllerProtocol: AnyObject -

protocol SettingsViewControllerProtocol: AnyObject {
    func displaySettings(viewModel: Settings.SettingsLoad.ViewModel)
    func displayDownloadVideoQualitySetting(viewModel: Settings.DownloadVideoQualitySettingPresentation.ViewModel)
    func displayStreamVideoQualitySetting(viewModel: Settings.StreamVideoQualitySettingPresentation.ViewModel)
    func displayApplicationThemeSetting(viewModel: Settings.ApplicationThemeSettingPresentation.ViewModel)
    func displayContentLanguageSetting(viewModel: Settings.ContentLanguageSettingPresentation.ViewModel)
    func displayStepFontSizeSetting(viewModel: Settings.StepFontSizeSettingPresentation.ViewModel)
    func displayDeleteAllContentResult(viewModel: Settings.DeleteAllContent.ViewModel)
    func displayDeleteUserAccount(viewModel: Settings.DeleteUserAccountPresentation.ViewModel)
    func displayBlockingLoadingIndicator(viewModel: Settings.BlockingWaitingIndicatorUpdate.ViewModel)
    func displayDismiss(viewModel: Settings.DismissPresentation.ViewModel)
}

// MARK: - Appearance -

extension SettingsViewController {
    struct Appearance {
        var navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState = .init()
    }
}

// MARK: - SettingsViewController: UIViewController -

final class SettingsViewController: UIViewController {
    private let interactor: SettingsInteractorProtocol
    private let analytics: Analytics

    let appearance: Appearance

    lazy var settingsView = self.view as? SettingsView

    private lazy var closeBarButtonItem = UIBarButtonItem.stepikCloseBarButtonItem(
        target: self,
        action: #selector(self.closeButtonClicked)
    )

    init(
        interactor: SettingsInteractorProtocol,
        analytics: Analytics,
        appearance: Appearance = .init()
    ) {
        self.interactor = interactor
        self.analytics = analytics
        self.appearance = appearance
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = SettingsView(frame: UIScreen.main.bounds)
        view.delegate = self
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.interactor.doSettingsLoad(request: .init())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.analytics.send(.settingsScreenOpened)
        self.updateNavigationBarAppearance()
    }

    // MARK: Private API

    private func setupNavigationItem() {
        self.title = NSLocalizedString("SettingsTitle", comment: "")
        self.navigationItem.rightBarButtonItem = self.closeBarButtonItem

        if #available(iOS 14.0, *) {
            self.navigationItem.backButtonDisplayMode = .minimal
        } else {
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }

    private func updateNavigationBarAppearance() {
        self.styledNavigationController?.setNeedsNavigationBarAppearanceUpdate(sender: self)
        self.styledNavigationController?.setDefaultNavigationBarAppearance(self.appearance.navigationBarAppearance)
    }

    @objc
    private func closeButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: Inner Types

    private enum Setting: String {
        case downloadQuality
        case streamQuality
        case useCellularDataForDownloads
        case theme
        case textSize
        case codeEditor
        case contentLanguage
        case autoplayNextVideo
        case adaptiveMode
        case downloads
        case deleteAllContent
        case about
        case deleteAccount
        case logOut

        var cellTitle: String {
            switch self {
            case .downloadQuality:
                return NSLocalizedString("SettingsCellTitleDownloadQuality", comment: "")
            case .streamQuality:
                return NSLocalizedString("SettingsCellTitleStreamQuality", comment: "")
            case .theme:
                return NSLocalizedString("SettingsCellTitleTheme", comment: "")
            case .useCellularDataForDownloads:
                return NSLocalizedString("SettingsCellTitleUseCellularDataForDownloads", comment: "")
            case .contentLanguage:
                return NSLocalizedString("SettingsCellTitleContentLanguage", comment: "")
            case .textSize:
                return NSLocalizedString("SettingsCellTitleTextSizeInSteps", comment: "")
            case .codeEditor:
                return NSLocalizedString("SettingsCellTitleCodeEditor", comment: "")
            case .autoplayNextVideo:
                return NSLocalizedString("SettingsCellTitleAutoplayNextVideo", comment: "")
            case .adaptiveMode:
                return NSLocalizedString("SettingsCellTitleAdaptiveMode", comment: "")
            case .downloads:
                return NSLocalizedString("SettingsCellTitleDownloads", comment: "")
            case .deleteAllContent:
                return NSLocalizedString("SettingsCellTitleDeleteAllContent", comment: "")
            case .about:
                return NSLocalizedString("SettingsCellTitleAbout", comment: "")
            case .deleteAccount:
                return NSLocalizedString("SettingsCellTitleDeleteAccount", comment: "")
            case .logOut:
                return NSLocalizedString("SettingsCellTitleLogOut", comment: "")
            }
        }

        init?(uniqueIdentifier: UniqueIdentifierType) {
            if let value = Setting(rawValue: uniqueIdentifier) {
                self = value
            } else {
                return nil
            }
        }
    }
}

// MARK: - SettingsViewController: SettingsViewControllerProtocol -

extension SettingsViewController: SettingsViewControllerProtocol {
    func displaySettings(viewModel: Settings.SettingsLoad.ViewModel) {
        self.updateSettingsViewModel(viewModel.viewModel)
    }

    func displayDownloadVideoQualitySetting(viewModel: Settings.DownloadVideoQualitySettingPresentation.ViewModel) {
        self.displaySelectionList(
            settingDescription: viewModel.settingDescription,
            title: NSLocalizedString("SettingsDownloadVideoQualityTitle", comment: ""),
            footerTitle: NSLocalizedString("SettingsDownloadVideoQualityFooterTitle", comment: ""),
            onSettingSelected: { [weak self] selectedSetting in
                self?.interactor.doDownloadVideoQualitySettingUpdate(request: .init(setting: selectedSetting))
            }
        )
    }

    func displayStreamVideoQualitySetting(viewModel: Settings.StreamVideoQualitySettingPresentation.ViewModel) {
        self.displaySelectionList(
            settingDescription: viewModel.settingDescription,
            title: NSLocalizedString("SettingsStreamVideoQualityTitle", comment: ""),
            footerTitle: NSLocalizedString("SettingsStreamVideoQualityFooterTitle", comment: ""),
            onSettingSelected: { [weak self] selectedSetting in
                self?.interactor.doStreamVideoQualitySettingUpdate(request: .init(setting: selectedSetting))
            }
        )
    }

    func displayApplicationThemeSetting(viewModel: Settings.ApplicationThemeSettingPresentation.ViewModel) {
        self.displaySelectionList(
            settingDescription: viewModel.settingDescription,
            title: NSLocalizedString("SettingsThemeTitle", comment: ""),
            onSettingSelected: { [weak self] selectedSetting in
                guard let strongSelf = self else {
                    return
                }

                DispatchQueue.main.async {
                    strongSelf.interactor.doApplicationThemeSettingUpdate(request: .init(setting: selectedSetting))
                }
            }
        )
    }

    func displayContentLanguageSetting(viewModel: Settings.ContentLanguageSettingPresentation.ViewModel) {
        self.displaySelectionList(
            settingDescription: viewModel.settingDescription,
            title: NSLocalizedString("SettingsContentLanguageTitle", comment: ""),
            footerTitle: NSLocalizedString("SettingsContentLanguageFooterTitle", comment: ""),
            onSettingSelected: { [weak self] selectedSetting in
                self?.interactor.doContentLanguageSettingUpdate(request: .init(setting: selectedSetting))
            }
        )
    }

    func displayStepFontSizeSetting(viewModel: Settings.StepFontSizeSettingPresentation.ViewModel) {
        self.displaySelectionList(
            settingDescription: viewModel.settingDescription,
            title: NSLocalizedString("SettingsStepFontSizeTitle", comment: ""),
            footerTitle: NSLocalizedString("SettingsStepFontSizeFooterTitle", comment: ""),
            onSettingSelected: { [weak self] selectedSetting in
                self?.interactor.doStepFontSizeUpdate(request: .init(setting: selectedSetting))
            }
        )
    }

    func displayDeleteAllContentResult(viewModel: Settings.DeleteAllContent.ViewModel) {
        if viewModel.isSuccessful {
            SVProgressHUD.showSuccess(withStatus: nil)
        } else {
            SVProgressHUD.showError(withStatus: nil)
        }
    }

    func displayDeleteUserAccount(viewModel: Settings.DeleteUserAccountPresentation.ViewModel) {
        WebControllerManager.shared.presentWebControllerWithURL(
            viewModel.url,
            inController: self,
            withKey: .deleteUserAccount,
            allowsSafari: true,
            backButtonStyle: .done
        )
    }

    func displayBlockingLoadingIndicator(viewModel: Settings.BlockingWaitingIndicatorUpdate.ViewModel) {
        if viewModel.shouldDismiss {
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.show()
        }
    }

    func displayDismiss(viewModel: Settings.DismissPresentation.ViewModel) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: Private Helpers

    private func displaySelectionList(
        settingDescription: Settings.SettingDescription,
        title: String? = nil,
        headerTitle: String? = nil,
        footerTitle: String? = nil,
        onSettingSelected: ((Settings.SettingDescription.Setting) -> Void)? = nil
    ) {
        let selectedCellViewModel: SelectItemViewModel.Section.Cell? = {
            if let currentSetting = settingDescription.currentSetting {
                return .init(uniqueIdentifier: currentSetting.uniqueIdentifier, title: currentSetting.title)
            }
            return nil
        }()

        let viewController = SelectItemTableViewController(
            style: .stepikInsetGrouped,
            viewModel: .init(
                sections: [
                    .init(
                        cells: settingDescription.settings.map {
                            .init(uniqueIdentifier: $0.uniqueIdentifier, title: $0.title)
                        },
                        headerTitle: headerTitle,
                        footerTitle: footerTitle
                    )
                ],
                selectedCell: selectedCellViewModel
            ),
            onItemSelected: { selectedCellViewModel in
                let selectedSetting = Settings.SettingDescription.Setting(
                    uniqueIdentifier: selectedCellViewModel.uniqueIdentifier,
                    title: selectedCellViewModel.title
                )
                onSettingSelected?(selectedSetting)
            }
        )

        viewController.title = title

        self.push(module: viewController)
    }

    private func updateSettingsViewModel(_ settingsViewModel: SettingsViewModel) {
        // Video
        let videoDownloadQualityCellViewModel = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.downloadQuality.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.downloadQuality.cellTitle),
                    detailType: .label(text: settingsViewModel.downloadVideoQuality),
                    accessoryType: .disclosureIndicator
                )
            )
        )
        let videoStreamQualityCellViewModel = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.streamQuality.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.streamQuality.cellTitle),
                    detailType: .label(text: settingsViewModel.streamVideoQuality),
                    accessoryType: .disclosureIndicator
                )
            )
        )
        let useCellularDataForDownloadsCellViewModel = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.useCellularDataForDownloads.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.useCellularDataForDownloads.cellTitle),
                    detailType: .switch(.init(isOn: settingsViewModel.shouldUseCellularDataForDownloads)),
                    accessoryType: .none
                )
            )
        )

        // Appearance
        let themeCellViewModel = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.theme.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.theme.cellTitle),
                    detailType: .label(text: settingsViewModel.applicationTheme),
                    accessoryType: .disclosureIndicator
                )
            )
        )
        let stepTextSizeCellViewModel = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.textSize.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.textSize.cellTitle),
                    detailType: .label(text: settingsViewModel.stepFontSize),
                    accessoryType: .disclosureIndicator
                )
            )
        )
        let codeEditorSettingsCellViewModel = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.codeEditor.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.codeEditor.cellTitle),
                    accessoryType: .disclosureIndicator
                )
            )
        )

        // Language
        let contentLanguageCellViewModel = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.contentLanguage.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.contentLanguage.cellTitle),
                    detailType: .label(text: settingsViewModel.contentLanguage),
                    accessoryType: .disclosureIndicator
                )
            )
        )

        // Learning
        let autoplayCellViewModel = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.autoplayNextVideo.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.autoplayNextVideo.cellTitle),
                    detailType: .switch(.init(isOn: settingsViewModel.isAutoplayEnabled)),
                    accessoryType: .none
                )
            )
        )
        let adaptiveModeCellViewModel = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.adaptiveMode.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.adaptiveMode.cellTitle),
                    detailType: .switch(.init(isOn: settingsViewModel.isAdaptiveModeEnabled)),
                    accessoryType: .none
                )
            )
        )

        // Downloaded Content
        let downloadsCellViewModel = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.downloads.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.downloads.cellTitle),
                    accessoryType: .disclosureIndicator
                )
            )
        )
        let deleteAllContentCellViewModel = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.deleteAllContent.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(
                        text: Setting.deleteAllContent.cellTitle,
                        appearance: .init(textColor: .stepikRed, textAlignment: .left)
                    ),
                    accessoryType: .none
                )
            )
        )

        // Other
        var otherSectionCellsViewModels = [
            SettingsTableSectionViewModel.Cell(
                uniqueIdentifier: Setting.about.rawValue,
                type: .rightDetail(
                    options: .init(
                        title: .init(text: Setting.about.cellTitle),
                        accessoryType: .disclosureIndicator
                    )
                )
            )
        ]
        if settingsViewModel.isAuthorized {
            otherSectionCellsViewModels.append(
                SettingsTableSectionViewModel.Cell(
                    uniqueIdentifier: Setting.deleteAccount.rawValue,
                    type: .rightDetail(
                        options: .init(
                            title: .init(
                                text: Setting.deleteAccount.cellTitle,
                                appearance: .init(textColor: .stepikRed, textAlignment: .left)
                            ),
                            accessoryType: .disclosureIndicator
                        )
                    )
                )
            )
        }

        let learningSectionCellsViewModels = settingsViewModel.isApplicationThemeSettingAvailable
            ? [autoplayCellViewModel, adaptiveModeCellViewModel]
            : [
                stepTextSizeCellViewModel, codeEditorSettingsCellViewModel, autoplayCellViewModel,
                adaptiveModeCellViewModel
            ]

        var sectionsViewModels: [SettingsTableSectionViewModel] = [
            .init(
                header: .init(title: NSLocalizedString("SettingsHeaderTitleVideo", comment: "")),
                cells: [
                    videoDownloadQualityCellViewModel,
                    videoStreamQualityCellViewModel,
                    useCellularDataForDownloadsCellViewModel
                ],
                footer: nil
            ),
            .init(
                header: .init(title: NSLocalizedString("SettingsHeaderTitleLanguage", comment: "")),
                cells: [contentLanguageCellViewModel],
                footer: nil
            ),
            .init(
                header: .init(title: NSLocalizedString("SettingsHeaderTitleLearning", comment: "")),
                cells: learningSectionCellsViewModels,
                footer: nil
            ),
            .init(
                header: .init(title: NSLocalizedString("SettingsHeaderTitleDownloadedContent", comment: "")),
                cells: [downloadsCellViewModel, deleteAllContentCellViewModel],
                footer: nil
            ),
            .init(
                header: .init(title: NSLocalizedString("SettingsHeaderTitleOther", comment: "")),
                cells: otherSectionCellsViewModels,
                footer: nil
            )
        ]

        if settingsViewModel.isApplicationThemeSettingAvailable {
            let appearanceSectionViewModel = SettingsTableSectionViewModel(
                header: .init(title: NSLocalizedString("SettingsHeaderTitleAppearance", comment: "")),
                cells: [themeCellViewModel, stepTextSizeCellViewModel, codeEditorSettingsCellViewModel],
                footer: nil
            )

            sectionsViewModels.insert(appearanceSectionViewModel, at: 1)
        }

        if settingsViewModel.isAuthorized {
            let logOutCellViewModel = SettingsTableSectionViewModel.Cell(
                uniqueIdentifier: Setting.logOut.rawValue,
                type: .rightDetail(
                    options: .init(
                        title: .init(
                            text: Setting.logOut.cellTitle,
                            appearance: .init(textColor: .stepikRed, textAlignment: .center)
                        ),
                        accessoryType: .none
                    )
                )
            )

            sectionsViewModels.append(.init(header: nil, cells: [logOutCellViewModel], footer: nil))
        }

        self.settingsView?.configure(viewModel: SettingsTableViewModel(sections: sectionsViewModels))
    }
}

// MARK: - SettingsViewController: SettingsViewDelegate -

extension SettingsViewController: SettingsViewDelegate {
    // swiftlint:disable:next cyclomatic_complexity
    func settingsTableView(
        _ tableView: SettingsTableView,
        didSelectCell cell: SettingsTableSectionViewModel.Cell,
        at indexPath: IndexPath
    ) {
        guard let selectedSetting = Setting(uniqueIdentifier: cell.uniqueIdentifier) else {
            return
        }

        switch selectedSetting {
        case .downloadQuality:
            self.interactor.doDownloadVideoQualitySettingPresentation(request: .init())
        case .streamQuality:
            self.interactor.doStreamVideoQualitySettingPresentation(request: .init())
        case .theme:
            self.interactor.doApplicationThemeSettingPresentation(request: .init())
        case .contentLanguage:
            self.interactor.doContentLanguageSettingPresentation(request: .init())
        case .textSize:
            self.interactor.doStepFontSizeSettingPresentation(request: .init())
        case .codeEditor:
            self.push(module: CodeEditorSettingsLegacyAssembly().makeModule())
        case .downloads:
            self.push(module: DownloadsAssembly().makeModule())
        case .deleteAllContent:
            self.handleDeleteAllContentAction()
        case .about:
            self.push(module: AboutAppViewController())
        case .deleteAccount:
            self.interactor.doDeleteUserAccountPresentation(request: .init())
        case .logOut:
            self.handleLogOutAction()
        case .useCellularDataForDownloads, .autoplayNextVideo, .adaptiveMode:
            break
        }
    }

    func settingsCell(_ cell: SettingsRightDetailSwitchTableViewCell, switchValueChanged isOn: Bool) {
        guard let uniqueIdentifier = cell.uniqueIdentifier,
              let setting = Setting(uniqueIdentifier: uniqueIdentifier) else {
            return
        }

        switch setting {
        case .useCellularDataForDownloads:
            self.interactor.doUseCellularDataForDownloadsSettingUpdate(request: .init(isOn: isOn))
        case .autoplayNextVideo:
            self.interactor.doAutoplayNextVideoSettingUpdate(request: .init(isOn: isOn))
        case .adaptiveMode:
            self.interactor.doAdaptiveModeSettingUpdate(request: .init(isOn: isOn))
        default:
            break
        }
    }

    // MARK: Private Helpers

    private func handleDeleteAllContentAction() {
        self.analytics.send(.downloadsClearCacheTapped)
        self.requestDeleteAllContent { [weak self] granted in
            guard let strongSelf = self else {
                return
            }

            if granted {
                strongSelf.analytics.send(.downloadsClearCacheAccepted)
                strongSelf.interactor.doDeleteAllContent(request: .init())
            }
        }
    }

    private func requestDeleteAllContent(completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: NSLocalizedString("DeleteAllContentConfirmationAlertTitle", comment: ""),
            message: NSLocalizedString("DeleteAllContentConfirmationAlertMessage", comment: ""),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Delete", comment: ""),
                style: .destructive,
                handler: { _ in
                    completionHandler(true)
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: { _ in
                    completionHandler(false)
                }
            )
        )

        self.present(alert, animated: true)
    }

    private func handleLogOutAction() {
        self.analytics.send(.logoutTapped)
        self.requestLogOut { [weak self] granted in
            if granted {
                self?.interactor.doAccountLogOut(request: .init())
            }
        }
    }

    private func requestLogOut(completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: NSLocalizedString("LogOutConfirmationAlertTitle", comment: ""),
            message: NSLocalizedString("LogOutConfirmationAlertMessage", comment: ""),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("LogOutConfirmationAlertActionDestructiveTitle", comment: ""),
                style: .destructive,
                handler: { _ in
                    completionHandler(true)
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: { _ in
                    completionHandler(false)
                }
            )
        )

        self.present(alert, animated: true)
    }
}

// MARK: - SettingsViewController: StyledNavigationControllerPresentable -

extension SettingsViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        self.appearance.navigationBarAppearance
    }
}
