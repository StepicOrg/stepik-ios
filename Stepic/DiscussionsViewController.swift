//
//  DiscussionsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SDWebImage

class DiscussionsViewController: UIViewController {

    var discussionProxyId: String!
    var target: Int!
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl : UIRefreshControl? = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        print("did load")
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        tableView.registerNib(UINib(nibName: "DiscussionTableViewCell", bundle: nil), forCellReuseIdentifier: "DiscussionTableViewCell")
        tableView.registerNib(UINib(nibName: "LoadMoreTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTableViewCell")
        
        //TODO: Do NOT forget to localize this!
        self.title = "Discussions"
        
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
    var userInfos = [Int: UserInfo]()
    var discussions = [Comment]()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func writeCommentPressed() {
        print("write comment pressed")
        presentWriteCommentController(parent: nil)
    }
    
    func resetData(withReload: Bool) {
        discussionIds = DiscussionIds()
        replies = Replies()
        userInfos = [Int: UserInfo]()
        discussions = [Comment]()

        if withReload {
            tableView.reloadData()
        }
    }
    
    let discussionLoadingInterval = 20
    let repliesLoadingInterval = 20
    
    func getNextDiscussionIdsToLoad() -> [Int] {
        let startIndex = discussionIds.loaded.count
        return Array(discussionIds.all[startIndex ..< startIndex + min(discussionLoadingInterval, discussionIds.leftToLoad)])
    }
    
    func getNextReplyIdsToLoad(section: Int) -> [Int] {
        if discussions.count <= section {
            return []
        } 
        let discussion = discussions[section]
//        let startIndex = replies.loaded[discussion.id]?.count ?? 0
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
        
//        return Array(discussion.repliesIds[startIndex ..< startIndex + min(repliesLoadingInterval, replies.leftToLoad(discussion))])
    }
    
    func loadDiscussions(ids: [Int], success: (Void -> Void)? = nil) {
        ApiDataDownloader.comments.retrieve(ids, success: 
            {
                [weak self]
                retrievedDiscussions, retrievedUserInfos in 
                
                if let s = self {
                    //get superDiscussions (those who have no parents)
                    let superDiscussions = Sorter.sort(retrievedDiscussions.filter({$0.parentId == nil}), byIds: ids, canMissElements: true)
                
                    s.discussionIds.loaded += ids
                    s.discussions += superDiscussions
                    
                    for (userId, info) in retrievedUserInfos {
                        s.userInfos[userId] = info
                    }
                    
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
                    
                    UIThread.performUI { 
                        s.updateTableFooterView() 
                    }
                }
            }, error: {
                errorString in
                print(errorString)
            }
        )
    }
    
    func updateTableFooterView() {
        if isShowMoreDiscussionsEnabled() {
            let cell = NSBundle.mainBundle().loadNibNamed("LoadMoreTableViewCell", owner: self, options: nil)[0]  as! LoadMoreTableViewCell
            
            let v = cell.contentView
            let tapG = UITapGestureRecognizer()
            tapG.addTarget(self, action: #selector(DiscussionsViewController.didTapTableViewFooter(_:)))
            v.addGestureRecognizer(tapG)
            
            tableView.tableFooterView = v
        } else {
            tableView.tableFooterView = nil
        }
    }
    
    var isReloading: Bool = false
    func reloadDiscussions() {
        if isReloading {
            return
        }
        resetData(false)
        isReloading = true
        ApiDataDownloader.discussionProxies.retrieve(discussionProxyId, success: 
            {
                [weak self] 
                discussionProxy in
                self?.discussionIds.all = discussionProxy.discussionIds
                print("retrieved discussionIds -> \(discussionProxy.discussionIds)")
                if let discussionIdsToLoad = self?.getNextDiscussionIdsToLoad() {
                    self?.loadDiscussions(discussionIdsToLoad, success: 
                        {            
                            [weak self] in
                            UIThread.performUI {
                                self?.refreshControl?.endRefreshing()
                                self?.tableView.reloadData()
                                self?.isReloading = false
                            }
                        }
                    )
                }
            }, error: {
                errorString in
                print(errorString)
            }
        )
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
    
    func handleSelectDiscussion(comment: Comment, completion: (Void->Void)?) {
        print("selected discussion with id: \(comment.id), text: \(comment.text) and parent: \(comment.parentId)")
        let alert = DiscussionAlertConstructor.getReplyAlert({
            [weak self] in
            self?.presentWriteCommentController(parent: comment.parentId ?? comment.id)
        })
        
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
    
}

extension DiscussionsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isShowMoreEnabledForSection(section) {
            return 50
        } else {
            return 0.5
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
}

extension DiscussionsViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return discussions.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection \(section)")
        return replies.loaded[discussions[section].id]?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DiscussionTableViewCell", forIndexPath: indexPath) as! DiscussionTableViewCell
        
        if discussions.count > indexPath.section && replies.loaded[discussions[indexPath.section].id]?.count > indexPath.row {
            if let comment = replies.loaded[discussions[indexPath.section].id]?[indexPath.row] {
                if let user = userInfos[comment.userId] {
                    cell.initWithComment(comment, user: user)
                    cell.indexPath = indexPath
                    cell.delegate = self
                }
            }
        } else {
            //TODO: Maybe should handle double refresh somehow
//            print("that was a double refresh")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCellWithIdentifier("DiscussionTableViewCell") as! DiscussionTableViewCell
        
        if discussions.count <= section  {
            return nil
        }
        
        let comment = discussions[section]
        if let user = userInfos[comment.userId] {
            cell.initWithComment(comment, user: user)
            let v = cell.contentView
            v.tag = section
            let tapG = UITapGestureRecognizer()
            tapG.addTarget(self, action: #selector(DiscussionsViewController.didTapHeader(_:)))
            v.addGestureRecognizer(tapG)
            
            return v
        } else {
            return nil
        }
    }
    
    func didTapTableViewFooter(gestureRecognizer: UITapGestureRecognizer) {
        print("did tap TableView footer")
        if let v = gestureRecognizer.view {
            let refreshView = CellOperationsUtil.addRefreshView(v, backgroundColor: tableView.backgroundColor!)
            update(section: nil, completion: {
                refreshView.removeFromSuperview()
            })
        }
    }
    
    func didTapHeader(gestureRecognizer: UITapGestureRecognizer) {
        print("did tap section header \(gestureRecognizer.view?.tag)")
        if let v = gestureRecognizer.view {
            let section = v.tag
            let deselectBlock = CellOperationsUtil.animateViewSelection(v)
            if discussions.count > section {
                let comment = discussions[section]
                handleSelectDiscussion(comment, completion: deselectBlock)
            } else {
                deselectBlock()
            }
        }
    }
    
    func didTapFooter(gestureRecognizer: UITapGestureRecognizer) {
        print("did tap section footer\(gestureRecognizer.view?.tag)")
        if let v = gestureRecognizer.view {
            let refreshView = CellOperationsUtil.addRefreshView(v, backgroundColor: tableView.backgroundColor!)
            update(section: v.tag, completion: {
                refreshView.removeFromSuperview()
            })
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isShowMoreEnabledForSection(section) {
            let cell = NSBundle.mainBundle().loadNibNamed("LoadMoreTableViewCell", owner: self, options: nil)[0]  as! LoadMoreTableViewCell
            
            let v = cell.contentView
            v.tag = section
            let tapG = UITapGestureRecognizer()
            tapG.addTarget(self, action: #selector(DiscussionsViewController.didTapFooter(_:)))
            v.addGestureRecognizer(tapG)
            
            return v
        } else {
            return nil
        }
    }
}

extension DiscussionsViewController : DiscussionUpdateDelegate {
    func update(section section: Int?, completion: (Void->Void)?) {
        if let s = section {
            let idsToLoad = getNextReplyIdsToLoad(s)
            loadDiscussions(idsToLoad, success: {
                [weak self] in
                UIThread.performUI {
                    self?.tableView.beginUpdates()
                    self?.tableView.reloadSections(NSIndexSet(index: s), withRowAnimation: UITableViewRowAnimation.Automatic)
                    self?.tableView.endUpdates()
                    completion?()
                }
            })
        } else {
            let idsToLoad = getNextDiscussionIdsToLoad()
            loadDiscussions(idsToLoad, success: {
                [weak self] in
                UIThread.performUI {
                    if let s = self {
                        s.tableView.beginUpdates()
                        let sections = NSIndexSet(indexesInRange: NSMakeRange(s.discussions.count - idsToLoad.count, idsToLoad.count))
                        s.tableView.insertSections(sections, withRowAnimation: .Automatic)
                        s.tableView.endUpdates()
                        completion?()
                    }
                }
            })
        }
    }
}

extension DiscussionsViewController : DiscussionCellDelegate {
    func didSelect(indexPath: NSIndexPath, deselectBlock: (Void -> Void)) {
        if discussions.count > indexPath.section && replies.loaded[discussions[indexPath.section].id]?.count > indexPath.row {
            if let comment = replies.loaded[discussions[indexPath.section].id]?[indexPath.row] {
                handleSelectDiscussion(comment, completion: deselectBlock)
            }
        } else {
            deselectBlock()
        }
    }
}

extension DiscussionsViewController : WriteCommentDelegate {
    func didWriteComment(comment: Comment, userInfo: UserInfo) {
        print("yay, he wrote the comment mothafucka!")
        print(comment.parentId)
        userInfos[userInfo.id] = userInfo
        if let parentId = comment.parentId {
            //insert row in an existing section
            if let section = discussions.indexOf({$0.id == parentId}) {
                discussions[section].repliesIds += [comment.id]
                if replies.loaded[parentId] == nil {
                    replies.loaded[parentId] = []
                }
                replies.loaded[parentId]! += [comment]
                tableView.beginUpdates()
                let p = NSIndexPath(forRow: replies.loaded[parentId]!.count - 1, inSection: section)
                tableView.insertRowsAtIndexPaths([p], withRowAnimation: .Automatic)
                tableView.endUpdates()
            }
        } else {
            //insert section
            discussionIds.all.insert(comment.id, atIndex: 0)
            discussionIds.loaded.insert(comment.id, atIndex: 0)
            discussions.insert(comment, atIndex: 0)
            tableView.beginUpdates()
            let index = NSIndexSet(index: 0)
            tableView.insertSections(index, withRowAnimation: .Automatic)
            tableView.endUpdates()
        }
    }
}
