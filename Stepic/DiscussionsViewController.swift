//
//  DiscussionsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SDWebImage
import DZNEmptyDataSet

enum DiscussionsEmptyDataSetState {
    case Error, Empty, None
}

enum SeparatorType {
    case Small, Big, None
}

struct DiscussionsCellInfo {
    var comment: Comment?
    var loadRepliesFor: Comment?
    var loadDiscussions: Bool?
    var separatorType: SeparatorType = .None
    
    init(comment: Comment, separatorType: SeparatorType) {
        self.comment = comment
        self.separatorType = separatorType
    }
    
    init(loadRepliesFor: Comment) {
        self.loadRepliesFor = loadRepliesFor
    }
    
    init(loadDiscussions: Bool) {
        self.loadDiscussions = loadDiscussions
    }
}

class DiscussionsViewController: UIViewController {

    var discussionProxyId: String!
    var target: Int!
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl : UIRefreshControl? = UIRefreshControl()
    
    var cellsInfo = [DiscussionsCellInfo]()
    
    var emptyDatasetState : DiscussionsEmptyDataSetState = .None {
        didSet {
            tableView.reloadEmptyDataSet()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("did load")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        emptyDatasetState = .None
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        tableView.tableFooterView = UIView()
        
        tableView.registerNib(UINib(nibName: "DiscussionTableViewCell", bundle: nil), forCellReuseIdentifier: "DiscussionTableViewCell")
        tableView.registerNib(UINib(nibName: "LoadMoreTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTableViewCell")
        tableView.registerNib(UINib(nibName: "DiscussionWebTableViewCell", bundle: nil), forCellReuseIdentifier: "DiscussionWebTableViewCell")
        
        self.title = NSLocalizedString("Discussions", comment: "")
        
        let writeCommentItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: #selector(DiscussionsViewController.writeCommentPressed))
        self.navigationItem.rightBarButtonItem = writeCommentItem
        
        refreshControl?.addTarget(self, action: #selector(DiscussionsViewController.reloadDiscussions), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl ?? UIView())
        refreshControl?.beginRefreshing()
        reloadDiscussions()
    }

    struct DiscussionIds {
        var all = [Int]()
        var loaded = [Int]()
        
        var leftToLoad : Int {
            return all.count - loaded.count
        }
    }
    
    struct Replies {
        var loaded = [Int : [Comment]]()
        
        func leftToLoad(comment: Comment) -> Int {
            if let loadedCount = loaded[comment.id]?.count {
                return comment.repliesIds.count - loadedCount
            } else {
                return comment.repliesIds.count
            }
        }
    }
    
    var discussionIds = DiscussionIds()
    var replies = Replies()
    var discussions = [Comment]()
    var votes = [String: Vote]()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func writeCommentPressed() {
        presentWriteCommentController(parent: nil)
    }
    
    func resetData(withReload: Bool) {
        discussionIds = DiscussionIds()
        replies = Replies()
        discussions = [Comment]()
        estimatedHeightForDiscussionId = [:]
        
        if withReload {
            self.reloadTableData()
        }
    }
    
    let discussionLoadingInterval = 10
    let repliesLoadingInterval = 10
    
    func getNextDiscussionIdsToLoad() -> [Int] {
        let startIndex = discussionIds.loaded.count
        return Array(discussionIds.all[startIndex ..< startIndex + min(discussionLoadingInterval, discussionIds.leftToLoad)])
    }
    
    func getNextReplyIdsToLoad(section: Int) -> [Int] {
        if discussions.count <= section {
            return []
        } 
        let discussion = discussions[section]

        return getNextReplyIdsToLoad(discussion)
    }
    
    func getNextReplyIdsToLoad(discussion: Comment) -> [Int] {
        let loadedIds : [Int] = replies.loaded[discussion.id]?.map({return $0.id}) ?? []
        let loadedReplies = Set<Int>(loadedIds)
        var res : [Int] = []
        
        for replyId in discussion.repliesIds {
            if !loadedReplies.contains(replyId) {
                res += [replyId]
                if res.count == repliesLoadingInterval {
                    return res
                }
            }
        }
        return res
    }
    
    
    
    func loadDiscussions(ids: [Int], success: (Void -> Void)? = nil) {
        self.emptyDatasetState = .None
        
        ApiDataDownloader.comments.retrieve(ids, success: 
            {
                [weak self]
                retrievedDiscussions in 
                
                if let s = self {
                    //get superDiscussions (those who have no parents)
                    let superDiscussions = Sorter.sort(retrievedDiscussions.filter({$0.parentId == nil}), byIds: ids, canMissElements: true)
                
                    s.discussionIds.loaded += ids
                    s.discussions += superDiscussions
                    
                    var changedDiscussionIds = Set<Int>()
                    //get all replies
                    for reply in retrievedDiscussions.filter({$0.parentId != nil}) {
                        if let parentId = reply.parentId {
                            if s.replies.loaded[parentId] == nil {
                                s.replies.loaded[parentId] = []
                            }
                            s.replies.loaded[parentId]? += [reply]
                            changedDiscussionIds.insert(parentId)
                        }
                    }
                    
                    //TODO: Possibly should sort all changed reply values 
                    for discussionId in changedDiscussionIds {
                        if let index = s.discussions.indexOf({$0.id == discussionId}) {
                            s.replies.loaded[discussionId]! = Sorter.sort(s.replies.loaded[discussionId]!, byIds: s.discussions[index].repliesIds, canMissElements: true)
                        }
                    }
                                        
                    success?()
                }
            }, error: {
                [weak self]
                errorString in
                print(errorString)
                self?.emptyDatasetState = .Error
                UIThread.performUI {
                    [weak self] in
                    self?.refreshControl?.endRefreshing()
                }
            }
        )
    }
    
    func reloadTableData(emptyState: DiscussionsEmptyDataSetState = .Empty) {
        //TODO: Create comments list here, then reload tableView data
        cellsInfo = []
        for discussion in discussions {
            let c = DiscussionsCellInfo(comment: discussion, separatorType: .Small)
            cellsInfo.append(c)
//            constructDiscussionCell(c)
            
            for reply in replies.loaded[discussion.id] ?? [] {
                let c = DiscussionsCellInfo(comment: reply, separatorType: .Small)
                cellsInfo.append(c)
//                constructDiscussionCell(c)
            }
            
            let left = replies.leftToLoad(discussion)
            if left > 0 {
                cellsInfo.append(DiscussionsCellInfo(loadRepliesFor: discussion))
            } else {
                cellsInfo[cellsInfo.count - 1].separatorType = .Big
            }
        }
        
        if discussionIds.leftToLoad > 0 {
            cellsInfo.append(DiscussionsCellInfo(loadDiscussions: true))
        }
        
        UIThread.performUI({
            [weak self] in
            if self?.cellsInfo.count == 0 {                
                self?.tableView.emptyDataSetSource = self
                self?.emptyDatasetState = emptyState
            } else {
                self?.tableView.emptyDataSetSource = nil
            }
            self?.tableView.reloadData()
        })
    }
    
    
    var isReloading: Bool = false
    
    func reloadDiscussions() {
        emptyDatasetState = .None
        if isReloading {
            return
        }
        resetData(false)
        isReloading = true
//        self.discussionIds.all = [0, 1, 2]
//        self.discussionIds.loaded = [0, 1, 2]
//        userInfos[10] = UserInfo(sample: true)
//        
//        
//        discussions = []
//
//        for i in 0 ..< 3 {
//            discussions += [Comment(sampleId: i)]
//        }
//        
//        self.refreshControl?.endRefreshing()
//        self.reloadTableData()
//        self.isReloading = false
//        return;
        
        AuthentificationManager.sharedManager.autoRefreshToken(success: {
            [weak self] in
            if let discussionProxyId = self?.discussionProxyId {
                ApiDataDownloader.discussionProxies.retrieve(discussionProxyId, success: 
                    {
                        [weak self] 
                        discussionProxy in
                        self?.discussionIds.all = discussionProxy.discussionIds
                        if let discussionIdsToLoad = self?.getNextDiscussionIdsToLoad() {
                            self?.loadDiscussions(discussionIdsToLoad, success: 
                                {            
                                    [weak self] in
                                    UIThread.performUI {
                                        self?.refreshControl?.endRefreshing()
                                        self?.reloadTableData()
                                        self?.isReloading = false
                                    }
                                }
                            )
                        }
                    }, error: {
                        [weak self]
                        errorString in
                        print(errorString)
                        self?.isReloading = false
                        self?.reloadTableData(.Error)
                        UIThread.performUI {
                            [weak self] in
                            self?.refreshControl?.endRefreshing()
                        }
                    }
                
                )
            }
        }, failure:  {
                [weak self]
                errorString in
                print(errorString)
                self?.isReloading = false
                self?.reloadTableData(.Error)
                UIThread.performUI {
                    [weak self] in
                    self?.refreshControl?.endRefreshing()
                }
        })
    }
    
    func isShowMoreEnabledForSection(section: Int) -> Bool {
        if discussions.count <= section  {
            return false
        }
        
        let discussion = discussions[section]
        return replies.leftToLoad(discussion) > 0 
    }
    
    func isShowMoreDiscussionsEnabled() -> Bool {
        return discussionIds.leftToLoad > 0
    }
    
    func setLiked(comment: Comment, cell: UITableViewCell) {
        if let c = cell as? DiscussionTableViewCell {
            if let value = comment.vote.value {
                let vToSet : VoteValue? = (value == VoteValue.Epic) ? nil : .Epic
                let v = Vote(id: comment.vote.id, value: vToSet)
                ApiDataDownloader.votes.update(v, success: 
                    {
                        vote in
                        comment.vote = vote
                        switch value {
                        case .Abuse: 
                            comment.abuseCount -= 1
                            comment.epicCount += 1
                            c.setLiked(true, likesCount: comment.epicCount)
                        case .Epic:
                            comment.epicCount -= 1
                            c.setLiked(false, likesCount: comment.epicCount)
                        }
                    }, error: {
                        errorMsg in
                        print(errorMsg)
                })
            } else {
                let v = Vote(id: comment.vote.id, value: .Epic)
                ApiDataDownloader.votes.update(v, success: 
                    {
                        vote in
                        comment.vote = vote
                        comment.epicCount += 1
                        c.setLiked(true, likesCount: comment.epicCount)
                    }, error: {
                        errorMsg in
                        print(errorMsg)
                    }
                )
                
            }
        }
    }
    
    func setAbused(comment: Comment, cell: UITableViewCell) {
        if let c = cell as? DiscussionTableViewCell {
            if let value = comment.vote.value {
                let v = Vote(id: comment.vote.id, value: .Abuse)
                ApiDataDownloader.votes.update(v, success: 
                    {
                        vote in
                        comment.vote = vote
                        switch value {
                        case .Abuse: 
                            break
                        case .Epic:
                            comment.epicCount -= 1
                            comment.abuseCount += 1
                            c.setLiked(false, likesCount: comment.epicCount)
                        }
                    }, error: {
                        errorMsg in
                        print(errorMsg)
                })
            } else {
                let v = Vote(id: comment.vote.id, value: .Abuse)
                ApiDataDownloader.votes.update(v, success: 
                    {
                        vote in
                        comment.vote = vote
                        comment.abuseCount += 1
                    }, error: {
                        errorMsg in
                        print(errorMsg)
                    }
                )
                
            }
        }
    }
    
    func handleSelectDiscussion(comment: Comment, cell: UITableViewCell, completion: (Void->Void)?) {
        let alert = DiscussionAlertConstructor.getCommentAlert(comment, 
            replyBlock: {
                [weak self] in
                self?.presentWriteCommentController(parent: comment.parentId ?? comment.id)
            }, likeBlock: {
                [weak self] in
                self?.setLiked(comment, cell: cell)
            }, abuseBlock:  {
                [weak self] in
                self?.setAbused(comment, cell: cell)
            }, openURLBlock:  {
                [weak self] 
                url in     
                if let s = self {
                    WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: s, withKey: "external link", allowsSafari: true, backButtonStyle: BackButtonStyle.Close)
                }
            }
        )
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = cell.contentView
            popoverController.sourceRect = cell.contentView.bounds
        }
        
        self.presentViewController(alert, animated: true, completion: {
            completion?()
        })
    }
    
    func presentWriteCommentController(parent parent: Int?) {
        if let writeController = ControllerHelper.instantiateViewController(identifier: "WriteCommentViewController", storyboardName: "DiscussionsStoryboard") as? WriteCommentViewController {
            writeController.parent = parent
            writeController.target = target
            writeController.delegate = self
            navigationController?.pushViewController(writeController, animated: true)
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    //TODO: Think when to reload this value
    
    var estimatedHeightForDiscussionId = [Int: CGFloat]()
    var webViewHeightForDiscussionId = [Int: CGFloat]()
}

extension DiscussionsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let comment = cellsInfo[indexPath.row].comment {         
            if let est = estimatedHeightForDiscussionId[comment.id] {
                return est
            }
        }
        return 44
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        print("CGFLoat min -> \(CGFloat.min)")
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("did select row at indexPath \(indexPath)")
        if let comment = cellsInfo[indexPath.row].comment {            
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            if let c = cell {
                handleSelectDiscussion(comment, cell: c, completion: {
                    [weak self] in
                    UIThread.performUI { 
                        self?.tableView.deselectRowAtIndexPath(indexPath, animated: true) 
                    }
                })
            }
        }
        
        if let loadRepliesFor = cellsInfo[indexPath.row].loadRepliesFor {
            let idsToLoad = getNextReplyIdsToLoad(loadRepliesFor)
            loadDiscussions(idsToLoad, success: {
                [weak self] in
                UIThread.performUI {
//                    self?.tableView.beginUpdates()
                    //TODO: Change to animated reload
                    self?.reloadTableData()
//                    self?.tableView.endUpdates()
                    self?.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
            })

        }
        
        if let shouldLoadDiscussions = cellsInfo[indexPath.row].loadDiscussions {
            let idsToLoad = getNextDiscussionIdsToLoad()
            loadDiscussions(idsToLoad, success: {
                [weak self] in
                UIThread.performUI {
                    if let s = self {
//                        s.tableView.beginUpdates()
                        self?.reloadTableData()
//                        s.tableView.endUpdates()
                        self?.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    }
                }
            })
        }
    }
}

extension DiscussionsViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellsInfo.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        print("will display cell for \(indexPath.row)")
    }
        
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print("cell for row \(indexPath.row)")
                
        if let comment = cellsInfo[indexPath.row].comment {
            
//            if !TagDetectionUtil.isWebViewSupportNeeded(comment.text) {
                let cell = tableView.dequeueReusableCellWithIdentifier("DiscussionTableViewCell", forIndexPath: indexPath) as! DiscussionTableViewCell

                cell.initWithComment(comment, separatorType: cellsInfo[indexPath.row].separatorType) 
                
                return cell
//            } else {
//                let cell = tableView.dequeueReusableCellWithIdentifier("DiscussionWebTableViewCell", forIndexPath: indexPath) as! DiscussionWebTableViewCell
//                
//                if let user = userInfos[comment.userId] {
//                    if let h = webViewHeightForDiscussionId[comment.id]  {
//                        cell.webContainerViewHeight.constant = h
//                    } else {
//
//                        cell.heightUpdateBlock = {
//                            [weak self] 
//                            height, webViewHeight in
//                            self?.webViewHeightForDiscussionId[comment.id] = webViewHeight
//                            print("height update block for \(indexPath.row) with height \(height)")
//                            dispatch_async(dispatch_get_main_queue(), {
//                                [weak self] in
//                                if self?.estimatedHeightForDiscussionId[comment.id] < height {
//                                    self?.tableView.beginUpdates()
//                                    self?.estimatedHeightForDiscussionId[comment.id] = height
//                                    self?.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
//                                    self?.tableView.endUpdates()
//                                }
//                            })
//                        }
//                    }
//                    cell.initWithComment(comment, user: user, separatorType: cellsInfo[indexPath.row].separatorType) 
//                } 
//                return cell
//
//            }
        } 
        
        if let loadRepliesFor = cellsInfo[indexPath.row].loadRepliesFor {
            print("load replies cell")
            let cell = tableView.dequeueReusableCellWithIdentifier("LoadMoreTableViewCell", forIndexPath: indexPath) as! LoadMoreTableViewCell
            cell.showMoreLabel.text = "\(NSLocalizedString("ShowMoreReplies", comment: ""))(\(replies.leftToLoad(loadRepliesFor)))"
            return cell
        }
        
        if let loadDiscussions = cellsInfo[indexPath.row].loadDiscussions {
            print("load discussions cell")
            let cell = tableView.dequeueReusableCellWithIdentifier("LoadMoreTableViewCell", forIndexPath: indexPath) as! LoadMoreTableViewCell
            cell.showMoreLabel.text = "\(NSLocalizedString("ShowMoreDiscussions", comment: ""))(\(discussionIds.leftToLoad))"
            return cell
        }
        
        return UITableViewCell()
    }
}

extension DiscussionsViewController : WriteCommentDelegate {
    func didWriteComment(comment: Comment) {
        print(comment.parentId)
        if let parentId = comment.parentId {
            //insert row in an existing section
            if let section = discussions.indexOf({$0.id == parentId}) {
                discussions[section].repliesIds += [comment.id]
                if replies.loaded[parentId] == nil {
                    replies.loaded[parentId] = []
                }
                replies.loaded[parentId]! += [comment]
//                tableView.beginUpdates()
                reloadTableData()
//                let p = NSIndexPath(forRow: replies.loaded[parentId]!.count - 1, inSection: section)
//                tableView.insertRowsAtIndexPaths([p], withRowAnimation: .Automatic)
//                tableView.endUpdates()
            }
        } else {
            //insert section
            discussionIds.all.insert(comment.id, atIndex: 0)
            discussionIds.loaded.insert(comment.id, atIndex: 0)
            discussions.insert(comment, atIndex: 0)
//            tableView.beginUpdates()
            reloadTableData()
//            let index = NSIndexSet(index: 0)
//            tableView.insertSections(index, withRowAnimation: .Automatic)
//            tableView.endUpdates()
        }
    }
}

extension DiscussionsViewController : DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        switch emptyDatasetState {
        case .Empty:
            return Images.noCommentsWhite.size200x200
        case .Error:
            return Images.noWifiImage.white
        case .None:
            return Images.noCommentsWhite.size200x200
        }
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        switch emptyDatasetState {
        case .Empty:
            text = NSLocalizedString("NoDiscussionsTitle", comment: "")
            break
        case .Error:
            text = NSLocalizedString("ConnectionErrorTitle", comment: "")
            break
        case .None:
            text = ""
            break
        }
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0),
                          NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        
        switch emptyDatasetState {
        case .Empty:
            text = NSLocalizedString("NoDiscussionsDescription", comment: "")
            break
        case .Error:
            text = NSLocalizedString("ConnectionErrorPullToRefresh", comment: "")
            break
        case .None: 
            text = NSLocalizedString("RefreshingDiscussions", comment: "")
            break
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(14.0),
                          NSForegroundColorAttributeName: UIColor.lightGrayColor(),
                          NSParagraphStyleAttributeName: paragraph]
                
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        //        print("offset -> \((self.navigationController?.navigationBar.bounds.height) ?? 0 + UIApplication.sharedApplication().statusBarFrame.height)")
        return 0
    }
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
}
