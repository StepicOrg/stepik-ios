import SnapKit
import UIKit

protocol NewDiscussionsViewDelegate: class {
    func newDiscussionsViewDidRequestRefresh(_ view: NewDiscussionsView)
    func newDiscussionsViewDidRequestPagination(_ view: NewDiscussionsView)
}

extension NewDiscussionsView {
    struct Appearance {
        let backgroundColor: UIColor = .white
        let paginationViewHeight: CGFloat = 52
    }
}

final class NewDiscussionsView: UIView {
    let appearance: Appearance
    weak var delegate: NewDiscussionsViewDelegate?

    private lazy var paginationView = PaginationView()

    private lazy var refreshControl = UIRefreshControl()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.separatorStyle = .none

        tableView.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.refreshControlDidChangeValue), for: .valueChanged)

        tableView.register(cellClass: NewDiscussionsTableViewCell.self)
        tableView.register(cellClass: NewDiscussionsLoadMoreTableViewCell.self)

        // Should use `self` as delegate to proxify some delegate methods
        tableView.delegate = self
        tableView.dataSource = self.tableViewDelegate

        return tableView
    }()

    private weak var tableViewDelegate: (UITableViewDelegate & UITableViewDataSource)?
    private var shouldShowPaginationView = false

    init(
        frame: CGRect = .zero,
        tableViewDelegate: (UITableViewDelegate & UITableViewDataSource),
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.tableViewDelegate = tableViewDelegate
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API

    func updateTableViewData(delegate: UITableViewDelegate & UITableViewDataSource) {
        self.refreshControl.endRefreshing()

        self.tableViewDelegate = delegate
        self.tableView.dataSource = self.tableViewDelegate
        self.tableView.reloadData()
    }

    func showPaginationView() {
        self.shouldShowPaginationView = true

        self.paginationView.setLoading()
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
        self.tableView.skeleton.viewBuilder = {
            CourseInfoTabReviewsSkeletonView()
        }
        self.tableView.skeleton.show()
    }

    func hideLoading() {
        self.tableView.skeleton.hide()
    }

    // MARK: - Private API

    @objc
    private func refreshControlDidChangeValue() {
        self.delegate?.newDiscussionsViewDidRequestRefresh(self)
    }
}

extension NewDiscussionsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

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

// MARK: - NewDiscussionsView: UITableViewDelegate -

extension NewDiscussionsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isLastIndexPath = indexPath.section == tableView.numberOfSections - 1
            && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        if isLastIndexPath && self.shouldShowPaginationView {
            self.delegate?.newDiscussionsViewDidRequestPagination(self)
        }

        self.tableViewDelegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableViewDelegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
}
