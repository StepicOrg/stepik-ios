import SnapKit
import UIKit

protocol CourseInfoTabSyllabusViewDelegate: AnyObject {
    func courseInfoTabSyllabusViewDidClickDeadlines(_ courseInfoTabSyllabusView: CourseInfoTabSyllabusView)
    func courseInfoTabSyllabusViewDidClickDownloadAll(_ courseInfoTabSyllabusView: CourseInfoTabSyllabusView)
    func courseInfoTabSyllabusViewDidClickErrorPlaceholderAction(_ courseInfoTabSyllabusView: CourseInfoTabSyllabusView)
}

extension CourseInfoTabSyllabusView {
    struct Appearance {
        let headerViewHeight: CGFloat = 60
        let errorPlaceholderBackgroundColor = UIColor.stepikBackground
        let skeletonCellBackgroundColor = UIColor.stepikBackground
    }
}

final class CourseInfoTabSyllabusView: UIView {
    weak var delegate: CourseInfoTabSyllabusViewDelegate?

    let appearance: Appearance

    private lazy var headerView: CourseInfoTabSyllabusHeaderView = {
        let headerView = CourseInfoTabSyllabusHeaderView()

        // Disable masks to prevent constraints breaking
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.headerViewHeight)
        }

        headerView.onDownloadAllButtonClick = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.courseInfoTabSyllabusViewDidClickDownloadAll(strongSelf)
            }
        }

        headerView.onCalendarButtonClick = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.courseInfoTabSyllabusViewDidClickDeadlines(strongSelf)
            }
        }

        return headerView
    }()

    // Proxify scroll view delegate
    private weak var pageScrollViewDelegate: UIScrollViewDelegate?
    private weak var tableViewDelegate: (UITableViewDelegate & UITableViewDataSource)?

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        tableView.estimatedSectionHeaderHeight = 90.0
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 1.1

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0

        tableView.tableHeaderView = self.headerView

        tableView.register(cellClass: CourseInfoTabSyllabusTableViewCell.self)

        // Should use `self` as delegate to proxify some delegate methods
        tableView.delegate = self
        tableView.dataSource = self.tableViewDelegate

        return tableView
    }()

    private lazy var errorPlaceholderView: StepikPlaceholderView = {
        let view = StepikPlaceholderView()
        view.appearance = .init(backgroundColor: self.appearance.errorPlaceholderBackgroundColor)
        view.delegate = self
        view.isHidden = true
        return view
    }()

    private var errorPlaceholderViewTopConstraint: Constraint?

    // Reference to tooltip-anchor view
    var deadlinesButtonTooltipAnchorView: UIView { self.headerView.deadlinesButtonTooltipAnchorView }

    // Reference to tooltip-container view
    var deadlinesButtonTooltipContainerView: UIView { self.tableView }

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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.layoutTableHeaderView()
    }

    // MARK: Public API

    func showLoading() {
        self.errorPlaceholderView.isHidden = true
        self.tableView.skeleton.cellBackgroundColor = self.appearance.skeletonCellBackgroundColor
        self.tableView.skeleton.viewBuilder = {
            CourseInfoTabSyllabusCellSkeletonView()
        }
        self.tableView.skeleton.show()
    }

    func hideLoading() {
        self.errorPlaceholderView.isHidden = true
        self.tableView.skeleton.hide()
    }

    func showError() {
        self.errorPlaceholderView.set(placeholder: .noConnection)
        self.errorPlaceholderView.delegate = self
        self.errorPlaceholderView.isHidden = false
    }

    func hideError() {
        self.errorPlaceholderView.isHidden = true
    }

    func updateTableViewData(delegate: UITableViewDelegate & UITableViewDataSource) {
        self.tableViewDelegate = delegate

        self.tableView.dataSource = self.tableViewDelegate
        self.tableView.reloadData()
    }

    func configure(headerViewModel: CourseInfoTabSyllabusHeaderViewModel) {
        self.headerView.isDownloadAllButtonEnabled = headerViewModel.isDownloadAllButtonEnabled
        self.headerView.shouldShowCalendarButton = headerViewModel.isDeadlineButtonVisible
        self.headerView.isCalendarButtonEnabled = headerViewModel.isDeadlineButtonEnabled
        self.headerView.courseDownloadState = headerViewModel.courseDownloadState
    }
}

extension CourseInfoTabSyllabusView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.tableView)
        self.addSubview(self.errorPlaceholderView)
    }

    func makeConstraints() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.errorPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        self.errorPlaceholderView.snp.makeConstraints { make in
            self.errorPlaceholderViewTopConstraint = make.top.equalToSuperview().constraint
            make.centerX.leading.bottom.trailing.equalToSuperview()
        }
    }
}

extension CourseInfoTabSyllabusView: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.pageScrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        self.tableViewDelegate?.tableView?(
            tableView,
            willDisplayHeaderView: view,
            forSection: section
        )
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.tableViewDelegate?.tableView?(tableView, viewForHeaderInSection: section)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.tableViewDelegate?.tableView?(
            tableView,
            willDisplay: cell,
            forRowAt: indexPath
        )
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.tableViewDelegate?.tableView?(
            tableView,
            didEndDisplaying: cell,
            forRowAt: indexPath
        )
    }

    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        self.tableViewDelegate?.tableView?(
            tableView,
            didEndDisplayingHeaderView: view,
            forSection: section
        )
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableViewDelegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNonzeroMagnitude
    }
}

extension CourseInfoTabSyllabusView: ScrollablePageViewProtocol {
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

            // Fixes an issue with incorrect content offset on presentation
            if newValue.top > 0 && self.contentOffset.y == 0 {
                self.contentOffset = CGPoint(x: self.contentOffset.x, y: -newValue.top)
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

extension CourseInfoTabSyllabusView: StepikPlaceholderViewDelegate {
    func buttonDidClick(_ button: UIButton) {
        self.delegate?.courseInfoTabSyllabusViewDidClickErrorPlaceholderAction(self)
    }
}
