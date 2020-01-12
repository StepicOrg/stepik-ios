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
        case downloadOverWiFiOnly
        case contentLanguage

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
                    titleText: "Download Quality",
                    detailValue: .label(text: "360p"),
                    accessoryType: .disclosureIndicator
                )
            )
        )
        let streamQuality = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.downloadQuality.rawValue,
            type: .rightDetail(
                options: .init(
                    titleText: "Stream Quality",
                    detailValue: .label(text: "360p"),
                    accessoryType: .disclosureIndicator
                )
            )
        )
        let downloadOverWiFiOnly = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.downloadQuality.rawValue,
            type: .rightDetail(
                options: .init(
                    titleText: "Download Over Wi-Fi Only",
                    detailValue: .switch(isOn: true),
                    accessoryType: .none
                )
            )
        )

        // Language
        let contentLanguage = SettingsTableSectionViewModel.Cell(
            uniqueIdentifier: Setting.downloadQuality.rawValue,
            type: .rightDetail(
                options: .init(
                    titleText: "Content Language",
                    detailValue: .label(text: "English"),
                    accessoryType: .disclosureIndicator
                )
            )
        )

        let sections: [SettingsTableSectionViewModel] = [
            .init(
                header: .init(title: "Video"),
                cells: [downloadQuality, streamQuality, downloadOverWiFiOnly],
                footer: nil
            ),
            .init(
                header: .init(title: "Language"),
                cells: [contentLanguage],
                footer: nil
            )
        ]

        self.settingsView?.configure(viewModel: SettingsTableViewModel(sections: sections))
    }
}
