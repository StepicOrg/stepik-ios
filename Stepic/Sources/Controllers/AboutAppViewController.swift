import SafariServices
import SnapKit
import UIKit

final class AboutAppViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .stepikInsetGrouped)
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 200
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 50.0
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    private lazy var socialNetworksView: StepikSocialNetworksView = {
        let view = StepikSocialNetworksView()
        view.onSocialNetworkClick = { socialNetwork in
            AnalyticsEvent.socialNetworkClicked(socialNetwork).report()
            if let url = socialNetwork.url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        return view
    }()

    private lazy var appVersionLabel: UILabel = {
        let label = UILabel()
        label.textColor = Appearance.appVersionLabelTextColor
        label.font = Appearance.appVersionLabelFont
        label.textAlignment = Appearance.appVersionLabelTextAlignment
        label.text = FormatterHelper.prettyVersion(
            versionNumber: Bundle.main.versionNumber,
            buildNumber: Bundle.main.buildNumber
        )
        return label
    }()

    private lazy var appVersionContainerView = UIView()

    private lazy var contactSupportController = ContactSupportController(
        presentationController: self,
        userAccountService: UserAccountService()
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    // MARK: Private API

    private func setup() {
        self.title = NSLocalizedString("AboutAppTitle", comment: "")

        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        // Simulate static table view.
        CellType.allCases.forEach {
            self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: $0.uniqueIdentifier)
        }

        self.appVersionContainerView.addSubview(self.appVersionLabel)
        self.appVersionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.appVersionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Appearance.appVersionLabelInsets.top)
            make.centerX.equalToSuperview()
        }
    }

    private func openURLInWeb(_ urlOrNil: URL?) {
        if let url = urlOrNil {
            self.present(module: SFSafariViewController(url: url))
        }
    }

    // MARK: Inner Types

    private enum Appearance {
        static var appVersionLabelTextColor = UIColor.stepikAccent
        static var appVersionLabelFont = UIFont.systemFont(ofSize: 14)
        static var appVersionLabelTextAlignment = NSTextAlignment.center
        static var appVersionLabelInsets = UIEdgeInsets(top: 24, left: 16, bottom: 0, right: 16)
    }

    private enum CellType: String, CaseIterable, UniqueIdentifiable {
        case helpCenter
        case contactSupport
        case termsOfService
        case privacyPolicy

        var uniqueIdentifier: UniqueIdentifierType { "\(self.rawValue)" }

        var title: String {
            switch self {
            case .helpCenter:
                return NSLocalizedString("HelpCenterTitle", comment: "")
            case .contactSupport:
                return NSLocalizedString("ContactSupportTitle", comment: "")
            case .termsOfService:
                return NSLocalizedString("TermsOfServiceTitle", comment: "")
            case .privacyPolicy:
                return NSLocalizedString("PrivacyPolicyTitle", comment: "")
            }
        }

        var url: URL? {
            switch self {
            case .helpCenter:
                return URL(string: NSLocalizedString("HelpCenterLink", comment: ""))
            case .termsOfService:
                return URL(string: NSLocalizedString("TermsOfServiceLink", comment: ""))
            case .privacyPolicy:
                return URL(string: NSLocalizedString("PrivacyPolicyLink", comment: ""))
            default:
                return nil
            }
        }
    }

    private enum AnalyticsEvent {
        case socialNetworkClicked(StepikSocialNetwork)

        func report() {
            switch self {
            case .socialNetworkClicked(let socialNetwork):
                AnalyticsReporter.reportEvent(
                    AnalyticsEvents.Profile.Settings.socialNetworkClick,
                    parameters: ["social": socialNetwork.rawValue]
                )
            }
        }
    }
}

extension AboutAppViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { CellType.allCases.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = CellType.allCases[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: cellType.uniqueIdentifier, for: indexPath)
        cell.textLabel?.text = cellType.title

        return cell
    }
}

extension AboutAppViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.socialNetworksView
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        self.appVersionContainerView
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.onDidSelectCell(CellType.allCases[indexPath.row])
    }

    private func onDidSelectCell(_ type: CellType) {
        switch type {
        case .helpCenter, .termsOfService, .privacyPolicy:
            self.openURLInWeb(type.url)
        case .contactSupport:
            self.contactSupportController.contactSupport()
        }
    }
}
