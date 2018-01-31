//
//  ParagraphTableViewCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 02.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class MenuSectionTableViewCell: UITableViewCell {

    static var reuseIdentifier: String { return "MenuSectionTableViewCell" }
    static var size: CGFloat { get { return CGFloat(66) } }

    static func getHeightForCell(with index: Int, _ title: String, width: CGFloat) -> CGFloat {
        return UILabel.heightForLabelWithText("\(index). \(title)", lines: 0, font: UIFont.systemFont(ofSize: 38, weight: UIFontWeightMedium), width: width - 200, alignment: .left) + 20
    }

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var progressIcon: UIImageView!

    private var index: Int?
    private var sectionTitle: String?

    func setup(with index: Int, _ sectionTitle: String) {
        self.index = index
        self.sectionTitle = sectionTitle

        self.nameLabel.text = "\(index). \(sectionTitle)"
    }
}

class MenuHeaderCourseTableViewCell: UITableViewCell {

    static var reuseIdentifier: String { return "MenuHeaderCourseTableViewCell" }
    static var size: CGFloat { return CGFloat(220) }

    static func getHeightForCell(with viewData: CourseViewData?, width: CGFloat) -> CGFloat {
        return max(80.0, UILabel.heightForLabelWithText(viewData?.title ?? "", lines: 0, font: UIFont.systemFont(ofSize: 57, weight: UIFontWeightMedium), width: width - 150, alignment: .left) + 40)
    }

    @IBOutlet var titleLabel: UILabel!

    var pressAction: (() -> Void)?

    func setup(with viewData: CourseViewData) {
        titleLabel.text = viewData.title

        self.pressAction = viewData.action
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        guard presses.first!.type != UIPressType.menu else { return }
        pressAction?()
    }
}
