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
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        tableView.registerNib(UINib(nibName: "DiscussionTableViewCell", bundle: nil), forCellReuseIdentifier: "DiscussionTableViewCell")
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
                
                //get superDiscussions (those who have no parents)
                let superDiscussions = Sorter.sort(retrievedDiscussions.filter({$0.parentId == nil}), byIds: ids)
                
                self?.discussionIds.loaded += ids
                self?.discussions += superDiscussions
                
                //get replies for all retrieved discussions
                for discussion in superDiscussions {
                    let repliesForDiscussion = retrievedDiscussions.filter({$0.parentId == discussion.id})
                    if self?.replies.loaded[discussion.id] == nil {
                        self?.replies.loaded[discussion.id] = []
                    }
                    
                    if let r = self?.replies.loaded[discussion.id] {
                        self?.replies.loaded[discussion.id] = Sorter.sort(r + repliesForDiscussion, byIds: discussion.repliesIds)
                    }
                }
                
                success?()
                return
            }, error: {
                errorString in
                print(errorString)
            }
        )
    }
    
    func reloadDiscussions() {
        resetData(false)
        
        ApiDataDownloader.discussionProxies.retrieve(discussionProxyId, success: 
            {
                [weak self] 
                discussionProxy in
                self?.discussionIds.all = discussionProxy.discussionIds
                if let discussionIdsToLoad = self?.getNextDiscussionIdsToLoad() {
                    self?.loadDiscussions(discussionIdsToLoad, success: 
                        {
                            [weak self] in
                            self?.discussionIds.loaded += discussionIdsToLoad
                            UIThread.performUI {
                                self?.tableView.reloadData()
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

}

extension DiscussionsViewController : UITableViewDelegate {
    
}

extension DiscussionsViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return discussionIds.loaded.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.loaded[discussions[section].id]?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DiscussionTableViewCell", forIndexPath: indexPath) as! DiscussionTableViewCell
        
        if let comment = replies.loaded[discussions[indexPath.section].id]?[indexPath.row] {
            if let user = userInfos[comment.id] {
                cell.userAvatarImageView.sd_setImageWithURL(NSURL(string: user.avatarURL)!)
                cell.nameLabel.text = "\(user.firstName) \(user.lastName)"
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
}
