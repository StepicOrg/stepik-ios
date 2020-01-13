import UIKit

struct SelectItemViewModel {
    let sections: [Section]
    let selectedCell: Section.Cell?

    struct Section {
        let cells: [Cell]

        let headerTitle: String?
        let footerTitle: String?

        struct Cell: UniqueIdentifiable {
            let uniqueIdentifier: UniqueIdentifierType
            let title: String
        }
    }
}

final class SelectItemTableViewController: UITableViewController {
    private static let cellReuseIdentifier = "selectItemTableViewCell"

    private let viewModel: SelectItemViewModel
    private var onItemSelected: ((SelectItemViewModel.Section.Cell) -> Void)?

    init(
        style: UITableView.Style,
        viewModel: SelectItemViewModel,
        onItemSelected: ((SelectItemViewModel.Section.Cell) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onItemSelected = onItemSelected
        super.init(style: style)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellReuseIdentifier)
    }

    // MARK: UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int { self.viewModel.sections.count }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.sections[section].cells.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellReuseIdentifier, for: indexPath)

        if let cellViewModel = self.cellViewModel(at: indexPath) {
            cell.textLabel?.text = cellViewModel.title
            cell.accessoryType = cellViewModel.uniqueIdentifier == self.viewModel.selectedCell?.uniqueIdentifier
                ? .checkmark
                : .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        self.viewModel.sections[safe: section]?.headerTitle
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        self.viewModel.sections[safe: section]?.footerTitle
    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let item = self.cellViewModel(at: indexPath) {
            self.onItemSelected?(item)
        }
    }

    // MARK: Private API

    private func cellViewModel(at indexPath: IndexPath) -> SelectItemViewModel.Section.Cell? {
        self.viewModel.sections[safe: indexPath.section]?.cells[safe: indexPath.row]
    }
}
