//
//  UnitsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton

class UnitsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var section : Section!
    var didRefresh = false
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = section.title
        self.navigationItem.backBarButtonItem?.title = " "

        tableView.tableFooterView = UIView()
                
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UICustomizer.sharedCustomizer.setStepicNavigationBar(self.navigationController?.navigationBar)
        UICustomizer.sharedCustomizer.setStepicTabBar(self.tabBarController?.tabBar)

        tableView.registerNib(UINib(nibName: "UnitTableViewCell", bundle: nil), forCellReuseIdentifier: "UnitTableViewCell")
        
        
        refreshControl.addTarget(self, action: "refreshUnits", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        refreshControl.beginRefreshing()
        refreshUnits()

        
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
    
    func refreshUnits() {
        didRefresh = false
        section.loadUnits(completion: {
            UIThread.performUI({
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            })
            self.didRefresh = true
        }, error: {
            UIThread.performUI({
                self.refreshControl.endRefreshing()
            })
            Messages.sharedManager.showConnectionErrorMessage(inController: self.navigationController!)
            self.didRefresh = true
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSteps" {
            let dvc = segue.destinationViewController as! StepsViewController
            dvc.hidesBottomBarWhenPushed = true
            
            //TODO : pass unit here!
            dvc.lesson = section.units[sender as! Int].lesson
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

extension UnitsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if !didRefresh {
            
        } else {
            performSegueWithIdentifier("showSteps", sender: indexPath.row)        
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UnitTableViewCell.heightForCellWithUnit(self.section.units[indexPath.row])
    }
    
}

extension UnitsViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.section.units.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UnitTableViewCell", forIndexPath: indexPath) as! UnitTableViewCell
        
        cell.initWithUnit(self.section.units[indexPath.row], delegate: self)
        
        return cell
    }
}

extension UnitsViewController : PKDownloadButtonDelegate {
    
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
    
    private func storeLesson(lesson: Lesson?, downloadButton: PKDownloadButton!) {
        lesson?.storeVideos(progress: {
            progress in
            UIThread.performUI({downloadButton.stopDownloadButton?.progress = CGFloat(progress)})
            }, completion: {
                downloaded, cancelled in 
                if cancelled == 0 { 
                    UIThread.performUI({downloadButton.state = PKDownloadButtonState.Downloaded})
                } else {
                    UIThread.performUI({downloadButton.state = PKDownloadButtonState.StartDownload})
                }
            }, error:  {
                error in
                UIThread.performUI({downloadButton.state = PKDownloadButtonState.StartDownload})
        })
    }
    
    func downloadButtonTapped(downloadButton: PKDownloadButton!, currentState state: PKDownloadButtonState) {
        
        if !didRefresh {
            //TODO : Add alert
            print("wait until the lesson is refreshed")
            return
        }
        

        
        switch (state) {
        case PKDownloadButtonState.StartDownload : 
            
            if !ConnectionHelper.shared.isReachable {
                Messages.sharedManager.show3GDownloadErrorMessage(inController: self.navigationController!)
                print("Not reachable to download")
                return
            }
            
            downloadButton.state = PKDownloadButtonState.Downloading
            
            if section.units[downloadButton.tag].lesson?.steps.count != 0 {
                storeLesson(section.units[downloadButton.tag].lesson, downloadButton: downloadButton)
            } else {
                section.units[downloadButton.tag].lesson?.loadSteps(completion: {
                    self.storeLesson(self.section.units[downloadButton.tag].lesson, downloadButton: downloadButton)
                })
            }
            break
            
        case PKDownloadButtonState.Downloading :
            downloadButton.state = PKDownloadButtonState.Pending
            downloadButton.pendingView?.startSpin()

            section.units[downloadButton.tag].lesson?.cancelVideoStore(completion: {
                dispatch_async(dispatch_get_main_queue(), {
                    downloadButton.pendingView?.stopSpin()
                    downloadButton.state = PKDownloadButtonState.StartDownload
                })
            })
            break
            
        case PKDownloadButtonState.Downloaded :
            
            downloadButton.state = PKDownloadButtonState.Pending
            downloadButton.pendingView?.startSpin()
            askForRemove(okHandler: {
                self.section.units[downloadButton.tag].lesson?.removeFromStore(completion: {
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