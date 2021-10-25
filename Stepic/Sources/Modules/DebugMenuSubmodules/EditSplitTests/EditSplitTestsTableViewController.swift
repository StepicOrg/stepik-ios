import UIKit

final class EditSplitTestsAssembly: Assembly {
    private let activeSplitTests: [SplitTestPlainObject]
    private let storage: StringStorageServiceProtocol

    init(
        activeSplitTests: [SplitTestPlainObject] = ActiveSplitTestsContainer.activeSplitTests,
        storage: StringStorageServiceProtocol = UserDefaults.standard
    ) {
        self.activeSplitTests = activeSplitTests
        self.storage = storage
    }

    func makeModule() -> UIViewController {
        let viewController = EditSplitTestsTableViewController(
            activeSplitTests: self.activeSplitTests,
            storage: self.storage
        )
        return viewController
    }
}

// MARK: - EditSplitTestsTableViewController: UITableViewController -

final class EditSplitTestsTableViewController: UITableViewController {
    private static let cellReuseIdentifier = "EditSplitTestsTableViewCell"

    private let activeSplitTests: [SplitTestPlainObject]
    private let storage: StringStorageServiceProtocol

    init(activeSplitTests: [SplitTestPlainObject], storage: StringStorageServiceProtocol) {
        self.activeSplitTests = activeSplitTests
        self.storage = storage
        super.init(style: .stepikInsetGrouped)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "A/B Groups"
    }

    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.activeSplitTests.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: Self.cellReuseIdentifier)

        let splitTest = self.activeSplitTests[indexPath.row]
        let currentGroup = self.getCurrentGroup(for: splitTest)

        cell.textLabel?.text = splitTest.uniqueIdentifier
        cell.detailTextLabel?.text = currentGroup ?? "None"

        return cell
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let alert = UIAlertController(title: "Select A/B Group", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        let splitTest = self.activeSplitTests[indexPath.row]
        let currentGroup = self.getCurrentGroup(for: splitTest)

        splitTest.groups.map { groupUniqueIdentifier -> UIAlertAction in
            UIAlertAction(
                title: groupUniqueIdentifier == currentGroup ? "\(groupUniqueIdentifier) ✓" : groupUniqueIdentifier,
                style: .default,
                handler: { [weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }

                    strongSelf.storage.save(string: groupUniqueIdentifier, for: splitTest.dataBaseKey)

                    let cell = strongSelf.tableView.cellForRow(at: indexPath)
                    cell?.detailTextLabel?.text = groupUniqueIdentifier
                }
            )
        }.forEach { alert.addAction($0) }

        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = tableView
            popoverPresentationController.sourceRect = tableView.rectForRow(at: indexPath)
        }

        self.present(alert, animated: true)
    }

    // MARK: Private API

    private func getCurrentGroup(for splitTest: SplitTestPlainObject) -> UniqueIdentifierType? {
        guard let splitTest = self.activeSplitTests.first(
            where: { $0.uniqueIdentifier == splitTest.uniqueIdentifier }
        ) else {
            return nil
        }

        return self.storage.getString(for: splitTest.dataBaseKey)
    }
}
