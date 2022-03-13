import UIKit

protocol CertificatesListTableViewAdapterDelegate: AnyObject {
//    func courseSearchResultsTableViewAdapter(
//        _ adapter: CourseSearchResultsTableViewAdapter,
//        didSelectSearchResult searchResult: CourseSearchResultViewModel,
//        at indexPath: IndexPath
//    )
//    func courseSearchResultsTableViewAdapterDidRequestPagination(
//        _ adapter: CourseSearchResultsTableViewAdapter
//    )
//    func courseSearchResultsTableViewAdapter(
//        _ adapter: CourseSearchResultsTableViewAdapter,
//        didSelectCover searchResult: CourseSearchResultViewModel,
//        at indexPath: IndexPath
//    )
//    func courseSearchResultsTableViewAdapter(
//        _ adapter: CourseSearchResultsTableViewAdapter,
//        didSelectComment searchResult: CourseSearchResultViewModel,
//        at indexPath: IndexPath
//    )
//    func courseSearchResultsTableViewAdapter(
//        _ adapter: CourseSearchResultsTableViewAdapter,
//        didSelectCommentUser searchResult: CourseSearchResultViewModel,
//        at indexPath: IndexPath
//    )
}

final class CertificatesListTableViewAdapter: NSObject {
    weak var delegate: CertificatesListTableViewAdapterDelegate?

    var viewModels: [CertificatesListItemViewModel]

    var canTriggerPagination = false

    init(
        viewModels: [CertificatesListItemViewModel] = [],
        delegate: CertificatesListTableViewAdapterDelegate? = nil
    ) {
        self.viewModels = viewModels
        self.delegate = delegate
        super.init()
    }
}

extension CertificatesListTableViewAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { self.viewModels.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CertificatesListTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()

        let viewModel = self.viewModels[indexPath.row]
        cell.configure(viewModel: viewModel)

        return cell
    }
}

extension CertificatesListTableViewAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        self.delegate?.courseSearchResultsTableViewAdapter(
//            self,
//            didSelectSearchResult: self.viewModels[indexPath.row],
//            at: indexPath
//        )
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard self.canTriggerPagination && (indexPath.row == self.viewModels.count - 1) else {
            return
        }

        //self.delegate?.courseSearchResultsTableViewAdapterDidRequestPagination(self)
    }
}
