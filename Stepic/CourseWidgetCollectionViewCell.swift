//
//  CourseWidgetCollectionViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 16.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CourseWidgetCollectionViewCell: UICollectionViewCell {
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

    func setup(courseViewData course: CourseViewData) {
        widgetView.title = course.title
        widgetView.action = course.action
        widgetView.buttonState = course.isEnrolled ? .continueLearning : .join
        widgetView.imageURL = URL(string: course.coverURLString)
        widgetView.rating = course.rating
        widgetView.learners = course.learners
        widgetView.progress = course.progress
        isLoading = false
    }
}
