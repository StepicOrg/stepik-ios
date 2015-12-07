//
//  SectionsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton

class SectionsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    var didRefresh = false
    var course : Course! 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = course.title
        tableView.tableFooterView = UIView()
        self.navigationItem.backBarButtonItem?.title = " "
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UICustomizer.sharedCustomizer.setStepicNavigationBar(self.navigationController?.navigationBar)
        UICustomizer.sharedCustomizer.setStepicTabBar(self.tabBarController?.tabBar)
        tableView.registerNib(UINib(nibName: "SectionTableViewCell", bundle: nil), forCellReuseIdentifier: "SectionTableViewCell")

        refreshControl.addTarget(self, action: "refreshSections", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        refreshControl.beginRefreshing()
        refreshSections()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem?.title = " "
        tableView.reloadData()
        if(self.refreshControl.refreshing) {
            let offset = self.tableView.contentOffset
            self.refreshControl.endRefreshing()
            self.refreshControl.beginRefreshing()
            self.tableView.contentOffset = offset
        }
    }
    
    func refreshSections() {
        didRefresh = false
        course.loadAllSections(success: {
            UIThread.performUI({
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            })
            self.didRefresh = true
        }, error: {
            Messages.sharedManager.showConnectionErrorMessage(inController: self.navigationController!)
            UIThread.performUI({
                self.refreshControl.endRefreshing()
            })
            self.didRefresh = true
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showCourse" {
            let dvc = segue.destinationViewController as! CoursePreviewViewController
            dvc.course = course
        }
        if segue.identifier == "showUnits" {
            let dvc = segue.destinationViewController as! UnitsViewController
            dvc.section = course.sections[sender as! Int]
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SectionsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showUnits", sender: indexPath.row)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SectionTableViewCell.heightForCellInSection(course.sections[indexPath.row])
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return course.sections[indexPath.row].isActive
    }
    
}

extension SectionsViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return course.sections.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SectionTableViewCell", forIndexPath: indexPath) as! SectionTableViewCell
        
        cell.initWithSection(course.sections[indexPath.row], delegate: self)
        
        return cell
    }
}

extension SectionsViewController : PKDownloadButtonDelegate {
    
    private func askForRemove(okHandler ok: Void->Void, cancelHandler cancel: Void->Void) {
        let alert = UIAlertController(title: NSLocalizedString("RemoveVideoTitle", comment: ""), message: NSLocalizedString("RemoveVideoBody", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: ""), style: UIAlertActionStyle.Destructive, handler: {
            action in
            ok()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.Cancel, handler: {
            action in
            cancel()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func storeSection(section: Section, downloadButton: PKDownloadButton!) {
        section.storeVideos(
            progress: {
            progress in
            UIThread.performUI({downloadButton.stopDownloadButton?.progress = CGFloat(progress)})
            }, completion: {
                if section.isCached {
                    UIThread.performUI({downloadButton.state = .Downloaded})
                } else {
                    UIThread.performUI({downloadButton.state = .StartDownload})
                }            
            }, error: {
                error in
                UIThread.performUI({downloadButton.state = PKDownloadButtonState.StartDownload})
        })
    }
    
    func downloadButtonTapped(downloadButton: PKDownloadButton!, currentState state: PKDownloadButtonState) {
        if !didRefresh {
            //TODO : Add alert
            print("wait until the section is refreshed")
            return
        }
        
        switch (state) {
        case PKDownloadButtonState.StartDownload : 
            
            if !ConnectionHelper.shared.isReachable {
                Messages.sharedManager.show3GDownloadErrorMessage(inController: self.navigationController!)
                print("Not reachable to download")
                return
            }
            
            if course.sections[downloadButton.tag].units.count != 0 {
                UIThread.performUI({downloadButton.state = PKDownloadButtonState.Downloading})
                storeSection(course.sections[downloadButton.tag], downloadButton: downloadButton)
            } else {
                UIThread.performUI({downloadButton.state = PKDownloadButtonState.Pending})
                course.sections[downloadButton.tag].loadUnits(completion: {
                    UIThread.performUI({downloadButton.state = PKDownloadButtonState.Downloading})
                    self.storeSection(self.course.sections[downloadButton.tag], downloadButton: downloadButton)
                }, error: {
                    print("Error while downloading section's units")
                })
            }
            break
            
        case PKDownloadButtonState.Downloading :
            
            downloadButton.state = PKDownloadButtonState.Pending

            course.sections[downloadButton.tag].cancelVideoStore(completion: {
                dispatch_async(dispatch_get_main_queue(), {
                    downloadButton.pendingView?.stopSpin()
                    downloadButton.state = PKDownloadButtonState.StartDownload
                })    
            })
            break
            
        case PKDownloadButtonState.Downloaded :

            askForRemove(okHandler: {
                
                downloadButton.state = PKDownloadButtonState.Pending
                
                self.course.sections[downloadButton.tag].removeFromStore(completion: {
                    dispatch_async(dispatch_get_main_queue(), {
                        downloadButton.pendingView?.stopSpin()
                        downloadButton.state = PKDownloadButtonState.StartDownload
                    })   
                })
                }, cancelHandler: {
                    dispatch_async(dispatch_get_main_queue(), {
                        downloadButton.pendingView?.stopSpin()
                        downloadButton.state = PKDownloadButtonState.Downloaded
                    })   
            })
            break
            
        case PKDownloadButtonState.Pending: 
            break
        }
    }
    
}