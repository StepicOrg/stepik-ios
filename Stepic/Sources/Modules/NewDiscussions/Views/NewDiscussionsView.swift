import SnapKit
import UIKit

protocol NewDiscussionsViewDelegate: class {
    func newDiscussionsViewDidRequestRefresh(_ view: NewDiscussionsView)
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

    private lazy var verticalPaginationView = PaginationView()
    private lazy var bottomPaginationView = PaginationView()

    private lazy var refreshControl = UIRefreshControl()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.separatorStyle = .none

        tableView.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(self.refreshControlDidChangeValue), for: .valueChanged)

        tableView.delegate = self
        tableView.register(cellClass: NewDiscussionsTableViewCell.self)

        return tableView
    }()

    private var shouldShowPaginationView = false

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

    // MARK: - Public API

    func updateTableViewData(dataSource: UITableViewDataSource) {
        self.refreshControl.endRefreshing()

        self.tableView.dataSource = dataSource
        self.tableView.reloadData()
    }

    func showPaginationView() {
        self.shouldShowPaginationView = true

        self.verticalPaginationView.setLoading()
        self.bottomPaginationView.setLoading()

        self.tableView.tableHeaderView = self.verticalPaginationView
        self.tableView.tableHeaderView?.frame = CGRect(
            x: 0,
            y: 0,
            width: self.frame.width,
            height: self.appearance.paginationViewHeight
        )
        self.tableView.tableFooterView = self.bottomPaginationView
        self.tableView.tableFooterView?.frame = CGRect(
            x: 0,
            y: 0,
            width: self.frame.width,
            height: self.appearance.paginationViewHeight
        )
    }

    func hidePaginationView() {
        self.shouldShowPaginationView = false
        self.tableView.tableHeaderView?.frame = .zero
        self.tableView.tableHeaderView = nil
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

extension NewDiscussionsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
