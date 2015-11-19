//
//  DownloadsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton
import SVProgressHUD
import DZNEmptyDataSet

class DownloadsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var downloading : [Video] = []
    var stored : [Video] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UICustomizer.sharedCustomizer.setStepicNavigationBar(self.navigationController?.navigationBar)
        UICustomizer.sharedCustomizer.setStepicTabBar(self.tabBarController?.tabBar)
        
        tableView.registerNib(UINib(nibName: "DownloadTableViewCell", bundle: nil), forCellReuseIdentifier: "DownloadTableViewCell")
        
        self.tableView.emptyDataSetDelegate = self 
        self.tableView.emptyDataSetSource = self
        
        self.tableView.tableFooterView = UIView()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchVideos()
    }
    
    func fetchVideos() {
        stored = []
        downloading = []
        let videos = Video.getAllVideos()
        for video in videos {
            if video.isDownloading {
                downloading += [video]
                video.downloadDelegate = self
            }
            if video.isCached {
                stored += [video]
            }
        }
        print("downloading \(downloading.count), stored \(stored.count)")
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showPreferences" {
            let dvc = segue.destinationViewController as! UserPreferencesTableViewController
            dvc.hidesBottomBarWhenPushed = true
        }
    }
    

    func isSectionDownloading(section: Int) -> Bool {
        if downloading != [] && stored != [] {
            return section == 0 
        }
        return downloading != []
    }
    
    
    func askForClearCache(remove remove: (Void->Void)) {
        let alert = UIAlertController(title: NSLocalizedString("ClearCacheTitle", comment: ""), message: NSLocalizedString("ClearCacheMessage", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: ""), style: UIAlertActionStyle.Destructive, handler: {
            action in
            remove()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: {
            action in
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func clearCachePressed(sender: UIBarButtonItem) {
        askForClearCache(remove: {
            SVProgressHUD.show()
            CacheManager.sharedManager.clearCache(completion: {
                completed, errors in 
                if errors != 0 {
                    UIThread.performUI({SVProgressHUD.showErrorWithStatus("\(NSLocalizedString("FailedToRemoveMessage", comment: "")) \(errors)/\(completed+errors) \(NSLocalizedString((completed%10 == 1 && completed != 11) ? "Video" : "Videos", comment: ""))")})
                } else {
                    UIThread.performUI({SVProgressHUD.showSuccessWithStatus("\(NSLocalizedString("RemovedAllMessage", comment: "")) \(completed) \(NSLocalizedString((completed%10 == 1 && completed != 11) ? "Video" : "Videos", comment: ""))")})
                }
                UIThread.performUI({self.fetchVideos()})
            })
        })
    }
    
}

extension DownloadsViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSectionDownloading(section) {
            return downloading.count
        } else {
            return stored.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if downloading == [] && stored == [] {
            return 0
        }
        
        if downloading != [] && stored != [] {
            return 2
        }
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSectionDownloading(section) {
            return NSLocalizedString("Downloading", comment: "")
        } else {
            return NSLocalizedString("Completed", comment: "")
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DownloadTableViewCell", forIndexPath: indexPath) as! DownloadTableViewCell
        
        if isSectionDownloading(indexPath.section) {
            cell.initWith(downloading[indexPath.row], buttonDelegate: self, downloadDelegate: self)
            cell.downloadButton.tag = downloading[indexPath.row].id
        } else {
            cell.initWith(stored[indexPath.row], buttonDelegate: self, downloadDelegate: self)
            cell.downloadButton.tag = stored[indexPath.row].id
        }
        
        
        
        return cell
    }
}

extension DownloadsViewController : VideoDownloadDelegate {
    
    func removeFromDownloading(video: Video) {
        if let index = downloading.indexOf(video) {
            downloading.removeAtIndex(index)
            self.tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
            if downloading.count == 0 {
//                tableView.reloadData()
                tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
            }
            self.tableView.endUpdates()
            self.tableView.reloadEmptyDataSet()
        }
    }
    
    func addToStored(video: Video) {
        stored += [video]
        self.tableView.beginUpdates()
        if tableView.numberOfSections == 1 && isSectionDownloading(0) {
            tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
        }
        
        tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: stored.count - 1, inSection: (isSectionDownloading(0) ? 1 : 0))], withRowAnimation: .Automatic)
        self.tableView.endUpdates()

    }
    
    func removeFromStored(video: Video) {
        if let index = stored.indexOf(video) {
            stored.removeAtIndex(index)
            self.tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: (isSectionDownloading(0) ? 1 : 0))], withRowAnimation: .Automatic)
            if stored.count == 0 {
//                tableView.reloadData()
                tableView.deleteSections(NSIndexSet(index: (isSectionDownloading(0) ? 1 : 0)), withRowAnimation: .Automatic)
            }
            self.tableView.endUpdates()
            self.tableView.reloadEmptyDataSet()
        }
    }
    
    func didDownload(video: Video) {
        removeFromDownloading(video)
        addToStored(video)
        video.downloadDelegate = nil
    }
    
    func didGetError(video: Video) {
        removeFromDownloading(video)
        video.downloadDelegate = nil
    }
}

extension DownloadsViewController : PKDownloadButtonDelegate {
    
    func getVideoById(array: [Video], id: Int) -> Video? {
        let filtered = array.filter({return $0.id == id})
        if filtered.count != 1 {
            print("strange error occured, filtered count -> \(filtered.count) for video with id -> \(id)")
        } else {
            return filtered[0]
        }
        return nil
    }
    
    func downloadButtonTapped(downloadButton: PKDownloadButton!, currentState state: PKDownloadButtonState) {
        switch downloadButton.state {
        case .Downloaded:
            if let vid = getVideoById(stored, id: downloadButton.tag) {
                if vid.removeFromStore() {
                    removeFromStored(vid)
                } else {
                    print("error while deleting from the store")
                }
            }
            break
        case .Downloading:
            if let vid = getVideoById(downloading, id: downloadButton.tag) {
                if vid.cancelStore() {
                    removeFromDownloading(vid)
                } else {
                    print("error while cancelling the store")
                }
            }
            break
        case .StartDownload, .Pending:
            print("Unsupported states")
            break
        }
    }
}

extension DownloadsViewController : DZNEmptyDataSetSource {
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return Images.emptyDownloadsPlaceholder
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = NSLocalizedString("EmptyDownloadsTitle", comment: "")
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(18.0),
            NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.whiteColor()
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        
        let text = NSLocalizedString("EmptyDownloadsDescription", comment: "")
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(14.0),
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
}

extension DownloadsViewController : DZNEmptyDataSetDelegate {
    
}