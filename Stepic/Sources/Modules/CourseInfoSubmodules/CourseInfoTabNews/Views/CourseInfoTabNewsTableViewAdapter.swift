import UIKit

protocol CourseInfoTabNewsTableViewAdapterDelegate: AnyObject {
    func courseInfoTabNewsTableViewAdapter(
        _ adapter: CourseInfoTabNewsTableViewAdapter,
        scrollViewDidScroll scrollView: UIScrollView
    )
    func courseInfoTabNewsTableViewAdapterDidRequestPagination(
        _ adapter: CourseInfoTabNewsTableViewAdapter
    )
    func courseInfoTabNewsTableViewAdapter(
        _ adapter: CourseInfoTabNewsTableViewAdapter,
        didRequestOpenURL url: URL
    )
    func courseInfoTabNewsTableViewAdapter(
        _ adapter: CourseInfoTabNewsTableViewAdapter,
        didRequestOpenImage url: URL
    )
}

final class CourseInfoTabNewsTableViewAdapter: NSObject {
    // For smooth table view update animation
    private static let tableViewUpdatesDelay: TimeInterval = 0.33

    weak var delegate: CourseInfoTabNewsTableViewAdapterDelegate?

    var viewModels: [CourseInfoTabNewsViewModel]

    var canTriggerPagination = false

    /// Caches cells heights
    private var cellHeightCache: [UniqueIdentifierType: CGFloat] = [:]
    /// Need for dynamic cell layouts & variable row heights where web view support not needed
    private var prototypeCell: CourseInfoTabNewsTableViewCell?
    /// Accumulates multiple table view updates into one invocation
    private var pendingTableViewUpdateWorkItem: DispatchWorkItem?

    init(viewModels: [CourseInfoTabNewsViewModel] = [], delegate: CourseInfoTabNewsTableViewAdapterDelegate? = nil) {
        self.viewModels = viewModels
        self.delegate = delegate
        super.init()
    }
}

// MARK: - CourseInfoTabNewsTableViewAdapter: UITableViewDataSource -

extension CourseInfoTabNewsTableViewAdapter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CourseInfoTabNewsTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()

        self.configureCell(cell, at: indexPath, tableView: tableView)

        return cell
    }

    // MARK: Private Helpers

    private func configureCell(
        _ cell: CourseInfoTabNewsTableViewCell,
        at indexPath: IndexPath,
        tableView: UITableView
    ) {
        let viewModel = self.viewModels[indexPath.row]
        let viewModelUniqueIdentifier = viewModel.uniqueIdentifier

        cell.onContentLoaded = { [weak self, weak cell, weak tableView] in
            guard let strongSelf = self, let strongCell = cell, let strongTableView = tableView else {
                return
            }

            let fittingSize = CGSize(width: strongTableView.bounds.width, height: .infinity)
            let cellSize = strongCell.sizeThatFits(fittingSize)

            strongSelf.updateCellHeight(
                cellSize.height,
                viewModelUniqueIdentifier: viewModelUniqueIdentifier,
                tableView: strongTableView
            )
        }
        cell.onNewHeightUpdate = { [weak self, weak tableView] newHeight in
            if let strongSelf = self, let strongTableView = tableView {
                strongSelf.updateCellHeight(
                    newHeight,
                    viewModelUniqueIdentifier: viewModelUniqueIdentifier,
                    tableView: strongTableView
                )
            }
        }
        cell.onLinkClick = { [weak self] url in
            if let strongSelf = self {
                strongSelf.delegate?.courseInfoTabNewsTableViewAdapter(strongSelf, didRequestOpenURL: url)
            }
        }
        cell.onImageClick = { [weak self] url in
            if let strongSelf = self {
                strongSelf.delegate?.courseInfoTabNewsTableViewAdapter(strongSelf, didRequestOpenImage: url)
            }
        }

        cell.configure(viewModel: viewModel)

        if !viewModel.processedContent.isWebViewSupportNeeded {
            let cellSize = cell.sizeThatFits(CGSize(width: tableView.bounds.width, height: .infinity))
            self.cellHeightCache[viewModelUniqueIdentifier] = cellSize.height
        }
    }

    private func updateCellHeight(
        _ newHeight: CGFloat,
        viewModelUniqueIdentifier: UniqueIdentifierType,
        tableView: UITableView
    ) {
        guard self.cellHeightCache[viewModelUniqueIdentifier, default: 0] < newHeight else {
            return
        }

        self.cellHeightCache[viewModelUniqueIdentifier] = newHeight

        let workItem = DispatchWorkItem { [weak self, weak tableView] in
            guard let strongSelf = self,
                  let strongTableView = tableView else {
                return
            }

            guard !strongSelf.viewModels.isEmpty
                  && strongTableView.dataSource != nil else {
                return
            }

            UIView.performWithoutAnimation {
                strongTableView.beginUpdates()
                strongTableView.endUpdates()
            }
        }

        self.pendingTableViewUpdateWorkItem?.cancel()
        self.pendingTableViewUpdateWorkItem = workItem

        DispatchQueue.main.asyncAfter(
            deadline: .now() + Self.tableViewUpdatesDelay,
            execute: workItem
        )
    }
}

// MARK: - CourseInfoTabNewsTableViewAdapter: UITableViewDelegate -

extension CourseInfoTabNewsTableViewAdapter: UITableViewDelegate {
    private static let estimatedRowHeight: CGFloat = 150

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.courseInfoTabNewsTableViewAdapter(self, scrollViewDidScroll: scrollView)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard self.canTriggerPagination && (indexPath.row == self.viewModels.count - 1) else {
            return
        }

        self.delegate?.courseInfoTabNewsTableViewAdapterDidRequestPagination(self)
    }

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool { false }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? { nil }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height: CGFloat = {
            guard let viewModel = self.viewModels[safe: indexPath.row] else {
                return Self.estimatedRowHeight
            }

            if let cellHeight = self.cellHeightCache[viewModel.uniqueIdentifier] {
                return cellHeight
            }

            if !viewModel.processedContent.isWebViewSupportNeeded {
                let prototypeCell = self.getPrototypeCell(tableView: tableView)
                self.configureCell(prototypeCell, at: indexPath, tableView: tableView)
                prototypeCell.layoutIfNeeded()

                let cellSize = prototypeCell.sizeThatFits(CGSize(width: tableView.bounds.width, height: .infinity))
                self.cellHeightCache[viewModel.uniqueIdentifier] = cellSize.height

                return cellSize.height
            }

            return Self.estimatedRowHeight
        }()

        return height
    }

    // MARK: Private Helpers

    private func getPrototypeCell(tableView: UITableView) -> CourseInfoTabNewsTableViewCell {
        if let prototypeCell = self.prototypeCell {
            return prototypeCell
        }

        let prototypeCell = CourseInfoTabNewsTableViewCell()
        prototypeCell.updateConstraintsIfNeeded()

        self.prototypeCell = prototypeCell

        return prototypeCell
    }
}
