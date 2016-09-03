//
//  UnitsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton
import DZNEmptyDataSet

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
                
        tableView.registerNib(UINib(nibName: "UnitTableViewCell", bundle: nil), forCellReuseIdentifier: "UnitTableViewCell")
        
        
        refreshControl.addTarget(self, action: #selector(UnitsViewController.refreshUnits), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
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
        
        section.loadProgressesForUnits({
            UIThread.performUI({
                self.tableView.reloadData()
            })
        })
    }
    
    var emptyDatasetState : EmptyDatasetState = .Empty {
        didSet {
            UIThread.performUI{
                self.tableView.reloadEmptyDataSet()
            }
        }
    }

    func refreshUnits() {
        didRefresh = false
        section.loadUnits(completion: {
            UIThread.performUI({
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                self.emptyDatasetState = EmptyDatasetState.Empty
            })
            self.didRefresh = true
        }, error: {
            UIThread.performUI({
                self.refreshControl.endRefreshing()
                self.emptyDatasetState = EmptyDatasetState.ConnectionError
            })
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
        if segue.identifier == "showSteps" || segue.identifier == "replaceSteps" {
            let dvc = segue.destinationViewController as! StepsViewController
            dvc.hidesBottomBarWhenPushed = true
            
            if let stepsPresentation = sender as? StepsPresentation {
                
                var index = stepsPresentation.index
                if stepsPresentation.isLastStep {
                    if let l = section.units[index].lesson {
                        dvc.startStepId = l.stepsArray.count - 1
                    }
                }
                dvc.lesson = section.units[index].lesson
                dvc.sectionNavigationDelegate = self
                currentlyDisplayingUnitIndex = index
                dvc.shouldNavigateToPrev = index != 0
                dvc.shouldNavigateToNext = index < section.units.count - 1
            }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    var currentlyDisplayingUnitIndex: Int?
    
    func selectUnitAtIndex(index: Int, isLastStep: Bool = false, replace: Bool = false) {
        performSegueWithIdentifier(replace ? "replaceSteps" : "showSteps", sender: StepsPresentation(index: index, isLastStep: isLastStep))       
    }
    
    func clearAllSelection() {
        if let selectedRows = tableView.indexPathsForSelectedRows {
            for indexPath in selectedRows {
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
        }
    }

}

class StepsPresentation {
    var index: Int
    var isLastStep: Bool
    init(index: Int, isLastStep: Bool) {
        self.index = index
        self.isLastStep = isLastStep
    }
}

extension UnitsViewController : SectionNavigationDelegate {
    func displayNext() {        
        if let uIndex = currentlyDisplayingUnitIndex {
            if uIndex + 1 < section.units.count {
                selectUnitAtIndex(uIndex + 1, replace: true)
            }
        }
    }
    
    func displayPrev() {
        if let uIndex = currentlyDisplayingUnitIndex {
            if uIndex - 1 >= 0 {
                selectUnitAtIndex(uIndex - 1, isLastStep: true, replace: true)
            }
        }        
    }
}

extension UnitsViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectUnitAtIndex(indexPath.row)
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
            
            AnalyticsReporter.reportEvent(AnalyticsEvents.Unit.cache, parameters: nil)
            
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
            AnalyticsReporter.reportEvent(AnalyticsEvents.Unit.cancel, parameters: nil)

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
        
        
            AnalyticsReporter.reportEvent(AnalyticsEvents.Unit.delete, parameters: nil)

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

extension UnitsViewController : DZNEmptyDataSetSource {
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        switch emptyDatasetState {
        case .Empty:
            return Images.emptyCoursesPlaceholder
        case .ConnectionError:
            return Images.noWifiImage.size250x250
        }
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        switch emptyDatasetState {
        case .Empty:
            text = NSLocalizedString("PullToRefreshUnitsTitle", comment: "")
            break
        case .ConnectionError:
            text = NSLocalizedString("ConnectionErrorTitle", comment: "")
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
            text = NSLocalizedString("PullToRefreshUnitsDescription", comment: "")
            break
        case .ConnectionError:
            text = NSLocalizedString("PullToRefreshUnitsDescription", comment: "")
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
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.whiteColor()
    }
    
    func verticalOffsetForEmptyDataSet(scrollView: UIScrollView!) -> CGFloat {
        //        print("offset -> \((self.navigationController?.navigationBar.bounds.height) ?? 0 + UIApplication.sharedApplication().statusBarFrame.height)")
        return 44
    }
}

extension UnitsViewController : DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
}
