import SnapKit
import UIKit

protocol CourseRevenueTabPurchasesViewDelegate: AnyObject {
    func courseRevenueTabPurchasesViewDidPaginationRequesting(_ view: CourseRevenueTabPurchasesView)
    func courseRevenueTabPurchasesView(_ view: CourseRevenueTabPurchasesView, didSelectRowAt indexPath: IndexPath)
}

extension CourseRevenueTabPurchasesView {
    struct Appearance {
        let paginationViewHeight: CGFloat = 52
    }
}

final class CourseRevenueTabPurchasesView: UIView {
    let appearance: Appearance

    weak var delegate: CourseRevenueTabPurchasesViewDelegate?

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        tableView.separatorStyle = .none

        tableView.delegate = self
        tableView.register(cellClass: CourseRevenueTabPurchasesTableViewCell.self)

        return tableView
    }()

    // Proxify delegates
    private weak var pageScrollViewDelegate: UIScrollViewDelegate?

    private var shouldShowPaginationView = false
    var paginationView: UIView?

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateTableViewData(dataSource: UITableViewDataSource) {
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
}

extension CourseRevenueTabPurchasesView: ProgrammaticallyInitializableViewProtocol {
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

extension CourseRevenueTabPurchasesView: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageScrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1,
           tableView.numberOfSections == 1,
           self.shouldShowPaginationView {
            self.delegate?.courseRevenueTabPurchasesViewDidPaginationRequesting(self)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.courseRevenueTabPurchasesView(self, didSelectRowAt: indexPath)
    }
}

extension CourseRevenueTabPurchasesView: ScrollablePageViewProtocol {
    var scrollViewDelegate: UIScrollViewDelegate? {
        get {
            self.pageScrollViewDelegate
        }
        set {
            self.pageScrollViewDelegate = newValue
        }
    }

    var contentInsets: UIEdgeInsets {
        get {
            self.tableView.contentInset
        }
        set {
            self.tableView.contentInset = newValue
        }
    }

    var contentOffset: CGPoint {
        get {
            self.tableView.contentOffset
        }
        set {
            self.tableView.contentOffset = newValue
        }
    }

    var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
        get {
            self.tableView.contentInsetAdjustmentBehavior
        }
        set {
            self.tableView.contentInsetAdjustmentBehavior = newValue
        }
    }
}
