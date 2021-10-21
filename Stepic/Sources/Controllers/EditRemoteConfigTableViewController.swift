import FirebaseRemoteConfig
import UIKit

final class EditRemoteConfigAssembly: Assembly {
    private let remoteConfig: RemoteConfig

    init(remoteConfig: RemoteConfig = .shared) {
        self.remoteConfig = remoteConfig
    }

    func makeModule() -> UIViewController {
        let viewController = EditRemoteConfigTableViewController(remoteConfig: self.remoteConfig)
        return viewController
    }
}

// MARK: - EditRemoteConfigTableViewController: UITableViewController -

final class EditRemoteConfigTableViewController: UITableViewController {
    private static let cellReuseIdentifier = "EditRemoteConfigTableViewCell"

    private let remoteConfig: RemoteConfig

    init(remoteConfig: RemoteConfig) {
        self.remoteConfig = remoteConfig
        super.init(style: .stepikInsetGrouped)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Remote Config"
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        RemoteConfig.Key.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: Self.cellReuseIdentifier)

        let key = RemoteConfig.Key.allCases[indexPath.row]
        let value = self.remoteConfig.value(for: key)

        cell.textLabel?.text = key.rawValue
        cell.detailTextLabel?.text = value.stringValue ?? "None"

        return cell
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
