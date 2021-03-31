import SnapKit
import UIKit

protocol CourseInfoTabReviewsViewDelegate: AnyObject {
    func courseInfoTabReviewsViewDidPaginationRequesting(_ view: CourseInfoTabReviewsView)
    func courseInfoTabReviewsViewDidRequestWriteReview(_ view: CourseInfoTabReviewsView)
    func courseInfoTabReviewsViewDidRequestEditReview(_ view: CourseInfoTabReviewsView)
    func courseInfoTabReviewsViewDidClickPlaceholderViewActionButton(_ view: CourseInfoTabReviewsView)
    func courseInfoTabReviewsView(_ view: CourseInfoTabReviewsView, willSelectRowAt indexPath: IndexPath) -> Bool
    func courseInfoTabReviewsView(_ view: CourseInfoTabReviewsView, didSelectRowAt indexPath: IndexPath)
}

extension CourseInfoTabReviewsView {
    struct Appearance {
        let headerViewHeight: CGFloat = 60

        let paginationViewHeight: CGFloat = 52

        let emptyStateLabelFont = Typography.bodyFont
        let emptyStateLabelColor = UIColor.stepikMaterialDisabledText
        let emptyStateLabelInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35)

        let errorPlaceholderViewBackgroundColor = UIColor.stepikBackground
    }
}

final class CourseInfoTabReviewsView: UIView {
    let appearance: Appearance

    weak var delegate: CourseInfoTabReviewsViewDelegate?

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

    private lazy var errorPlaceholderView: StepikPlaceholderView = {
        let appearance = StepikPlaceholderView.Appearance(
            backgroundColor: self.appearance.errorPlaceholderViewBackgroundColor
        )

        let view = StepikPlaceholderView()
        view.appearance = appearance
        view.delegate = self
        view.isHidden = true

        return view
    }()

    private var errorPlaceholderViewTopConstraint: Constraint?

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
        self.emptyStateLabel.isHidden = true
        self.errorPlaceholderView.isHidden = true

        self.tableView.skeleton.viewBuilder = {
            CourseInfoTabReviewsCellSkeletonView()
        }
        self.tableView.skeleton.show()
    }

    func hideLoading() {
        self.emptyStateLabel.isHidden = false
        self.errorPlaceholderView.isHidden = true

        self.tableView.skeleton.hide()
    }

    func showErrorPlaceholder() {
        self.errorPlaceholderView.set(placeholder: .noConnection)
        self.errorPlaceholderView.delegate = self
        self.errorPlaceholderView.isHidden = false
    }

    func hideErrorPlaceholder() {
        self.errorPlaceholderView.isHidden = true
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
        self.addSubview(self.errorPlaceholderView)
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

        self.errorPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        self.errorPlaceholderView.snp.makeConstraints { make in
            self.errorPlaceholderViewTopConstraint = make.top.equalToSuperview().constraint
            make.centerX.leading.bottom.trailing.equalToSuperview()
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

            self.errorPlaceholderViewTopConstraint?.update(offset: newValue.top)
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

// MARK: - CourseInfoTabReviewsView: StepikPlaceholderViewDelegate -

extension CourseInfoTabReviewsView: StepikPlaceholderViewDelegate {
    func buttonDidClick(_ button: UIButton) {
        self.delegate?.courseInfoTabReviewsViewDidClickPlaceholderViewActionButton(self)
    }
}
