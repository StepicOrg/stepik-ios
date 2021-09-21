import SnapKit
import UIKit

protocol CourseInfoTabNewsViewDelegate: AnyObject {
    func courseInfoTabNewsViewDidClickErrorPlaceholderActionButton(_ view: CourseInfoTabNewsView)
}

extension CourseInfoTabNewsView {
    struct Appearance {
        let paginationViewHeight: CGFloat = 52

        let errorPlaceholderViewBackgroundColor = UIColor.stepikBackground
    }
}

final class CourseInfoTabNewsView: UIView {
    private static let hideLoadingTableViewDelay: TimeInterval = 2

    let appearance: Appearance

    weak var delegate: CourseInfoTabNewsViewDelegate?

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.separatorStyle = .none
        tableView.register(cellClass: CourseInfoTabNewsTableViewCell.self)
        return tableView
    }()

    private lazy var loadingTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.separatorStyle = .none
        return tableView
    }()

    private lazy var paginationView = PaginationView()

    private lazy var placeholderView: StepikPlaceholderView = {
        let appearance = StepikPlaceholderView.Appearance(
            backgroundColor: self.appearance.errorPlaceholderViewBackgroundColor
        )
        let view = StepikPlaceholderView()
        view.appearance = appearance
        view.delegate = self
        view.isHidden = true
        return view
    }()

    private var placeholderViewTopConstraint: Constraint?

    // Proxify delegates
    private weak var pageScrollViewDelegate: UIScrollViewDelegate?

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

    func updateTableViewData(delegate: UITableViewDelegate & UITableViewDataSource) {
        self.tableView.delegate = delegate
        self.tableView.dataSource = delegate
        self.tableView.reloadData()
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
        self.loadingTableView.isHidden = false
        self.loadingTableView.skeleton.viewBuilder = { CourseInfoTabReviewsCellSkeletonView() }
        self.loadingTableView.skeleton.show()
    }

    func hideLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.hideLoadingTableViewDelay) {
            self.loadingTableView.skeleton.hide()
            self.loadingTableView.isHidden = true
        }
    }

    func showErrorPlaceholder() {
        self.placeholderView.set(placeholder: .noConnection)
        self.placeholderView.delegate = self
        self.placeholderView.isHidden = false
    }

    func hideErrorPlaceholder() {
        self.placeholderView.isHidden = true
    }

    func showEmptyPlaceholder() {
        self.placeholderView.set(placeholder: .emptyCourseInfoTabNews)
        self.placeholderView.delegate = nil
        self.placeholderView.isHidden = false
    }

    func hideEmptyPlaceholder() {
        self.placeholderView.isHidden = true
    }
}

extension CourseInfoTabNewsView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.tableView)
        self.addSubview(self.loadingTableView)
        self.addSubview(self.placeholderView)
    }

    func makeConstraints() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.snp.makeConstraints { $0.edges.equalToSuperview() }

        self.loadingTableView.translatesAutoresizingMaskIntoConstraints = false
        self.loadingTableView.snp.makeConstraints { $0.edges.equalToSuperview() }

        self.placeholderView.translatesAutoresizingMaskIntoConstraints = false
        self.placeholderView.snp.makeConstraints { make in
            self.placeholderViewTopConstraint = make.top.equalToSuperview().constraint
            make.centerX.leading.bottom.trailing.equalToSuperview()
        }
    }
}

// MARK: - CourseInfoTabNewsView: ScrollablePageViewProtocol -

extension CourseInfoTabNewsView: ScrollablePageViewProtocol {
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
            self.loadingTableView.contentInset = newValue

            self.placeholderViewTopConstraint?.update(offset: newValue.top)
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
            self.loadingTableView.contentInsetAdjustmentBehavior = newValue
        }
    }
}

// MARK: - CourseInfoTabNewsView: StepikPlaceholderViewDelegate -

extension CourseInfoTabNewsView: StepikPlaceholderViewDelegate {
    func buttonDidClick(_ button: UIButton) {
        self.delegate?.courseInfoTabNewsViewDidClickErrorPlaceholderActionButton(self)
    }
}
