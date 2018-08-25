//
//  LessonHeaderTableView.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 25/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class LessonHeaderTableView: UIView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    @IBOutlet var titleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet var subtitleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet var subtitleLabelBottomConstraint: NSLayoutConstraint!

    var layoutHeight: CGFloat {
        let titleHeight = titleLabel.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        let subtitleHeight = subtitleLabel.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height

        return ceil(titleHeight
            + subtitleHeight
            + titleLabelTopConstraint.constant
            + subtitleLabelTopConstraint.constant
            + subtitleLabelBottomConstraint.constant
        )
    }
}
