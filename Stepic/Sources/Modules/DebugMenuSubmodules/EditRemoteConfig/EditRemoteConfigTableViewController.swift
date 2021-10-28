import FirebaseRemoteConfig
import UIKit

final class EditRemoteConfigAssembly: Assembly {
    func makeModule() -> UIViewController {
        let viewController = EditRemoteConfigTableViewController(remoteConfig: .shared, debugRemoteConfig: .shared)
        return viewController
    }
}

// MARK: - EditRemoteConfigTableViewController: UITableViewController -

final class EditRemoteConfigTableViewController: UITableViewController {
    private static let cellReuseIdentifier = "EditRemoteConfigTableViewCell"

    private let remoteConfig: RemoteConfig
    private let debugRemoteConfig: DebugRemoteConfig

    private lazy var moreBarButtonItem = UIBarButtonItem(
        image: UIImage(named: "horizontal-dots-icon")?.withRenderingMode(.alwaysTemplate),
        style: .plain,
        target: self,
        action: #selector(self.moreBarButtonItemClicked)
    )

    init(remoteConfig: RemoteConfig, debugRemoteConfig: DebugRemoteConfig) {
        self.remoteConfig = remoteConfig
        self.debugRemoteConfig = debugRemoteConfig
        super.init(style: .stepikInsetGrouped)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Remote Config"
        self.navigationItem.rightBarButtonItem = self.moreBarButtonItem
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        RemoteConfig.Key.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: Self.cellReuseIdentifier)

        let key = self.getRemoteConfigKey(at: indexPath)
        let stringValue: String? = {
            if let debugValue = self.debugRemoteConfig.getValueForKey(key) {
                return String(describing: debugValue)
            }
            return self.remoteConfig.value(for: key).stringValue
        }()

        cell.textLabel?.text = key.rawValue
        cell.detailTextLabel?.text = stringValue ?? "None"

        return cell
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let key = self.getRemoteConfigKey(at: indexPath)

        switch key.valueDataType {
        case .string:
            let stringValue: String? = {
                if let debugValue = self.debugRemoteConfig.getValueForKey(key) as? String {
                    return debugValue
                }
                return self.remoteConfig.value(for: key).stringValue
            }()
            let assembly = EditRemoteConfigValueAssembly(key: key, value: stringValue, delegate: self)

            self.push(module: assembly.makeModule())
        default:
            return self.presentDataTypeNotSupportedAlert(key.valueDataType)
        }
    }

    // MARK: Private API

    private func getRemoteConfigKey(at indexPath: IndexPath) -> RemoteConfig.Key {
        RemoteConfig.Key.allCases[indexPath.row]
    }

    private func presentDataTypeNotSupportedAlert(_ dataType: RemoteConfig.ValueDataType) {
        let alert = UIAlertController(
            title: "Error",
            message: "Editing of the \"\(dataType)\" data type is not supported",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        self.present(alert, animated: true)
    }

    @objc
    private func moreBarButtonItemClicked() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(
            UIAlertAction(
                title: "Delete All Debug Values",
                style: .destructive,
                handler: { [weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }

                    for key in RemoteConfig.Key.allCases {
                        strongSelf.debugRemoteConfig.setValue(nil, forKey: key)
                    }

                    strongSelf.tableView.reloadData()
                }
            )
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        alert.popoverPresentationController?.barButtonItem = self.moreBarButtonItem

        self.present(alert, animated: true)
    }
}

// MARK: - EditRemoteConfigTableViewController: EditRemoteConfigValueViewControllerDelegate -

extension EditRemoteConfigTableViewController: EditRemoteConfigValueViewControllerDelegate {
    func editRemoteConfigValueViewController(
        _ viewController: EditRemoteConfigValueViewController,
        didChangeValue value: Any?,
        forKey key: RemoteConfig.Key
    ) {
        guard key.valueDataType == .string else {
            fatalError("\(key.valueDataType) not supported")
        }

        self.navigationController?.popViewController(animated: true)

        self.debugRemoteConfig.setValue(value, forKey: key)
        self.tableView.reloadData()
    }
}
