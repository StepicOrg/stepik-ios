//
//  GeneralInfoTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

enum DisplayingInfoType : Int {
    case Overview = 0, Detailed = 1
}

class GeneralInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
  
    @IBOutlet weak var joinButton: UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        joinButton.setRoundedCorners(cornerRadius: 6, borderWidth: 1, borderColor: UIColor.stepicGreenColor())
        
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didRotate", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func didRotate() {
        print("did rotate in general info")
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func initWithCourse(course: Course) {
        courseNameLabel.text = course.title
        if course.enrolled {
            joinButton.setDisabledJoined()
        } else {
            joinButton.setEnabledJoined()
        }
    }
    

}

