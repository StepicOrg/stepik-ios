import UIKit

protocol CourseSearchSuggestionsTableViewAdapterDelegate: AnyObject {
    func courseSearchSuggestionTableViewAdapter(
        _ adapter: CourseSearchSuggestionsTableViewAdapter,
        didSelectSuggestion suggestion: CourseSearchSuggestionViewModel,
        at indexPath: IndexPath
    )
}

final class CourseSearchSuggestionsTableViewAdapter: NSObject {
    weak var delegate: CourseSearchSuggestionsTableViewAdapterDelegate?

    var viewModels: [CourseSearchSuggestionViewModel]
    var query: String

    init(
        viewModels: [CourseSearchSuggestionViewModel] = [],
        query: String = "",
        delegate: CourseSearchSuggestionsTableViewAdapterDelegate? = nil
    ) {
        self.viewModels = viewModels
        self.query = query
        self.delegate = delegate
        super.init()
    }
}

extension CourseSearchSuggestionsTableViewAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { self.viewModels.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CourseSearchSuggestionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()

        let viewModel = self.viewModels[indexPath.row]
        cell.configure(suggestion: viewModel.title, query: self.query)

        return cell
    }
}

extension CourseSearchSuggestionsTableViewAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.courseSearchSuggestionTableViewAdapter(
            self,
            didSelectSuggestion: self.viewModels[indexPath.row],
            at: indexPath
        )
    }
}
