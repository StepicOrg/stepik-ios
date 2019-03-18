import SnapKit
import UIKit

extension SettingsTableView {
    struct Appearance { }
}

final class SettingsTableView: UIView {
    let appearance: Appearance

    private var viewModel: SettingsTableViewModel?

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none

        tableView.sectionFooterHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionFooterHeight = 50.0

        tableView.register(cellClass: SettingsInputTableViewCell<TableInputTextField>.self)

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
        guard let sectionViewModel = self.viewModel?.sections[safe: indexPath.section] else {
            fatalError("View model is undefined")
        }

        let cell: SettingsInputTableViewCell<TableInputTextField> = tableView.dequeueReusableCell(
            for: indexPath
        )

        let cellsCount = sectionViewModel.cells.count
        cell.topSeparatorType = indexPath.item == 0 && cellsCount > 1 ? .full : .left
        cell.bottomSeparatorType = indexPath.item == cellsCount - 1 ? .full : .none

        return cell
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

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 53.0
    }
}
