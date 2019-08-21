import SnapKit
import UIKit

protocol NewSortingQuizViewDelegate: class {
    func newSortingQuizView(
        _ view: NewSortingQuizView,
        didMoveOption option: NewSortingQuiz.Option,
        atIndex sourceIndex: Int,
        toIndex destinationIndex: Int
    )
}

extension NewSortingQuizView {
    struct Appearance {
    }
}

final class NewSortingQuizView: UIView {
    let appearance: Appearance
    weak var delegate: NewSortingQuizViewDelegate?

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

    private(set) var options: [NewSortingQuiz.Option] = []

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

    override func layoutSubviews() {
        super.layoutSubviews()

        print(self.tableView.frame.size)
        print(self.tableView.contentSize)
    }

    func set(options: [NewSortingQuiz.Option]) {
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
        cell.updateConstraintsIfNeeded()

        let option = self.options[indexPath.row]

        cell.tag = option.id
        cell.delegate = self

        cell.configure(
            viewModel: .init(
                text: option.text,
                direction: self.getAvailableNavigationDirection(for: cell, atIndexPath: indexPath)
            )
        )

        return cell
    }

    private func getAvailableNavigationDirection(
        for cell: NewSortingQuizTableViewCell,
        atIndexPath indexPath: IndexPath
    ) -> NewSortingQuizTableViewCell.Direction {
        var direction: NewSortingQuizTableViewCell.Direction = []

        if indexPath.row != 0 {
            direction.insert(.top)
        }

        if indexPath.row != self.options.count - 1 {
            direction.insert(.bottom)
        }

        return direction
    }
}

extension NewSortingQuizView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}

extension NewSortingQuizView: NewSortingQuizTableViewCellDelegate {
    func newSortingQuizTableViewCellDidLoadContent(_ view: NewSortingQuizTableViewCell) {
        print(#function)
    }

    func newSortingQuizTableViewCellDidRequestMoveTop(_ view: NewSortingQuizTableViewCell) {
        self.move(cell: view, direction: .top)
    }

    func newSortingQuizTableViewCellDidRequestMoveDown(_ view: NewSortingQuizTableViewCell) {
        self.move(cell: view, direction: .bottom)
    }

    private func move(cell: NewSortingQuizTableViewCell, direction: Direction) {
        guard let option = self.options.first(where: { $0.id == cell.tag }),
              let sourceIndex = self.options.firstIndex(where: { $0.id == option.id }) else {
            return
        }

        let destinationIndex = direction == .top ? sourceIndex - 1 : sourceIndex + 1
        let destinationIndexPath = IndexPath(row: destinationIndex, section: 0)
        let sourceIndexPath = IndexPath(row: sourceIndex, section: 0)

        self.tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)

        self.options.remove(at: sourceIndex)
        self.options.insert(option, at: destinationIndex)

        cell.updateNavigation(self.getAvailableNavigationDirection(for: cell, atIndexPath: destinationIndexPath))
        if let affectedCell = self.tableView.cellForRow(at: sourceIndexPath) as? NewSortingQuizTableViewCell {
            affectedCell.updateNavigation(
                self.getAvailableNavigationDirection(for: affectedCell, atIndexPath: sourceIndexPath)
            )
        }

        self.delegate?.newSortingQuizView(self, didMoveOption: option, atIndex: sourceIndex, toIndex: destinationIndex)
    }

    private enum Direction {
        case top
        case bottom
    }
}
