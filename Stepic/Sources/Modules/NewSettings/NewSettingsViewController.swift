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

        init?(uniqueIdentifier: UniqueIdentifierType) {
            if let value = Setting(rawValue: uniqueIdentifier) {
                self = value
            } else {
                return nil
            }
        }
    }
}

extension NewSettingsViewController: NewSettingsViewControllerProtocol {
    func displaySettings(viewModel: NewSettings.SettingsLoad.ViewModel) {
        // Video
        let downloadQuality = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.downloadQuality.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: NSLocalizedString("SettingsCellTitleDownloadQuality", comment: "")),
                    detailType: .label(text: "360p"),
                    accessoryType: .disclosureIndicator
                )
            )
        )
        let streamQuality = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.downloadQuality.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: NSLocalizedString("SettingsCellTitleStreamQuality", comment: "")),
                    detailType: .label(text: "360p"),
                    accessoryType: .disclosureIndicator
                )
            )
        )

        // Language
        let contentLanguage = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.downloadQuality.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: NSLocalizedString("SettingsCellTitleContentLanguage", comment: "")),
                    detailType: .label(text: "English"),
                    accessoryType: .disclosureIndicator
                )
            )
        )

        // Learning
        let textSize = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.textSize.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: NSLocalizedString("SettingsCellTitleTextSizeInSteps", comment: "")),
                    detailType: .label(text: "Small"),
                    accessoryType: .disclosureIndicator
                )
            )
        )
        let codeEditor = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.codeEditor.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: NSLocalizedString("SettingsCellTitleCodeEditor", comment: "")),
                    detailType: .none,
                    accessoryType: .disclosureIndicator
                )
            )
        )
        let autoplayNextVideo = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.autoplayNextVideo.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: NSLocalizedString("SettingsCellTitleAutoplayNextVideo", comment: "")),
                    detailType: .switch(isOn: true),
                    accessoryType: .none
                )
            )
        )
        let adaptiveMode = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.adaptiveMode.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: NSLocalizedString("SettingsCellTitleAdaptiveMode", comment: "")),
                    detailType: .switch(isOn: true),
                    accessoryType: .none
                )
            )
        )

        // Downloaded Content
        let downloads = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.downloads.rawValue,
            type: .rightDetail(
                options: .init(
                    title: .init(text: NSLocalizedString("SettingsCellTitleDownloads", comment: "")),
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
                        text: NSLocalizedString("SettingsCellTitleDeleteAllContent", comment: ""),
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
                    title: .init(text: NSLocalizedString("SettingsCellTitleAbout", comment: "")),
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
                        text: NSLocalizedString("SettingsCellTitleLogOut", comment: ""),
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
