import SnapKit
import UIKit

protocol CourseInfoTabReviewsViewDelegate: class {
    func courseInfoTabReviewsViewDidPaginationRequesting(_ courseInfoTabReviewsView: CourseInfoTabReviewsView)
    func courseInfoTabReviewsViewDidRequestWriteReview(_ courseInfoTabReviewsView: CourseInfoTabReviewsView)
    func courseInfoTabReviewsViewDidRequestEditReview(_ courseInfoTabReviewsView: CourseInfoTabReviewsView)
    func courseInfoTabReviewsView(
        _ courseInfoTabReviewsView: CourseInfoTabReviewsView,
        willSelectRowAt index: Int
    ) -> Bool
    func courseInfoTabReviewsView(
        _ courseInfoTabReviewsView: CourseInfoTabReviewsView,
        didSelectRowAt index: Int
    )
}

extension CourseInfoTabReviewsView {
    struct Appearance {
        let headerViewHeight: CGFloat = 60

        let paginationViewHeight: CGFloat = 52

        let emptyStateLabelFont = UIFont.systemFont(ofSize: 17, weight: .light)
        let emptyStateLabelColor = UIColor(hex: 0x535366, alpha: 0.4)
        let emptyStateLabelInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 35)
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
    private func writeReviewDidClick() {
        self.delegate?.courseInfoTabReviewsViewDidRequestWriteReview(self)
    }
}

extension CourseInfoTabReviewsView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.tableView)
        self.addSubview(self.emptyStateLabel)
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
        return self.delegate?.courseInfoTabReviewsView(self, willSelectRowAt: indexPath.row) ?? false
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return self.delegate?.courseInfoTabReviewsView(self, willSelectRowAt: indexPath.row) ?? false ? indexPath : nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.courseInfoTabReviewsView(self, didSelectRowAt: indexPath.row)
    }
}

// MARK: - CourseInfoTabReviewsView: CourseInfoScrollablePageViewProtocol -

extension CourseInfoTabReviewsView: CourseInfoScrollablePageViewProtocol {
    var scrollViewDelegate: UIScrollViewDelegate? {
        get {
            return self.pageScrollViewDelegate
        }
        set {
            self.pageScrollViewDelegate = newValue
        }
    }

    var contentInsets: UIEdgeInsets {
        get {
            return self.tableView.contentInset
        }
        set {
            self.emptyStateLabel.snp.updateConstraints { make in
                make.centerY.equalToSuperview().offset(newValue.top / 2)
            }
            self.tableView.contentInset = newValue
        }
    }

    var contentOffset: CGPoint {
        get {
            return self.tableView.contentOffset
        }
        set {
            self.tableView.contentOffset = newValue
        }
    }

    @available(iOS 11.0, *)
    var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
        get {
            return self.tableView.contentInsetAdjustmentBehavior
        }
        set {
            self.tableView.contentInsetAdjustmentBehavior = newValue
        }
    }
}
