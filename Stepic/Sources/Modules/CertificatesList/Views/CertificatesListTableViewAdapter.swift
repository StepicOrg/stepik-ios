import UIKit

protocol CertificatesListTableViewAdapterDelegate: AnyObject {
    func certificatesListTableViewAdapter(
        _ adapter: CertificatesListTableViewAdapter,
        didSelectCertificate certificate: CertificatesListItemViewModel,
        at indexPath: IndexPath
    )
    func certificatesListTableViewAdapterDidRequestPagination(_ adapter: CertificatesListTableViewAdapter)
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

        cell.onCellViewClick = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.certificatesListTableViewAdapter(
                strongSelf,
                didSelectCertificate: viewModel,
                at: indexPath
            )
        }

        return cell
    }
}

extension CertificatesListTableViewAdapter: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard self.canTriggerPagination && (indexPath.row == self.viewModels.count - 1) else {
            return
        }

        self.delegate?.certificatesListTableViewAdapterDidRequestPagination(self)
    }
}
