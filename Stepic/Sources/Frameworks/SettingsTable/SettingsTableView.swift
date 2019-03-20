import SnapKit
import UIKit

protocol SettingsTableViewDelegate: SettingsInputCellDelegate, SettingsLargeInputCellDelegate { }

extension SettingsTableView {
    struct Appearance { }
}

final class SettingsTableView: UIView {
    let appearance: Appearance
    weak var delegate: SettingsTableViewDelegate?

    private var viewModel: SettingsTableViewModel?

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none

        tableView.sectionFooterHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionFooterHeight = 50.0

        tableView.register(cellClass: SettingsInputTableViewCell<TableInputTextField>.self)
        tableView.register(cellClass: SettingsLargeInputTableViewCell<TableInputTextView>.self)

        tableView.register(headerFooterViewClass: SettingsTableSectionHeaderView.self)
        tableView.register(headerFooterViewClass: SettingsTableSectionFooterView.self)

        return tableView
    }()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(viewModel: SettingsTableViewModel) {
        self.viewModel = viewModel
        self.tableView.reloadData()
    }
}

extension SettingsTableView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.tableView)
    }

    func makeConstraints() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension SettingsTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel?.sections.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.sections[safe: section]?.cells.count ?? 0
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let sectionViewModel = self.viewModel?.sections[safe: indexPath.section],
            let cellViewModel = sectionViewModel.cells[safe: indexPath.item] else {
                fatalError("View model is undefined")
        }

        func setSeparatorsStyle(cell: SettingsTableViewSeparatableCellProtocol) {
            let cellsCount = sectionViewModel.cells.count
            cell.topSeparatorType = indexPath.item == 0 && cellsCount > 1 ? .full : .left
            cell.bottomSeparatorType = indexPath.item == cellsCount - 1 ? .full : .none
        }

        switch cellViewModel.type {
        case .input(let options):
            let cell: SettingsInputTableViewCell<TableInputTextField> = tableView.dequeueReusableCell(for: indexPath)
            cell.uniqueIdentifier = cellViewModel.uniqueIdentifier
            cell.elementView.placeholder = options.placeholderText
            cell.elementView.text = options.valueText
            cell.elementView.shouldAlwaysShowPlaceholder = options.shouldAlwaysShowPlaceholder
            cell.delegate = self.delegate
            setSeparatorsStyle(cell: cell)
            return cell
        case .largeInput(let options):
            let cell: SettingsLargeInputTableViewCell<TableInputTextView> = tableView.dequeueReusableCell(
                for: indexPath
            )
            cell.elementView.placeholder = options.placeholderText
            cell.elementView.text = options.valueText
            cell.elementView.maxTextLength = options.maxLength
            cell.delegate = self.delegate
            cell.uniqueIdentifier = cellViewModel.uniqueIdentifier
            cell.onHeightUpdate = { [weak self] in
                DispatchQueue.main.async {
                    UIView.performWithoutAnimation {
                        self?.tableView.beginUpdates()
                        self?.tableView.endUpdates()
                    }
                }
            }
            setSeparatorsStyle(cell: cell)
            return cell
        default:
            fatalError("Unsupported cell type")
        }
    }
}

extension SettingsTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: SettingsTableSectionHeaderView = tableView.dequeueReusableHeaderFooterView()

        if let title = self.viewModel?.sections[safe: section]?.header?.title {
            view.title = title
        }

        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view: SettingsTableSectionFooterView = tableView.dequeueReusableHeaderFooterView()

        if let description = self.viewModel?.sections[safe: section]?.footer?.description {
            view.text = description
        }

        return view
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionViewModel = self.viewModel?.sections[safe: indexPath.section],
              let cellViewModel = sectionViewModel.cells[safe: indexPath.item] else {
            fatalError("View model is undefined")
        }

        switch cellViewModel.type {
        case .largeInput:
            return UITableViewAutomaticDimension
        default:
            return 44.0
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 53.0
    }
}
