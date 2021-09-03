import Foundation

protocol CourseSearchSuggestionTableViewAdapterDelegate: AnyObject {
    func courseSearchSuggestionTableViewAdapter(
        _ adapter: CourseSearchSuggestionTableViewAdapter,
        didSelectSuggestion: CourseSearchSuggestionViewModel,
        at indexPath: IndexPath
    )
}

final class CourseSearchSuggestionTableViewAdapter: NSObject {
    weak var delegate: CourseSearchSuggestionTableViewAdapterDelegate?

    var viewModels: [CourseSearchSuggestionViewModel]
    var query: String

    init(
        viewModels: [CourseSearchSuggestionViewModel] = [],
        query: String = "",
        delegate: CourseSearchSuggestionTableViewAdapterDelegate? = nil
    ) {
        self.viewModels = viewModels
        self.query = query
        self.delegate = delegate
        super.init()
    }
}

extension CourseSearchSuggestionTableViewAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { self.viewModels.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CourseSearchSuggestionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()

        let viewModel = self.viewModels[indexPath.row]
        cell.configure(suggestion: viewModel.title, query: self.query)

        return cell
    }
}

extension CourseSearchSuggestionTableViewAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.courseSearchSuggestionTableViewAdapter(
            self,
            didSelectSuggestion: self.viewModels[indexPath.row],
            at: indexPath
        )
    }
}
