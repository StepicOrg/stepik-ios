//
//  SectionsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton
import DZNEmptyDataSet

class SectionsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let refreshControl = UIRefreshControl()
    var didRefresh = false
    var course : Course! 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LastStepGlobalContext.context.course = course
        
        self.navigationItem.title = course.title
        tableView.tableFooterView = UIView()
        self.navigationItem.backBarButtonItem?.title = " "
        
        let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(SectionsViewController.shareButtonPressed(_:)))
        let infoBtn = UIButton(type: UIButtonType.infoDark)
        infoBtn.addTarget(self, action: #selector(SectionsViewController.infoButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        let infoBarButtonItem = UIBarButtonItem(customView: infoBtn)
        self.navigationItem.rightBarButtonItems = [shareBarButtonItem, infoBarButtonItem]
        
        tableView.register(UINib(nibName: "SectionTableViewCell", bundle: nil), forCellReuseIdentifier: "SectionTableViewCell")

        refreshControl.addTarget(self, action: #selector(SectionsViewController.refreshSections), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        refreshControl.beginRefreshing()
        refreshSections()

        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        // Do any additional setup after loading the view.
    }
    
    var url : String {
        if let slug = course?.slug {
            return StepicApplicationsInfo.stepicURL + "/course/" + slug + "/syllabus/"
        } else {
            return ""
        }
    }
    
    func shareButtonPressed(_ button: UIBarButtonItem) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Syllabus.shared, parameters: nil)
        DispatchQueue.global( priority: DispatchQueue.GlobalQueuePriority.default).async {
            let shareVC = SharingHelper.getSharingController(self.url)
            shareVC.popoverPresentationController?.barButtonItem = button
            DispatchQueue.main.async {
                self.present(shareVC, animated: true, completion: nil)
            }
            }
    }
    
    func infoButtonPressed(_ button: UIButton) {
        self.performSegue(withIdentifier: "showCourse", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.backBarButtonItem?.title = " "
        tableView.reloadData()
        if(self.refreshControl.isRefreshing) {
            let offset = self.tableView.contentOffset
            self.refreshControl.endRefreshing()
            self.refreshControl.beginRefreshing()
            self.tableView.contentOffset = offset
        }
    }
    
    var emptyDatasetState : EmptyDatasetState = .empty {
        didSet {
            UIThread.performUI{
                self.tableView.reloadEmptyDataSet()
            }
        }
    }
    
    func refreshSections() {
        didRefresh = false
        course.loadAllSections(success: {
            UIThread.performUI({
                self.refreshControl.endRefreshing()
                self.emptyDatasetState = EmptyDatasetState.empty
                self.tableView.reloadData()
            })
            self.didRefresh = true
        }, error: {
            //TODO: Handle error type in section downloading
            UIThread.performUI({
                self.refreshControl.endRefreshing()
                self.emptyDatasetState = EmptyDatasetState.connectionError
                self.tableView.reloadData()
            })
            self.didRefresh = true
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCourse" {
            let dvc = segue.destination as! CoursePreviewViewController
            dvc.course = course
            dvc.hidesBottomBarWhenPushed = true
        }
        if segue.identifier == "showUnits" {
            let dvc = segue.destination as! UnitsViewController
            dvc.section = course.sections[sender as! Int]
            dvc.hidesBottomBarWhenPushed = true
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

    func showExamAlert(cancel cancelAction: @escaping ((Void)->Void)) {
        let alert = UIAlertController(title: NSLocalizedString("ExamTitle", comment: ""), message: NSLocalizedString("ShowExamInWeb", comment: ""), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Open", comment: ""), style: .default, handler: {
            [weak self]
            action in
            if let s = self {
                WebControllerManager.sharedManager.presentWebControllerWithURLString(s.url + "?from_mobile_app=true", inController: s, withKey: "exam", allowsSafari: true, backButtonStyle: .close)
            }
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {
            action in
            cancelAction()
        }))
        
        self.present(alert, animated: true, completion: {})
    }
}

extension SectionsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = course.sections[indexPath.row] 
        if section.isExam {
            showExamAlert(cancel: {})
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        performSegue(withIdentifier: "showUnits", sender: (indexPath as NSIndexPath).row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SectionTableViewCell.heightForCellInSection(course.sections[(indexPath as NSIndexPath).row])
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return course.sections[(indexPath as NSIndexPath).row].isActive || (course.sections[(indexPath as NSIndexPath).row].testSectionAction != nil)
    }
    
}

extension SectionsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return course.sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionTableViewCell", for: indexPath) as! SectionTableViewCell
        
        cell.initWithSection(course.sections[(indexPath as NSIndexPath).row], delegate: self)
        
        return cell
    }
}

extension SectionsViewController : PKDownloadButtonDelegate {
    
    fileprivate func askForRemove(okHandler ok: @escaping (Void)->Void, cancelHandler cancel: @escaping (Void)->Void) {
        let alert = UIAlertController(title: NSLocalizedString("RemoveVideoTitle", comment: ""), message: NSLocalizedString("RemoveVideoBody", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: ""), style: UIAlertActionStyle.destructive, handler: {
            action in
            ok()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: {
            action in
            cancel()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func storeSection(_ section: Section, downloadButton: PKDownloadButton!) {
        section.storeVideos(
            progress: {
            progress in
            UIThread.performUI({downloadButton.stopDownloadButton?.progress = CGFloat(progress)})
            }, completion: {
                if section.isCached {
                    UIThread.performUI({downloadButton.state = .downloaded})
                } else {
                    UIThread.performUI({downloadButton.state = .startDownload})
                }            
            }, error: {
                error in
                UIThread.performUI({downloadButton.state = PKDownloadButtonState.startDownload})
        })
    }
    
    func downloadButtonTapped(_ downloadButton: PKDownloadButton!, currentState state: PKDownloadButtonState) {
        if !didRefresh {
            //TODO : Add alert
            print("wait until the section is refreshed")
            return
        }
        
        switch (state) {
        case PKDownloadButtonState.startDownload : 
            
            AnalyticsReporter.reportEvent(AnalyticsEvents.Section.cache, parameters: nil)

            if !ConnectionHelper.shared.isReachable {
                Messages.sharedManager.show3GDownloadErrorMessage(inController: self.navigationController!)
                print("Not reachable to download")
                return
            }
            
            if course.sections[downloadButton.tag].units.count != 0 {
                UIThread.performUI({downloadButton.state = PKDownloadButtonState.downloading})
                storeSection(course.sections[downloadButton.tag], downloadButton: downloadButton)
            } else {
                UIThread.performUI({downloadButton.state = PKDownloadButtonState.pending})
                course.sections[downloadButton.tag].loadUnits(success: {
                    UIThread.performUI({downloadButton.state = PKDownloadButtonState.downloading})
                    self.storeSection(self.course.sections[downloadButton.tag], downloadButton: downloadButton)
                }, error: {
                    print("Error while downloading section's units")
                })
            }
            break
            
        case PKDownloadButtonState.downloading :
            
            AnalyticsReporter.reportEvent(AnalyticsEvents.Section.cancel, parameters: nil)

            downloadButton.state = PKDownloadButtonState.pending

            course.sections[downloadButton.tag].cancelVideoStore(completion: {
                DispatchQueue.main.async(execute: {
                    downloadButton.pendingView?.stopSpin()
                    downloadButton.state = PKDownloadButtonState.startDownload
                })    
            })
            break
            
        case PKDownloadButtonState.downloaded :

            askForRemove(okHandler: {
                AnalyticsReporter.reportEvent(AnalyticsEvents.Section.delete, parameters: nil)

                downloadButton.state = PKDownloadButtonState.pending
                
                self.course.sections[downloadButton.tag].removeFromStore(completion: {
                    DispatchQueue.main.async(execute: {
                        downloadButton.pendingView?.stopSpin()
                        downloadButton.state = PKDownloadButtonState.startDownload
                    })   
                })
                }, cancelHandler: {
                    DispatchQueue.main.async(execute: {
                        downloadButton.pendingView?.stopSpin()
                        downloadButton.state = PKDownloadButtonState.downloaded
                    })   
            })
            break
            
        case PKDownloadButtonState.pending: 
            break
        }
    }
}

extension SectionsViewController : DZNEmptyDataSetSource {
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        switch emptyDatasetState {
        case .empty:
            return Images.emptyCoursesPlaceholder
        case .connectionError:
            return Images.noWifiImage.size250x250
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        switch emptyDatasetState {
        case .empty:
            text = NSLocalizedString("PullToRefreshSectionsTitle", comment: "")
            break
        case .connectionError:
            text = NSLocalizedString("ConnectionErrorTitle", comment: "")
            break
        }
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18.0),
            NSForegroundColorAttributeName: UIColor.darkGray]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        var text : String = ""
        
        switch emptyDatasetState {
        case .empty:
            text = NSLocalizedString("PullToRefreshSectionsDescription", comment: "")
            break
        case .connectionError:
            text = NSLocalizedString("PullToRefreshSectionsDescription", comment: "")
            break
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        paragraph.alignment = .center
        
        let attributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0),
            NSForegroundColorAttributeName: UIColor.lightGray,
            NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
    
    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        //        print("offset -> \((self.navigationController?.navigationBar.bounds.height) ?? 0 + UIApplication.sharedApplication().statusBarFrame.height)")
        return 44
    }
}

extension SectionsViewController : DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}
