import SnapKit
import UIKit

extension CertificatesListView {
    struct Appearance {
        let estimatedRowHeight: CGFloat = 142
        let tableViewContentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)

        let paginationViewHeight: CGFloat = 52

        let backgroundColor = UIColor.stepikBackground
    }
}

final class CertificatesListView: UIView {
    let appearance: Appearance

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = self.appearance.backgroundColor
        tableView.contentInset = self.appearance.tableViewContentInset
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = self.appearance.estimatedRowHeight
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(cellClass: CertificatesListTableViewCell.self)
        return tableView
    }()

    private lazy var paginationView = PaginationView()

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

    func showPaginationView() {
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
        self.tableView.tableFooterView?.frame = .zero
        self.tableView.tableFooterView = nil
    }

    func showLoading() {
        self.tableView.skeleton.viewBuilder = { CourseInfoTabSyllabusCellSkeletonView() }
        self.tableView.skeleton.show()
    }

    func hideLoading() {
        self.tableView.skeleton.hide()
    }

    func updateTableViewData(delegate: UITableViewDelegate & UITableViewDataSource) {
        self.tableView.delegate = delegate
        self.tableView.dataSource = delegate
        self.tableView.reloadData()
    }
}

extension CertificatesListView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.tableView)
    }

    func makeConstraints() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
