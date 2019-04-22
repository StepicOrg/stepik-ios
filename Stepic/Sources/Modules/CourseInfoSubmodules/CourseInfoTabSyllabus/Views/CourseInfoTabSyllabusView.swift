import SnapKit
import UIKit

protocol CourseInfoTabSyllabusViewDelegate: class {
    func courseInfoTabSyllabusViewDidClickDeadlines(_ courseInfoTabSyllabusView: CourseInfoTabSyllabusView)
    func courseInfoTabSyllabusViewDidClickDownloadAll(_ courseInfoTabSyllabusView: CourseInfoTabSyllabusView)
}

extension CourseInfoTabSyllabusView {
    struct Appearance {
        let headerViewHeight: CGFloat = 60
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

    // Reference to tooltip-anchor view
    var deadlinesButtonTooltipAnchorView: UIView {
        return self.headerView.deadlinesButtonTooltipAnchorView
    }

    // Reference to tooltip-container view
    var deadlinesButtonTooltipContainerView: UIView {
        return self.tableView
    }

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

    func updateTableViewData(delegate: UITableViewDelegate & UITableViewDataSource) {
        self.tableViewDelegate = delegate

        self.tableView.dataSource = self.tableViewDelegate
        self.tableView.reloadData()
    }

    func configure(headerViewModel: CourseInfoTabSyllabusHeaderViewModel) {
        self.headerView.isDownloadAllButtonEnabled = headerViewModel.isDownloadAllButtonEnabled
        self.headerView.shouldShowCalendarButton = headerViewModel.isDeadlineButtonVisible
    }
}

extension CourseInfoTabSyllabusView: ProgrammaticallyInitializableViewProtocol {
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
        return self.tableViewDelegate?.tableView?(
            tableView,
            viewForHeaderInSection: section
        )
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
        return .leastNonzeroMagnitude
    }
}

extension CourseInfoTabSyllabusView: CourseInfoScrollablePageViewProtocol {
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
