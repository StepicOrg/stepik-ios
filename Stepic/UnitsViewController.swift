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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
                
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UICustomizer.sharedCustomizer.setStepicNavigationBar(self.navigationController?.navigationBar)
        UICustomizer.sharedCustomizer.setStepicTabBar(self.tabBarController?.tabBar)
        
        tableView.registerNib(UINib(nibName: "UnitTableViewCell", bundle: nil), forCellReuseIdentifier: "UnitTableViewCell")
        
        section.loadUnits(completion: {
            self.tableView.reloadData()
        })
        // Do any additional setup after loading the view.
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
            dvc.lesson = section.units[sender as! Int].lesson
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}

extension UnitsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showSteps", sender: indexPath.row)        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
        let alert = UIAlertController(title: "Remove lesson", message: "Are you sure you want to remove lesson from local store?", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
            action in
            ok()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            action in
            cancel()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func downloadButtonTapped(downloadButton: PKDownloadButton!, currentState state: PKDownloadButtonState) {
        switch (state) {
        case PKDownloadButtonState.StartDownload : 
            downloadButton.state = PKDownloadButtonState.Downloading
            
            section.units[downloadButton.tag].lesson?.storeVideos(downloadButton.tag, progress: {
                id, progress in
                downloadButton.stopDownloadButton?.progress = CGFloat(progress)
            }, completion: {
                id in
                downloadButton.state = PKDownloadButtonState.Downloaded
            })
            
        case PKDownloadButtonState.Downloading :
            downloadButton.state = PKDownloadButtonState.Pending
            downloadButton.pendingView?.startSpin()
            section.units[downloadButton.tag].lesson?.cancelVideoStore(completion: {
                downloadButton.pendingView?.stopSpin()
                downloadButton.state = PKDownloadButtonState.StartDownload
            })
            
        case PKDownloadButtonState.Downloaded :
            downloadButton.state = PKDownloadButtonState.Pending
            downloadButton.pendingView?.startSpin()

            askForRemove(okHandler: {
                section.units[downloadButton.tag].lesson?.removeFromStore(completion: {
                    downloadButton.pendingView?.stopSpin()
                    downloadButton.state = PKDownloadButtonState.StartDownload
                })
            }, cancelHandler: {
                downloadButton.pendingView?.stopSpin()
                downloadButton.state = PKDownloadButtonState.Downloaded
            })
            
            
        case PKDownloadButtonState.Pending: 
            break
        }
    }
}