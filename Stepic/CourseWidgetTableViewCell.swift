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

    var isLoading: Bool = false {
        didSet {
            widgetView.isLoading = isLoading
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

    func initWithCourse(_ course: Course, action: (() -> Void)?) {
        widgetView.title = course.title
        widgetView.action = action
        widgetView.buttonState = course.enrolled ? .continueLearning : .join
        widgetView.imageURL = URL(string: course.coverURLString)
        widgetView.rating = course.reviewSummary?.average
        widgetView.learners = course.learnersCount
        widgetView.progress = course.enrolled ? course.progress?.percentPassed : nil
        isLoading = false
    }

    func setup(courseViewData course: CourseViewData, colorMode: CourseListColorMode) {
        widgetView.title = course.title
        widgetView.action = course.action
        widgetView.buttonState = course.isEnrolled ? .continueLearning : .join
        widgetView.imageURL = URL(string: course.coverURLString)
        widgetView.rating = course.rating
        widgetView.learners = course.learners
        widgetView.progress = course.progress
        widgetView.colorMode = colorMode
        isLoading = false
        widgetView.layoutSubviews()
        self.layoutSubviews()

        widgetView.backgroundColor = UIColor.clear
    }
}
