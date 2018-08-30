//
//  CourseWidgetTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 28.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CourseWidgetTableViewCell: UITableViewCell {

    @IBOutlet weak var widgetView: OldCourseWidgetView!

    var isLoading: Bool {
        get {
            return widgetView.isLoading
        }
        set(value) {
            widgetView.isLoading = value
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(courseViewData course: CourseViewData, colorMode: CourseListColorMode) {
        widgetView.setup(courseViewData: course, colorMode: colorMode)
    }
}
