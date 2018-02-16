//
//  ParagraphTableViewCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 02.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class MenuSectionTableViewCell: FocusableCustomTableViewCell {

    static var reuseIdentifier: String { return "MenuSectionTableViewCell" }
    static var size: CGFloat { get { return CGFloat(66) } }

    static func getHeightForCell(with index: Int, _ title: String, width: CGFloat) -> CGFloat {
        return UILabel.heightForLabelWithText("\(index). \(title)", lines: 0, font: UIFont.systemFont(ofSize: 38, weight: UIFontWeightMedium), width: width - 180, alignment: .left) + 20
    }

    @IBOutlet var nameLabel: UILabel?

    private var index: Int?
    private var sectionTitle: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        changeToDefault()
    }

    func setup(with index: Int? = nil, _ sectionTitle: String) {
        self.index = index
        self.sectionTitle = sectionTitle

        if let index = index {
            self.nameLabel?.text = "\(index). \(sectionTitle)"
        } else {
            self.nameLabel?.text = "\(sectionTitle)"
        }
    }

    override func changeToDefault() {
        super.changeToDefault()
        nameLabel?.textColor = UIColor.black.withAlphaComponent(0.3)
    }

    override func changeToFocused() {
        super.changeToFocused()
        nameLabel?.textColor = UIColor.white
    }

    func setCurrentSection() {
        changeToDefault()
        nameLabel?.textColor = UIColor.black.withAlphaComponent(0.9)
    }
}

class MenuHeaderCourseTableViewCell: FocusableCustomTableViewCell {

    static var reuseIdentifier: String { return "MenuHeaderCourseTableViewCell" }
    static var size: CGFloat { return CGFloat(220) }

    static func getHeightForCell(with viewData: CourseViewData?, width: CGFloat) -> CGFloat {
        return max(80.0, UILabel.heightForLabelWithText(viewData?.title ?? "", lines: 0, font: UIFont.systemFont(ofSize: 57, weight: UIFontWeightMedium), width: width - 150, alignment: .left) + 40)
    }

    @IBOutlet var titleLabel: UILabel?

    var pressAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        changeToDefault()
    }

    func setup(with viewData: CourseViewData) {
        titleLabel?.text = viewData.title

        self.pressAction = viewData.action
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        guard presses.first!.type != UIPressType.menu else { return }
        pressAction?()
    }

    override func changeToDefault() {
        super.changeToDefault()
        titleLabel?.textColor = UIColor.black.withAlphaComponent(0.3)
    }

    override func changeToFocused() {
        super.changeToFocused()
        titleLabel?.textColor = UIColor.white
    }
}
