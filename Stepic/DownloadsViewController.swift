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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func isSectionDownloading(section: Int) -> Bool {
        if downloading != [] && stored != [] {
            return section == 0 
        }
        return downloading != []
    }
    
    
    func askForClearCache(remove remove: (Void->Void)) {
        //TODO: Add localized title
        let alert = UIAlertController(title: "Clear cache", message: "Remove all videos stored in the memory of the iPhone?", preferredStyle: UIAlertControllerStyle.Alert)
        
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
                //TODO: Add localized statuses
                if errors != 0 {
                    UIThread.performUI({SVProgressHUD.showErrorWithStatus("Failed to clear \(errors)/\(completed+errors) videos")})
                } else {
                    UIThread.performUI({SVProgressHUD.showSuccessWithStatus("Cleared all videos!")})
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
        //TODO: Localize
        if isSectionDownloading(section) {
            return "Downloading"
        } else {
            return "Completed"
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
        }
    }
    
    func didDownload(video: Video, downloadButton: PKDownloadButton) {
        removeFromDownloading(video)
        addToStored(video)
    }
}

extension DownloadsViewController : PKDownloadButtonDelegate {
    
    func getVideoById(array: [Video], id: Int) -> Video? {
        let filtered = array.filter({return $0.id == id})
        if filtered.count != 1 {
            print("strange error occured")
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