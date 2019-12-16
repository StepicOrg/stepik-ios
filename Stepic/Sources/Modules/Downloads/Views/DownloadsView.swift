import SnapKit
import UIKit

// MARK: Appearance -

extension DownloadsView {
    struct Appearance {
        let estimatedRowHeight: CGFloat = 96
    }
}

// MARK: - DownloadsViewDelegate -

protocol DownloadsViewDelegate: AnyObject {
    func downloadsView(_ downloadsView: DownloadsView, didSelectCell cell: UITableViewCell, at indexPath: IndexPath)
}

// MARK: - DownloadsView: UIView -

final class DownloadsView: UIView {
    let appearance: Appearance

    weak var delegate: DownloadsViewDelegate?

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = self.appearance.estimatedRowHeight

        tableView.register(cellClass: DownloadsTableViewCell.self)

        tableView.delegate = self

        return tableView
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public API

    func updateTableViewData(dataSource: UITableViewDataSource) {
        self.tableView.dataSource = dataSource
        self.tableView.reloadData()
    }

    func setEditing(_ editing: Bool, animated: Bool) {
        self.tableView.setEditing(editing, animated: animated)
    }
}

// MARK: - DownloadsView: ProgrammaticallyInitializableViewProtocol -

extension DownloadsView: ProgrammaticallyInitializableViewProtocol {
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

// MARK: - DownloadsView: UITableViewDelegate -

extension DownloadsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let selectedCell = tableView.cellForRow(at: indexPath) {
            self.delegate?.downloadsView(self, didSelectCell: selectedCell, at: indexPath)
        }
    }
}
