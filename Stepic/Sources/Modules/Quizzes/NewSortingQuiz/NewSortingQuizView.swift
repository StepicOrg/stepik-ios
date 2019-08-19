import SnapKit
import UIKit

extension NewSortingQuizView {
    struct Appearance {
    }
}

final class NewSortingQuizView: UIView {
    let appearance: Appearance

    private lazy var tableView: UITableView = {
        let tableView = FullHeightTableView()
        tableView.isScrollEnabled = false
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0

        tableView.register(cellClass: NewSortingQuizTableViewCell.self)

        tableView.dataSource = self
        tableView.delegate = self

        return tableView
    }()

    var isEnabled = true {
        didSet {
            self.tableView.isUserInteractionEnabled = self.isEnabled
        }
    }

    private var options: [String] = []

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

    func set(options: [String]) {
        self.options = options
        self.tableView.reloadData()
    }
}

extension NewSortingQuizView: ProgrammaticallyInitializableViewProtocol {
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

extension NewSortingQuizView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NewSortingQuizTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.textLabel?.text = self.options[indexPath.row]
        return cell
    }
}

extension NewSortingQuizView: UITableViewDelegate {
}
