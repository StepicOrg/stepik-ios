//
//  VideoQualityTableViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class VideoQualityTableViewController: UITableViewController {

    @IBOutlet var qualityCells: [UITableViewCell]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        UICustomizer.sharedCustomizer.setStepicNavigationBar(self.navigationController?.navigationBar)
        UICustomizer.sharedCustomizer.setStepicTabBar(self.tabBarController?.tabBar)

        tableView.tableFooterView = UIView()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
        setCheckmarkTo(VideosInfo.videoQuality.preferencesTag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension VideoQualityTableViewController {
    
    private func setCheckmarkTo(selectedTag: Int) {
        for cell in qualityCells {
            if cell.tag == selectedTag {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let filtered = qualityCells.filter({return $0.tag == indexPath.row}) 
        switch filtered.count {
        case 0: 
            print("error! selected a video quality cell without a tag!")
        case 1:
            VideosInfo.videoQuality = VideoQuality(preferencesTag: filtered[0].tag)
            setCheckmarkTo(filtered[0].tag)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        default:
            print("something wrong happened during selection in videoQualityTableViewController")
        }
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
