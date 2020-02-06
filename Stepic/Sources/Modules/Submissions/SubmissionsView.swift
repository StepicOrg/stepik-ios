import SnapKit
import UIKit

protocol SubmissionsViewDelegate: AnyObject {
    func submissionsViewRefreshControlDidRefresh(_ submissionsView: SubmissionsView)
    func submissionsViewDidRequestPagination(_ submissionsView: SubmissionsView)
    func submissionsView(_ submissionsView: SubmissionsView, didSelectRowAt indexPath: IndexPath)
}

extension SubmissionsView {
    struct Appearance {
        let estimatedRowHeight: CGFloat = 120
        let paginationViewHeight: CGFloat = 52
    }
}

final class SubmissionsView: UIView {
    let appearance: Appearance

    weak var delegate: SubmissionsViewDelegate?

    private lazy var refreshControl = UIRefreshControl()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = self.appearance.estimatedRowHeight
        tableView.separatorStyle = .none

        tableView.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.refreshControlDidChangeValue), for: .valueChanged)

        tableView.delegate = self
        tableView.register(cellClass: SubmissionsTableViewCell.self)

        return tableView
    }()

    private var shouldShowPaginationView = false
    var paginationView: UIView?

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
        self.refreshControl.endRefreshing()

        self.tableView.dataSource = dataSource
        self.tableView.reloadData()
    }

    func showPaginationView() {
        self.shouldShowPaginationView = true
        self.tableView.tableFooterView = self.paginationView
        self.tableView.tableFooterView?.frame = CGRect(
            x: 0,
            y: 0,
            width: self.frame.width,
            height: self.appearance.paginationViewHeight
        )
    }

    func hidePaginationView() {
        self.shouldShowPaginationView = false
        self.tableView.tableFooterView?.frame = .zero
        self.tableView.tableFooterView = nil
    }

    func showLoading() {
        self.tableView.skeleton.viewBuilder = { SubmissionsSkeletonView() }
        self.tableView.skeleton.show()
    }

    func hideLoading() {
        self.tableView.skeleton.hide()
    }

    // MARK: Private API

    @objc
    private func refreshControlDidChangeValue() {
        self.delegate?.submissionsViewRefreshControlDidRefresh(self)
    }
}

extension SubmissionsView: ProgrammaticallyInitializableViewProtocol {
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

// MARK: - SubmissionsView: UITableViewDelegate -

extension SubmissionsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1,
           tableView.numberOfSections == 1,
           self.shouldShowPaginationView {
            self.delegate?.submissionsViewDidRequestPagination(self)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.submissionsView(self, didSelectRowAt: indexPath)
    }
}
