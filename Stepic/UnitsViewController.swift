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
    func downloadButtonTapped(downloadButton: PKDownloadButton!, currentState state: PKDownloadButtonState) {
        switch (state) {
        case PKDownloadButtonState.StartDownload : 
            downloadButton.state = PKDownloadButtonState.Downloading
            VideoDownloader.sharedDownloader.downloadVideoWithURLs(section.units[downloadButton.tag].lesson?.getVideoURLs())
        case PKDownloadButtonState.Downloading :
            downloadButton.state = PKDownloadButtonState.StartDownload
            VideoDownloader.sharedDownloader.cancelVideoDownloadWithURLs(section.units[downloadButton.tag].lesson?.getVideoURLs())
        case PKDownloadButtonState.Downloaded :
            downloadButton.state = PKDownloadButtonState.StartDownload
            VideoDownloader.sharedDownloader.deleteVideosViewURLs(section.units[downloadButton.tag].lesson?.getVideoURLs())
        default:
            print("unsupported download button state")
        }
    }
}