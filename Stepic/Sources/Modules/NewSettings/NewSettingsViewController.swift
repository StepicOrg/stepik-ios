import SVProgressHUD
import UIKit

// MARK: NewSettingsViewControllerProtocol: AnyObject -

protocol NewSettingsViewControllerProtocol: AnyObject {
    func displaySettings(viewModel: NewSettings.SettingsLoad.ViewModel)
    func displayDownloadVideoQualitySetting(viewModel: NewSettings.DownloadVideoQualitySettingPresentation.ViewModel)
    func displayStreamVideoQualitySetting(viewModel: NewSettings.StreamVideoQualitySettingPresentation.ViewModel)
    func displayContentLanguageSetting(viewModel: NewSettings.ContentLanguageSettingPresentation.ViewModel)
    func displayStepFontSizeSetting(viewModel: NewSettings.StepFontSizeSettingPresentation.ViewModel)
    func displayDeleteAllContentResult(viewModel: NewSettings.DeleteAllContent.ViewModel)
    func displayBlockingLoadingIndicator(viewModel: NewSettings.BlockingWaitingIndicatorUpdate.ViewModel)
}

// MARK: - Appearance -

extension NewSettingsViewController {
    struct Appearance {
        var navigationBarAppearance: StyledNavigationController.NavigationBarAppearanceState = .init()
    }
}

// MARK: - NewSettingsViewController: UIViewController -

final class NewSettingsViewController: UIViewController {
    private let interactor: NewSettingsInteractorProtocol

    let appearance: Appearance

    lazy var settingsView = self.view as? NewSettingsView
    lazy var styledNavigationController = self.navigationController as? StyledNavigationController

    private lazy var closeBarButtonItem: UIBarButtonItem = {
        if #available(iOS 13.0, *) {
            return UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(self.closeButtonClicked)
            )
        } else {
            return UIBarButtonItem(
                image: UIImage(named: "navigation-item-button-close"),
                style: .plain,
                target: self,
                action: #selector(self.closeButtonClicked)
            )
        }
    }()

    init(
        interactor: NewSettingsInteractorProtocol,
        appearance: Appearance = .init()
    ) {
        self.interactor = interactor
        self.appearance = appearance
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = NewSettingsView(frame: UIScreen.main.bounds)
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

        // FIXME: analytics dependency
        AmplitudeAnalyticsEvents.Settings.opened.send()

        self.updateNavigationBarAppearance()
    }

    // MARK: Private API

    private func setupNavigationItem() {
        self.title = NSLocalizedString("SettingsTitle", comment: "")
        self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
        case contentLanguage
        case textSize
        case codeEditor
        case autoplayNextVideo
        case adaptiveMode
        case downloads
        case deleteAllContent
        case about
        case logOut

        var cellTitle: String {
            switch self {
            case .downloadQuality:
                return NSLocalizedString("SettingsCellTitleDownloadQuality", comment: "")
            case .streamQuality:
                return NSLocalizedString("SettingsCellTitleStreamQuality", comment: "")
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

// MARK: - NewSettingsViewController: NewSettingsViewControllerProtocol -

extension NewSettingsViewController: NewSettingsViewControllerProtocol {
    func displaySettings(viewModel: NewSettings.SettingsLoad.ViewModel) {
        self.updateSettingsViewModel(viewModel.viewModel)
    }

    func displayDownloadVideoQualitySetting(viewModel: NewSettings.DownloadVideoQualitySettingPresentation.ViewModel) {
        self.displaySelectSettingModule(
            settingDescription: viewModel.settingDescription,
            title: NSLocalizedString("SettingsDownloadVideoQualityTitle", comment: ""),
            footerTitle: NSLocalizedString("SettingsDownloadVideoQualityFooterTitle", comment: ""),
            onSettingSelected: { [weak self] selectedSetting in
                self?.interactor.doDownloadVideoQualitySettingUpdate(request: .init(setting: selectedSetting))
            }
        )
    }

    func displayStreamVideoQualitySetting(viewModel: NewSettings.StreamVideoQualitySettingPresentation.ViewModel) {
        self.displaySelectSettingModule(
            settingDescription: viewModel.settingDescription,
            title: NSLocalizedString("SettingsStreamVideoQualityTitle", comment: ""),
            footerTitle: NSLocalizedString("SettingsStreamVideoQualityFooterTitle", comment: ""),
            onSettingSelected: { [weak self] selectedSetting in
                self?.interactor.doStreamVideoQualitySettingUpdate(request: .init(setting: selectedSetting))
            }
        )
    }

    func displayContentLanguageSetting(viewModel: NewSettings.ContentLanguageSettingPresentation.ViewModel) {
        self.displaySelectSettingModule(
            settingDescription: viewModel.settingDescription,
            title: NSLocalizedString("SettingsContentLanguageTitle", comment: ""),
            footerTitle: NSLocalizedString("SettingsContentLanguageFooterTitle", comment: ""),
            onSettingSelected: { [weak self] selectedSetting in
                self?.interactor.doContentLanguageSettingUpdate(request: .init(setting: selectedSetting))
            }
        )
    }

    func displayStepFontSizeSetting(viewModel: NewSettings.StepFontSizeSettingPresentation.ViewModel) {
        self.displaySelectSettingModule(
            settingDescription: viewModel.settingDescription,
            title: NSLocalizedString("SettingsStepFontSizeTitle", comment: ""),
            footerTitle: NSLocalizedString("SettingsStepFontSizeFooterTitle", comment: ""),
            onSettingSelected: { [weak self] selectedSetting in
                self?.interactor.doStepFontSizeUpdate(request: .init(setting: selectedSetting))
            }
        )
    }

    func displayDeleteAllContentResult(viewModel: NewSettings.DeleteAllContent.ViewModel) {
        if viewModel.isSuccessful {
            SVProgressHUD.showSuccess(withStatus: nil)
        } else {
            SVProgressHUD.showError(withStatus: nil)
        }
    }

    func displayBlockingLoadingIndicator(viewModel: NewSettings.BlockingWaitingIndicatorUpdate.ViewModel) {
        if viewModel.shouldDismiss {
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.show()
        }
    }

    // MARK: Private Helpers

    private func displaySelectSettingModule(
        settingDescription: NewSettings.SettingDescription,
        title: String? = nil,
        headerTitle: String? = nil,
        footerTitle: String? = nil,
        onSettingSelected: ((NewSettings.SettingDescription.Setting) -> Void)? = nil
    ) {
        let selectedCellViewModel: SelectItemViewModel.Section.Cell? = {
            if let currentSetting = settingDescription.currentSetting {
                return .init(uniqueIdentifier: currentSetting.uniqueIdentifier, title: currentSetting.title)
            }
            return nil
        }()

        let controller = SelectItemTableViewController(
            style: .insetGroupedFallbackGrouped,
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
                let selectedSetting = NewSettings.SettingDescription.Setting(
                    uniqueIdentifier: selectedCellViewModel.uniqueIdentifier,
                    title: selectedCellViewModel.title
                )
                onSettingSelected?(selectedSetting)
            }
        )

        controller.title = title

        self.push(module: controller)
    }

    private func updateSettingsViewModel(_ settingsViewModel: NewSettingsViewModel) {
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
        let autoplayNextVideoCellViewModel = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.autoplayNextVideo.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.autoplayNextVideo.cellTitle),
                    detailType: .switch(isOn: settingsViewModel.isAutoplayEnabled),
                    accessoryType: .none
                )
            )
        )
        let adaptiveModeCellViewModel = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.adaptiveMode.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.adaptiveMode.cellTitle),
                    detailType: .switch(isOn: settingsViewModel.isAdaptiveModeEnabled),
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
                        appearance: .init(textColor: .errorRed, textAlignment: .left)
                    ),
                    accessoryType: .none
                )
            )
        )

        // Other
        let aboutCellViewModel = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.about.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.about.cellTitle),
                    accessoryType: .disclosureIndicator
                )
            )
        )

        // Log Out
        let logOutCellViewModel = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.logOut.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(
                        text: Setting.logOut.cellTitle,
                        appearance: .init(textColor: .errorRed, textAlignment: .center)
                    ),
                    accessoryType: .none
                )
            )
        )

        let sectionsViewModels: [SettingsTableSectionViewModel] = [
            .init(
                header: .init(title: NSLocalizedString("SettingsHeaderTitleVideo", comment: "")),
                cells: [videoDownloadQualityCellViewModel, videoStreamQualityCellViewModel],
                footer: nil
            ),
            .init(
                header: .init(title: NSLocalizedString("SettingsHeaderTitleLanguage", comment: "")),
                cells: [contentLanguageCellViewModel],
                footer: nil
            ),
            .init(
                header: .init(title: NSLocalizedString("SettingsHeaderTitleLearning", comment: "")),
                cells: [
                    stepTextSizeCellViewModel,
                    codeEditorSettingsCellViewModel,
                    autoplayNextVideoCellViewModel,
                    adaptiveModeCellViewModel
                ],
                footer: nil
            ),
            .init(
                header: .init(title: NSLocalizedString("SettingsHeaderTitleDownloadedContent", comment: "")),
                cells: [downloadsCellViewModel, deleteAllContentCellViewModel],
                footer: nil
            ),
            .init(
                header: .init(title: NSLocalizedString("SettingsHeaderTitleOther", comment: "")),
                cells: [aboutCellViewModel],
                footer: nil
            ),
            .init(header: nil, cells: [logOutCellViewModel], footer: nil)
        ]

        self.settingsView?.configure(viewModel: SettingsTableViewModel(sections: sectionsViewModels))
    }
}

// MARK: - NewSettingsViewController: NewSettingsViewDelegate -

extension NewSettingsViewController: NewSettingsViewDelegate {
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
            break
        case .logOut:
            self.handleLogOutAction()
        case .autoplayNextVideo, .adaptiveMode:
            break
        }
    }

    func settingsCell(_ cell: SettingsRightDetailSwitchTableViewCell, switchValueChanged isOn: Bool) {
        guard let uniqueIdentifier = cell.uniqueIdentifier,
              let setting = Setting(uniqueIdentifier: uniqueIdentifier) else {
            return
        }

        switch setting {
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
        self.requestDeleteAllContent { [weak self] granted in
            if granted {
                self?.interactor.doDeleteAllContent(request: .init())
            }
        }
    }

    private func requestDeleteAllContent(completionHandler: @escaping ((Bool) -> Void)) {
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
        self.requestLogOut { [weak self] granted in
            if granted {
                self?.interactor.doLogOutOfAccount(request: .init())
            }
        }
    }

    private func requestLogOut(completionHandler: @escaping ((Bool) -> Void)) {
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

// MARK: - NewSettingsViewController: StyledNavigationControllerPresentable -

extension NewSettingsViewController: StyledNavigationControllerPresentable {
    var navigationBarAppearanceOnFirstPresentation: StyledNavigationController.NavigationBarAppearanceState {
        self.appearance.navigationBarAppearance
    }
}
