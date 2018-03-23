//
//  DetailsCourseInfoCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 29.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class DetailsCourseInfoSectionCell: UICollectionViewCell, CourseInfoSectionViewProtocol {
    static var nibName: String { return "DetailsCourseInfoSectionCell" }
    static var reuseIdentifier: String { return "DetailsCourseInfoSectionCell" }

    static func getHeightForCell(section: CourseInfoSection, width: CGFloat) -> CGFloat {
        // Hardcoding cell's height according to the income content

        guard case let .text(content: content, selectionAction: _) = section.contentType else {
            return 35.0
        }

        return max(35, UILabel.heightForLabelWithText(content, lines: 0, font: UIFont.systemFont(ofSize: 29, weight: .regular), width: width - 220, html: true, alignment: .left)) + 125
    }

    @IBOutlet var title: UILabel!
    @IBOutlet var content: TVFocusableText!

    override func awakeFromNib() {
        super.awakeFromNib()

        content.setupStyle(defaultTextColor: UIColor.black, focusedTextColor: UIColor.white, substrateViewColor: UIColor(hex: 0x80c972).withAlphaComponent(0.8))
    }

    func setup(with section: CourseInfoSection) {
        title.text = section.title

        switch section.contentType {
        case let .text(content: content, selectionAction: selectionAction):
            self.content.setTextWithHTMLString(content)
            self.content.pressAction = selectionAction
        default:
            fatalError("Sections data and view dependencies fails")
        }
    }
}
