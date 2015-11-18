//
//  DownloadsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton

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
        } else {
            cell.initWith(stored[indexPath.row], buttonDelegate: self, downloadDelegate: self)
        }
        
        cell.downloadButton.tag = indexPath.row
        
        return cell
    }
}

extension DownloadsViewController : VideoDownloadDelegate {
    func didDownload(video: Video, downloadButton: PKDownloadButton) {
        if let index = downloading.indexOf(video) {
            downloading.removeAtIndex(index)
            stored += [video]
            tableView.reloadData()
        } else {
            print("Something strange happened")
        }
    }
}

extension DownloadsViewController : PKDownloadButtonDelegate {
    func downloadButtonTapped(downloadButton: PKDownloadButton!, currentState state: PKDownloadButtonState) {
        switch downloadButton.state {
        case .Downloaded:
            stored.removeAtIndex(downloadButton.tag)
            tableView.reloadData()
            break
        case .Downloading:
            if stored[downloadButton.tag].cancelStore() {
                stored.removeAtIndex(downloadButton.tag)
                tableView.reloadData()
            } else {
                print("error while cancelling the store")
            }
            break
        case .StartDownload, .Pending:
            print("Unsupported states")
            break
        }
    }
}