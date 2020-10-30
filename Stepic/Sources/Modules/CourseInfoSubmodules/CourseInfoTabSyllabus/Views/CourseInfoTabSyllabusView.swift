import SnapKit
import UIKit

protocol CourseInfoTabSyllabusViewDelegate: AnyObject {
    func courseInfoTabSyllabusViewDidClickDeadlines(_ courseInfoTabSyllabusView: CourseInfoTabSyllabusView)
    func courseInfoTabSyllabusViewDidClickDownloadAll(_ courseInfoTabSyllabusView: CourseInfoTabSyllabusView)
}

extension CourseInfoTabSyllabusView {
    struct Appearance {
        let loadingIndicatorInsets = LayoutInsets(top: 20)
        let headerViewHeight: CGFloat = 60
    }
}

final class CourseInfoTabSyllabusView: UIView {
    weak var delegate: CourseInfoTabSyllabusViewDelegate?

    let appearance: Appearance

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .stepikGray)
        view.hidesWhenStopped = true
        return view
    }()
    private var loadingIndicatorTopConstraint: Constraint?

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

    // Reference to tooltip-anchor view
    var deadlinesButtonTooltipAnchorView: UIView { self.headerView.deadlinesButtonTooltipAnchorView }

    // Reference to tooltip-container view
    var deadlinesButtonTooltipContainerView: UIView { self.tableView }

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

    override func layoutSubviews() {
        super.layoutSubviews()
        self.tableView.layoutTableHeaderView()
    }

    // MARK: Public API

    func showLoading() {
        self.tableView.isHidden = true
        self.loadingIndicator.startAnimating()
    }

    func hideLoading() {
        self.tableView.isHidden = false
        self.loadingIndicator.stopAnimating()
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
        self.addSubview(self.loadingIndicator)
    }

    func makeConstraints() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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

extension CourseInfoTabSyllabusView: CourseInfoScrollablePageViewProtocol {
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
