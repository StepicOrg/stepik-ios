import UIKit

protocol NewSettingsViewControllerProtocol: AnyObject {
    func displaySettings(viewModel: NewSettings.SettingsLoad.ViewModel)
}

final class NewSettingsViewController: UIViewController {
    private let interactor: NewSettingsInteractorProtocol

    lazy var settingsView = self.view as? NewSettingsView

    init(interactor: NewSettingsInteractorProtocol) {
        self.interactor = interactor
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

        self.title = NSLocalizedString("Settings", comment: "")

        self.interactor.doSettingsLoad(request: .init())
    }

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

        var title: String {
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
        let settingsViewModel = viewModel.viewModel

        // Video
        let downloadQuality = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.downloadQuality.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.downloadQuality.title),
                    detailType: .label(text: settingsViewModel.downloadVideoQuality),
                    accessoryType: .disclosureIndicator
                )
            )
        )
        let streamQuality = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.streamQuality.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.streamQuality.title),
                    detailType: .label(text: settingsViewModel.streamVideoQuality),
                    accessoryType: .disclosureIndicator
                )
            )
        )

        // Language
        let contentLanguage = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.contentLanguage.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.contentLanguage.title),
                    detailType: .label(text: settingsViewModel.contentLanguage),
                    accessoryType: .disclosureIndicator
                )
            )
        )

        // Learning
        let textSize = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.textSize.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.textSize.title),
                    detailType: .label(text: settingsViewModel.stepFontSize),
                    accessoryType: .disclosureIndicator
                )
            )
        )
        let codeEditor = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.codeEditor.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.codeEditor.title),
                    detailType: .none,
                    accessoryType: .disclosureIndicator
                )
            )
        )
        let autoplayNextVideo = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.autoplayNextVideo.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.autoplayNextVideo.title),
                    detailType: .switch(isOn: settingsViewModel.isAutoplayEnabled),
                    accessoryType: .none
                )
            )
        )
        let adaptiveMode = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.adaptiveMode.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.adaptiveMode.title),
                    detailType: .switch(isOn: settingsViewModel.isAdaptiveModeEnabled),
                    accessoryType: .none
                )
            )
        )

        // Downloaded Content
        let downloads = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.downloads.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.downloads.title),
                    detailType: .none,
                    accessoryType: .disclosureIndicator
                )
            )
        )
        let deleteAllContent = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.deleteAllContent.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(
                        text: Setting.deleteAllContent.title,
                        appearance: .init(textColor: .errorRed, textAlignment: .left)
                    ),
                    detailType: .none,
                    accessoryType: .none
                )
            )
        )

        // Other
        let about = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.about.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: Setting.about.title),
                    detailType: .none,
                    accessoryType: .disclosureIndicator
                )
            )
        )

        // Log Out
        let logOut = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.logOut.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(
                        text: Setting.logOut.title,
                        appearance: .init(textColor: .errorRed, textAlignment: .center)
                    ),
                    detailType: .none,
                    accessoryType: .none
                )
            )
        )

        let sections: [SettingsTableSectionViewModel] = [
            .init(
                header: .init(title: NSLocalizedString("SettingsHeaderTitleVideo", comment: "")),
                cells: [downloadQuality, streamQuality],
                footer: nil
            ),
            .init(
                header: .init(title: NSLocalizedString("SettingsHeaderTitleLanguage", comment: "")),
                cells: [contentLanguage],
                footer: nil
            ),
            .init(
                header: .init(title: NSLocalizedString("SettingsHeaderTitleLearning", comment: "")),
                cells: [textSize, codeEditor, autoplayNextVideo, adaptiveMode],
                footer: nil
            ),
            .init(
                header: .init(title: NSLocalizedString("SettingsHeaderTitleDownloadedContent", comment: "")),
                cells: [downloads, deleteAllContent],
                footer: nil
            ),
            .init(
                header: .init(title: NSLocalizedString("SettingsHeaderTitleOther", comment: "")),
                cells: [about],
                footer: nil
            ),
            .init(header: nil, cells: [logOut], footer: nil)
        ]

        self.settingsView?.configure(viewModel: SettingsTableViewModel(sections: sections))
    }
}

// MARK: - NewSettingsViewController: NewSettingsViewDelegate -

extension NewSettingsViewController: NewSettingsViewDelegate {
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
            let selectItemController = SelectItemTableViewController(
                style: .insetGroupedFallbackGrouped,
                viewModel: .init(
                    sections: [
                        .init(
                            cells: [
                                .init(uniqueIdentifier: "360p", title: "360p"),
                                .init(uniqueIdentifier: "720p", title: "720p"),
                                .init(uniqueIdentifier: "1080p", title: "1080p")
                            ],
                            headerTitle: "Header",
                            footerTitle: "Footer"
                        )
                    ],
                    selectedCell: .init(uniqueIdentifier: "360p", title: "360p")
                ),
                onItemSelected: { selectedItem in
                    print(selectedItem)
                }
            )
            selectItemController.title = "Title"
            self.navigationController?.pushViewController(selectItemController, animated: true)
        case .streamQuality:
            break
        case .contentLanguage:
            break
        case .textSize:
            break
        case .codeEditor:
            break
        case .autoplayNextVideo:
            break
        case .adaptiveMode:
            break
        case .downloads:
            break
        case .deleteAllContent:
            break
        case .about:
            break
        case .logOut:
            break
        }
    }
}
