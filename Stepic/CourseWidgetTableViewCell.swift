//
//  CourseWidgetTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 28.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CourseWidgetTableViewCell: UITableViewCell {

    @IBOutlet weak var widgetView: CourseWidgetView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWithCourse(_ course: Course, action: (() -> Void)?) {
        widgetView.title = course.title
        widgetView.action = action
        widgetView.buttonState = course.enrolled ? .continueLearning : .join
        widgetView.imageURL = URL(string: course.coverURLString)
//        widgetView.rating = 4.3
        widgetView.learners = course.learnersCount
        widgetView.progress = course.enrolled ? course.progress?.percentPassed : nil
    }
}
