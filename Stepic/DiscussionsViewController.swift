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
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl : UIRefreshControl? = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        tableView.registerNib(UINib(nibName: "DiscussionTableViewCell", bundle: nil), forCellReuseIdentifier: "DiscussionTableViewCell")
        tableView.registerNib(UINib(nibName: "LoadMoreTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadMoreTableViewCell")
        
        //TODO: Do NOT forget to localize this!
        self.title = "Discussions"
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func resetData(withReload: Bool) {
        discussionIds = DiscussionIds()
        replies = Replies()
        userInfos = [Int: UserInfo]()
        discussions = [Comment]()
        
        if withReload {
            tableView.reloadData()
        }
    }
    
    let discussionLoadingInterval = 10
    func getNextDiscussionIdsToLoad() -> [Int] {
        let startIndex = discussionIds.loaded.count
        return Array(discussionIds.all[startIndex ..< startIndex + min(discussionLoadingInterval, discussionIds.leftToLoad)])
    }
    
    func loadDiscussions(ids: [Int], success: (Void->Void)? = nil) {
        ApiDataDownloader.comments.retrieve(ids, success: 
            {
                [weak self]
                retrievedDiscussions, retrievedUserInfos in 
                
                if let s = self {
                    //get superDiscussions (those who have no parents)
                    let superDiscussions = Sorter.sort(retrievedDiscussions.filter({$0.parentId == nil}), byIds: ids)
                
                    s.discussionIds.loaded += ids
                    s.discussions += superDiscussions
                    
                    for (userId, info) in retrievedUserInfos {
                        s.userInfos[userId] = info
                    }
                    
                    //get all replies
                    for reply in retrievedDiscussions.filter({$0.parentId != nil}) {
                        if let parentId = reply.parentId {
                            if s.replies.loaded[parentId] == nil {
                                s.replies.loaded[parentId] = []
                            }
                            s.replies.loaded[parentId]? += [reply]
                        }
                    }
                    
                    //TODO: Possibly should sort all changed reply values 
                    
                    success?()
                }
            }, error: {
                errorString in
                print(errorString)
            }
        )
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
        return replies.loaded[discussions[section].id]?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DiscussionTableViewCell", forIndexPath: indexPath) as! DiscussionTableViewCell
        
        if discussions.count > indexPath.section && replies.loaded[discussions[indexPath.section].id]?.count > indexPath.row {
            if let comment = replies.loaded[discussions[indexPath.section].id]?[indexPath.row] {
                if let user = userInfos[comment.userId] {
                    cell.initWithComment(comment, user: user)
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
            return cell
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if isShowMoreEnabledForSection(section) {
            let cell = tableView.dequeueReusableCellWithIdentifier("LoadMoreTableViewCell") as! LoadMoreTableViewCell
            cell.tag = section
            cell.showMorePressedHandler = {
                section in
                print("pressed showMore for section id \(section)")
            }
            return cell
        } else {
            return nil
        }
    }
}
