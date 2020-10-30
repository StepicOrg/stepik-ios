import SnapKit
import UIKit

protocol CourseInfoTabReviewsViewDelegate: AnyObject {
    func courseInfoTabReviewsViewDidPaginationRequesting(_ courseInfoTabReviewsView: CourseInfoTabReviewsView)
    func courseInfoTabReviewsViewDidRequestWriteReview(_ courseInfoTabReviewsView: CourseInfoTabReviewsView)
    func courseInfoTabReviewsViewDidRequestEditReview(_ courseInfoTabReviewsView: CourseInfoTabReviewsView)
    func courseInfoTabReviewsView(
        _ courseInfoTabReviewsView: CourseInfoTabReviewsView,
        willSelectRowAt indexPath: IndexPath
    ) -> Bool
    func courseInfoTabReviewsView(
        _ courseInfoTabReviewsView: CourseInfoTabReviewsView,
        didSelectRowAt indexPath: IndexPath
    )
}

extension CourseInfoTabReviewsView {
    struct Appearance {
        let loadingIndicatorInsets = LayoutInsets(top: 20)

        let headerViewHeight: CGFloat = 60

        let paginationViewHeight: CGFloat = 52

        let emptyStateLabelFont = UIFont.systemFont(ofSize: 17, weight: .light)
        let emptyStateLabelColor = UIColor.stepikPlaceholderText
        let emptyStateLabelInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35)
    }
}

final class CourseInfoTabReviewsView: UIView {
    let appearance: Appearance
    weak var delegate: CourseInfoTabReviewsViewDelegate?

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .stepikGray)
        view.hidesWhenStopped = true
        return view
    }()
    private var loadingIndicatorTopConstraint: Constraint?

    private lazy var headerView: CourseInfoTabReviewsHeaderView = {
        let headerView = CourseInfoTabReviewsHeaderView()

        // Disable masks to prevent constraints breaking
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.headerViewHeight)
        }

        headerView.onWriteReviewButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseInfoTabReviewsViewDidRequestWriteReview(strongSelf)
        }

        headerView.onEditReviewButtonClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseInfoTabReviewsViewDidRequestEditReview(strongSelf)
        }

        return headerView
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
        tableView.separatorStyle = .none

        tableView.delegate = self
        tableView.register(cellClass: CourseInfoTabReviewsTableViewCell.self)

        return tableView
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("NoReviews", comment: "")
        label.numberOfLines = 0
        label.textColor = self.appearance.emptyStateLabelColor
        label.font = self.appearance.emptyStateLabelFont
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    // Proxify delegates
    private weak var pageScrollViewDelegate: UIScrollViewDelegate?

    private var shouldShowPaginationView = false
    var paginationView: UIView?

    var writeCourseReviewState: CourseInfoTabReviews.WriteCourseReviewState = .hide {
        didSet {
            switch self.writeCourseReviewState {
            case .write:
                self.tableView.tableHeaderView = self.headerView
                self.headerView.shouldShowWriteReviewButton = true
            case .edit:
                self.tableView.tableHeaderView = self.headerView
                self.headerView.shouldShowEditReviewButton = true
            case .hide:
                self.tableView.tableHeaderView = nil
            case .banner(let text):
                self.tableView.tableHeaderView = self.headerView
                self.headerView.writeReviewBannerText = text
                self.headerView.shouldShowWriteReviewBanner = true
            }
        }
    }

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.layoutTableHeaderView()
    }

    // MARK: - Public API

    func updateTableViewData(dataSource: UITableViewDataSource) {
        let numberOfRows = dataSource.tableView(self.tableView, numberOfRowsInSection: 0)
        self.emptyStateLabel.isHidden = numberOfRows != 0

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
        self.tableView.isHidden = true
        self.emptyStateLabel.isHidden = true
        self.loadingIndicator.startAnimating()
    }

    func hideLoading() {
        self.tableView.isHidden = false
        self.emptyStateLabel.isHidden = false
        self.loadingIndicator.stopAnimating()
    }

    func popoverPresentationAnchorPoint(at indexPath: IndexPath) -> (UIView, CGRect) {
        (self.tableView, self.tableView.rectForRow(at: indexPath))
    }

    // MARK: - Private API

    @objc
    private func writeReviewDidClick() {
        self.delegate?.courseInfoTabReviewsViewDidRequestWriteReview(self)
    }
}

extension CourseInfoTabReviewsView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.tableView)
        self.addSubview(self.emptyStateLabel)
        self.addSubview(self.loadingIndicator)
    }

    func makeConstraints() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.emptyStateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading
                .greaterThanOrEqualToSuperview()
                .offset(self.appearance.emptyStateLabelInsets.left)
                .priority(999)
            make.trailing
                .lessThanOrEqualToSuperview()
                .offset(-self.appearance.emptyStateLabelInsets.right)
                .priority(999)
            make.width.lessThanOrEqualTo(600)
        }

        self.loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicator.snp.makeConstraints { make in
            self.loadingIndicatorTopConstraint = make.top
                .equalToSuperview()
                .offset(self.appearance.loadingIndicatorInsets.top).constraint
            make.centerX.equalToSuperview()
        }
    }
}

// MARK: - CourseInfoTabReviewsView: UITableViewDelegate -

extension CourseInfoTabReviewsView: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageScrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1,
           tableView.numberOfSections == 1,
           self.shouldShowPaginationView {
            self.delegate?.courseInfoTabReviewsViewDidPaginationRequesting(self)
        }
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        self.delegate?.courseInfoTabReviewsView(self, willSelectRowAt: indexPath) ?? false
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.delegate?.courseInfoTabReviewsView(self, willSelectRowAt: indexPath) ?? false ? indexPath : nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.courseInfoTabReviewsView(self, didSelectRowAt: indexPath)
    }
}

// MARK: - CourseInfoTabReviewsView: CourseInfoScrollablePageViewProtocol -

extension CourseInfoTabReviewsView: CourseInfoScrollablePageViewProtocol {
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

            self.emptyStateLabel.snp.updateConstraints { make in
                make.centerY.equalToSuperview().offset(newValue.top / 2)
            }

            let loadingIndicatorTopOffset = newValue.top + self.appearance.loadingIndicatorInsets.top
            self.loadingIndicatorTopConstraint?.update(offset: loadingIndicatorTopOffset)
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
