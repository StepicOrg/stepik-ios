import SnapKit
import UIKit

protocol DiscussionsViewDelegate: class {
    func discussionsViewDidRequestRefresh(_ view: DiscussionsView)
    func discussionsViewDidRequestTopPagination(_ view: DiscussionsView)
    func discussionsViewDidRequestBottomPagination(_ view: DiscussionsView)
}

extension DiscussionsView {
    struct Appearance {
        let backgroundColor: UIColor = .white

        let paginationViewHeight: CGFloat = 52
        let skeletonCellHeight: CGFloat = 130
    }
}

// MARK: - DiscussionsView: UIView -

final class DiscussionsView: UIView {
    let appearance: Appearance
    weak var delegate: DiscussionsViewDelegate?

    private lazy var topPaginationView = PaginationView()
    private lazy var bottomPaginationView = PaginationView()

    private lazy var refreshControl = UIRefreshControl()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        tableView.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.refreshControlDidChangeValue), for: .valueChanged)

        tableView.register(cellClass: DiscussionsTableViewCell.self)
        tableView.register(cellClass: DiscussionsLoadMoreTableViewCell.self)

        // Should use `self` as delegate to proxify some delegate methods
        tableView.delegate = self
        tableView.dataSource = self.tableViewDelegate

        return tableView
    }()

    private weak var tableViewDelegate: (UITableViewDelegate & UITableViewDataSource)?

    private var shouldShowTopPaginationView = false
    private var shouldShowBottomPaginationView = false

    private var isSkeletonVisible = false

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

    func showTopPaginationView() {
        self.shouldShowTopPaginationView = true

        self.topPaginationView.setLoading()
        self.tableView.tableHeaderView = self.topPaginationView
        self.tableView.tableHeaderView?.frame = CGRect(
            x: 0,
            y: 0,
            width: self.frame.width,
            height: self.appearance.paginationViewHeight
        )
    }

    func hideTopPaginationView() {
        self.shouldShowTopPaginationView = false
        self.tableView.tableHeaderView?.frame = .zero
        self.tableView.tableHeaderView = nil
    }

    func showBottomPaginationView() {
        self.shouldShowBottomPaginationView = true

        self.bottomPaginationView.setLoading()
        self.tableView.tableFooterView = self.bottomPaginationView
        self.tableView.tableFooterView?.frame = CGRect(
            x: 0,
            y: 0,
            width: self.frame.width,
            height: self.appearance.paginationViewHeight
        )
    }

    func hideBottomPaginationView() {
        self.shouldShowBottomPaginationView = false
        self.tableView.tableFooterView?.frame = .zero
        self.tableView.tableFooterView = nil
    }

    func showLoading() {
        self.isSkeletonVisible = true
        self.tableView.skeleton.viewBuilder = {
            CourseInfoTabReviewsSkeletonView()
        }
        self.tableView.skeleton.show()
    }

    func hideLoading() {
        self.isSkeletonVisible = false
        self.tableView.skeleton.hide()
    }

    func scrollToRow(at indexPath: IndexPath, animated: Bool) {
        self.tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
    }

    // MARK: - Private API

    @objc
    private func refreshControlDidChangeValue() {
        self.delegate?.discussionsViewDidRequestRefresh(self)
    }
}

// MARK: - DiscussionsView: ProgrammaticallyInitializableViewProtocol -

extension DiscussionsView: ProgrammaticallyInitializableViewProtocol {
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

// MARK: - DiscussionsView: UITableViewDelegate -

extension DiscussionsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isFirstIndexPath = indexPath.section == 0 && indexPath.row == 0
        if isFirstIndexPath && self.shouldShowTopPaginationView {
            self.delegate?.discussionsViewDidRequestTopPagination(self)
        }

        let isLastIndexPath = indexPath.section == tableView.numberOfSections - 1
            && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        if isLastIndexPath && self.shouldShowBottomPaginationView {
            self.delegate?.discussionsViewDidRequestBottomPagination(self)
        }

        self.tableViewDelegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isSkeletonVisible {
            return self.appearance.skeletonCellHeight
        }

        return self.tableViewDelegate?.tableView?(tableView, heightForRowAt: indexPath) ?? 0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableViewDelegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
}
