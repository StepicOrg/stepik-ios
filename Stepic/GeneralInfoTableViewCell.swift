//
//  GeneralInfoTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

enum DisplayingInfoType: Int {
    case overview = 0, detailed = 1, syllabus = 2
}

class GeneralInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var courseNameLabel: StepikLabel!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!

    @IBOutlet weak var joinButton: UIButton!

    class func heightForCellWith(_ course: Course) -> CGFloat {
        let constrainHeight: CGFloat = 108
        let width = UIScreen.main.bounds.width - 16
        let titleHeight = UILabel.heightForLabelWithText(course.title, lines: 0, standardFontOfSize: 17, width: width, alignment : NSTextAlignment.center)
        return constrainHeight + titleHeight
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        joinButton.setRoundedCorners(cornerRadius: 6, borderWidth: 1, borderColor: UIColor.stepicGreenColor())

        typeSegmentedControl.setTitle(NSLocalizedString("Syllabus", comment: ""), forSegmentAt: 2)
        typeSegmentedControl.tintColor = UIColor.mainDarkColor
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(GeneralInfoTableViewCell.didRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func didRotate() {
        print("did rotate in general info")
        setNeedsLayout()
        layoutIfNeeded()
    }

    func initWithCourse(_ course: Course) {
        courseNameLabel.text = course.title
        if course.enrolled {
            joinButton.setStepicWhiteStyle()
            joinButton.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
        } else {
            joinButton.setStepicGreenStyle()
            joinButton.setTitle(Constants.joinCourseButtonText, for: .normal)
        }
    }

}
