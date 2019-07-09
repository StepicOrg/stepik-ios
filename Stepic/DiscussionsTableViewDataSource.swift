import UIKit

final class DiscussionsTableViewDataSource: NSObject {
    weak var delegate: DiscussionsViewControllerDelegate?
    
    var viewDatas = [DiscussionsViewData]()
    
    init(viewDatas: [DiscussionsViewData] = []) {
        self.viewDatas = viewDatas
        super.init()
    }
}

extension DiscussionsTableViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewData = self.viewDatas[safe: indexPath.row] else {
            return UITableViewCell()
        }
        
        if viewData.comment != nil {
            let cell: DiscussionTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(viewData: viewData)
            cell.onProfileButtonClick = { [weak self] userId in
                self?.delegate?.profileButtonDidClick(userId)
            }
            return cell
        } else if viewData.fetchRepliesFor != nil || viewData.needFetchDiscussions {
            let cell: LoadMoreTableViewCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(viewData: viewData)
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

extension DiscussionsTableViewDataSource: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard let viewData = self.viewDatas[safe: indexPath.row] else {
            return
        }
        
        self.delegate?.cellDidSelect(viewData)
    }
}
