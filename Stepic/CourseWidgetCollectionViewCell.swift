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

    func setup(courseViewData course: CourseViewData, colorMode: CourseListColorMode) {
        widgetView.setup(courseViewData: course, colorMode: colorMode)
    }
}
