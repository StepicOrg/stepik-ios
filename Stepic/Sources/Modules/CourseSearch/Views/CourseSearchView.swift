import SnapKit
import UIKit

extension CourseSearchView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground

        let paginationViewHeight: CGFloat = 52
    }
}

final class CourseSearchView: UIView {
    let appearance: Appearance

    private lazy var suggestionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = self.appearance.backgroundColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.keyboardDismissMode = .interactive
        tableView.separatorStyle = .none
        tableView.register(cellClass: CourseSearchSuggestionTableViewCell.self)
        return tableView
    }()

    private lazy var searchResultsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = self.appearance.backgroundColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 98
        tableView.separatorStyle = .none
        tableView.register(cellClass: CourseSearchResultTableViewCell.self)
        return tableView
    }()

    var paginationView: UIView?

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
        self.searchResultsTableView.tableFooterView = self.paginationView
        self.searchResultsTableView.tableFooterView?.frame = CGRect(
            x: 0,
            y: 0,
            width: self.frame.width,
            height: self.appearance.paginationViewHeight
        )
    }

    func hidePaginationView() {
        self.searchResultsTableView.tableFooterView?.frame = .zero
        self.searchResultsTableView.tableFooterView = nil
    }

    func showLoading() {
        self.setSearchResultsTableViewHidden(false)

        self.searchResultsTableView.skeleton.viewBuilder = { CourseInfoTabSyllabusCellSkeletonView() }
        self.searchResultsTableView.skeleton.show()
    }

    func hideLoading() {
        self.searchResultsTableView.skeleton.hide()
    }

    func setSuggestionsTableViewHidden(_ isHidden: Bool) {
        self.suggestionsTableView.isHidden = isHidden
        self.suggestionsTableView.alpha = isHidden ? 0 : 1
    }

    func updateSuggestionsTableViewData(delegate: UITableViewDelegate & UITableViewDataSource) {
        self.suggestionsTableView.delegate = delegate
        self.suggestionsTableView.dataSource = delegate
        self.suggestionsTableView.reloadData()
    }

    func setSearchResultsTableViewHidden(_ isHidden: Bool) {
        self.searchResultsTableView.isHidden = isHidden
        self.searchResultsTableView.alpha = isHidden ? 0 : 1
    }

    func updateSearchResultsTableViewData(delegate: UITableViewDelegate & UITableViewDataSource) {
        self.searchResultsTableView.delegate = delegate
        self.searchResultsTableView.dataSource = delegate
        self.searchResultsTableView.reloadData()
    }
}

extension CourseSearchView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor

        self.setSuggestionsTableViewHidden(true)
        self.setSearchResultsTableViewHidden(true)
    }

    func addSubviews() {
        self.addSubview(self.suggestionsTableView)
        self.addSubview(self.searchResultsTableView)
    }

    func makeConstraints() {
        self.suggestionsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.suggestionsTableView.snp.makeConstraints { $0.edges.equalToSuperview() }

        self.searchResultsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.searchResultsTableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
