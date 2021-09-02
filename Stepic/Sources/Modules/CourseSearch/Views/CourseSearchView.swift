import SnapKit
import UIKit

extension CourseSearchView {
    struct Appearance {
        let backgroundColor = UIColor.stepikBackground
    }
}

final class CourseSearchView: UIView {
    let appearance: Appearance

    private lazy var suggestionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = self.appearance.backgroundColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.register(cellClass: CourseSearchSuggestionTableViewCell.self)
        tableView.isHidden = true
        return tableView
    }()

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

    func setSuggestionsTableViewHidden(_ isHidden: Bool) {
        self.suggestionsTableView.isHidden = isHidden
        self.suggestionsTableView.alpha = isHidden ? 0 : 1
    }

    func updateSuggestionsTableViewData(delegate: UITableViewDelegate & UITableViewDataSource) {
        self.suggestionsTableView.delegate = delegate
        self.suggestionsTableView.dataSource = delegate
        self.suggestionsTableView.reloadData()
    }
}

extension CourseSearchView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.suggestionsTableView)
    }

    func makeConstraints() {
        self.suggestionsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.suggestionsTableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
