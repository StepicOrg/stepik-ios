import UIKit

protocol CourseSearchResultsTableViewAdapterDelegate: AnyObject {
    func courseSearchResultsTableViewAdapter(
        _ adapter: CourseSearchResultsTableViewAdapter,
        didSelectSearchResult searchResult: CourseSearchResultViewModel,
        at indexPath: IndexPath
    )
    func courseSearchResultsTableViewAdapterDidRequestPagination(
        _ adapter: CourseSearchResultsTableViewAdapter
    )
    func courseSearchResultsTableViewAdapter(
        _ adapter: CourseSearchResultsTableViewAdapter,
        didSelectCover searchResult: CourseSearchResultViewModel,
        at indexPath: IndexPath
    )
    func courseSearchResultsTableViewAdapter(
        _ adapter: CourseSearchResultsTableViewAdapter,
        didSelectComment searchResult: CourseSearchResultViewModel,
        at indexPath: IndexPath
    )
    func courseSearchResultsTableViewAdapter(
        _ adapter: CourseSearchResultsTableViewAdapter,
        didSelectCommentUser searchResult: CourseSearchResultViewModel,
        at indexPath: IndexPath
    )
}

final class CourseSearchResultsTableViewAdapter: NSObject {
    weak var delegate: CourseSearchResultsTableViewAdapterDelegate?

    var viewModels: [CourseSearchResultViewModel]

    var canTriggerPagination = false

    init(
        viewModels: [CourseSearchResultViewModel] = [],
        delegate: CourseSearchResultsTableViewAdapterDelegate? = nil
    ) {
        self.viewModels = viewModels
        self.delegate = delegate
        super.init()
    }
}

extension CourseSearchResultsTableViewAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { self.viewModels.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CourseSearchResultTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()

        let viewModel = self.viewModels[indexPath.row]
        cell.configure(viewModel: viewModel)

        cell.onCoverClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseSearchResultsTableViewAdapter(
                strongSelf,
                didSelectCover: viewModel,
                at: indexPath
            )
        }
        cell.onCommentClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseSearchResultsTableViewAdapter(
                strongSelf,
                didSelectComment: viewModel,
                at: indexPath
            )
        }
        cell.onCommentUserAvatarClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.courseSearchResultsTableViewAdapter(
                strongSelf,
                didSelectCommentUser: viewModel,
                at: indexPath
            )
        }

        return cell
    }
}

extension CourseSearchResultsTableViewAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.courseSearchResultsTableViewAdapter(
            self,
            didSelectSearchResult: self.viewModels[indexPath.row],
            at: indexPath
        )
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard self.canTriggerPagination && (indexPath.row == self.viewModels.count - 1) else {
            return
        }

        self.delegate?.courseSearchResultsTableViewAdapterDidRequestPagination(self)
    }
}
