import SafariServices
import SnapKit
import UIKit

final class AboutAppViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGroupedFallbackGrouped)
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
        Cell.allCases.forEach {
            self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: $0.uniqueIdentifier)
        }
    }

    private func openURLInWeb(_ urlOrNil: URL?) {
        if let url = urlOrNil {
            self.present(module: SFSafariViewController(url: url))
        }
    }

    // MARK: Inner Types

    private enum Cell: String, CaseIterable, UniqueIdentifiable {
        case termsOfService
        case privacyPolicy

        var uniqueIdentifier: UniqueIdentifierType { "\(self.rawValue)" }

        var title: String {
            switch self {
            case .termsOfService:
                return NSLocalizedString("TermsOfServiceTitle", comment: "")
            case .privacyPolicy:
                return NSLocalizedString("PrivacyPolicyTitle", comment: "")
            }
        }

        var url: URL? {
            switch self {
            case .termsOfService:
                return URL(string: NSLocalizedString("TermsOfServiceLink", comment: ""))
            case .privacyPolicy:
                return URL(string: NSLocalizedString("PrivacyPolicyLink", comment: ""))
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { Cell.allCases.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = Cell.allCases[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: cellType.uniqueIdentifier, for: indexPath)
        cell.textLabel?.text = cellType.title

        return cell
    }
}

extension AboutAppViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { self.socialNetworksView }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedCellType = Cell.allCases[indexPath.row]
        switch selectedCellType {
        case .termsOfService, .privacyPolicy:
            self.openURLInWeb(selectedCellType.url)
        }
    }
}
