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
    
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var mediumLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var veryHighLabel: UILabel!
    
    
    let defaultQualities = ["270", "360", "720", "1080"]
    let qualityStrings = [
        NSLocalizedString("Low", comment: ""),
        NSLocalizedString("Medium", comment: ""),
        NSLocalizedString("High", comment: ""),
        NSLocalizedString("VeryHigh", comment: "")
    ]
    
    fileprivate func localize() {
        lowLabel.text = "\(qualityStrings[0]) (\(defaultQualities[0])p)"
        mediumLabel.text = "\(qualityStrings[1]) (\(defaultQualities[1])p)"
        highLabel.text = "\(qualityStrings[2]) (\(defaultQualities[2])p)"
        veryHighLabel.text = "\(qualityStrings[3]) (\(defaultQualities[3])p)"
        title = NSLocalizedString("VideoQuality", comment: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        localize()
        tableView.tableFooterView = UIView()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(_ animated: Bool) {
        setCheckmarkTo(defaultQualities.index(of: VideosInfo.videoQuality) ?? 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension VideoQualityTableViewController {
    
    fileprivate func setCheckmarkTo(_ selectedTag: Int) {
        for cell in qualityCells {
            if cell.tag == selectedTag {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filtered = qualityCells.filter({return $0.tag == (indexPath as NSIndexPath).row}) 
        switch filtered.count {
        case 0: 
            print("error! selected a video quality cell without a tag!")
        case 1:
            VideosInfo.videoQuality = defaultQualities[filtered[0].tag]
            setCheckmarkTo(filtered[0].tag)
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            print("something wrong happened during selection in videoQualityTableViewController")
        }
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
