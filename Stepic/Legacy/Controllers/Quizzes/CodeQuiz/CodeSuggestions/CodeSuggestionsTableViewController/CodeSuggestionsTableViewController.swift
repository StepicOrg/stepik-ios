import UIKit

protocol CodeSuggestionDelegate: AnyObject {
    var suggestionsSize: CodeSuggestionsSize { get }

    func didSelectSuggestion(suggestion: String, prefix: String)
}

final class CodeSuggestionsTableViewController: UITableViewController {
    private static let defaultSuggestionHeight: CGFloat = 22
    private static let maxSuggestionCount = 4

    weak var delegate: CodeSuggestionDelegate?

    private var suggestionRowHeight: CGFloat {
        if let size = self.delegate?.suggestionsSize {
            return size.realSizes.suggestionHeight
        } else {
            return Self.defaultSuggestionHeight
        }
    }

    var suggestions: [String] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }

    var prefix: String = "" {
        didSet {
            self.tableView.reloadData()
        }
    }

    var suggestionsHeight: CGFloat {
        self.suggestionRowHeight * CGFloat(min(Self.maxSuggestionCount, self.suggestions.count))
    }

    init(suggestions: [String] = [], prefix: String = "") {
        self.suggestions = suggestions
        self.prefix = prefix
        super.init(style: .plain)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(cellClass: CodeSuggestionTableViewCell.self)

        self.tableView.separatorStyle = .singleLine
        self.tableView.separatorInset = .zero

        self.tableView.allowsSelection = false
        self.clearsSelectionOnViewWillAppear = false
        self.tableView.rowHeight = self.suggestionRowHeight

        //Adding tap gesture recognizer to catch selection to avoid resignFirstResponder call and keyboard disappearance
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.didTap(recognizer:))
        )
        self.tableView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.suggestions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CodeSuggestionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()

        cell.setSuggestion(
            self.suggestions[indexPath.row],
            prefixLength: self.prefix.count,
            size: self.delegate?.suggestionsSize
        )

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.suggestionRowHeight
    }

    // MARK: Private API

    @objc
    private func didTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: location)

        guard let row = indexPath?.row else {
            return
        }

        self.delegate?.didSelectSuggestion(suggestion: self.suggestions[row], prefix: self.prefix)
    }
}
