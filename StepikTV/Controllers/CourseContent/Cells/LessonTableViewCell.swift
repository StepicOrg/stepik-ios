//
//  LessonTableViewCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 07.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

extension UILabel {

    var textSize: CGSize? {
        guard let labelText = text else {
            return nil
        }

        let labelTextSize = (labelText as NSString).size(attributes: [NSFontAttributeName: font])

        return labelTextSize
    }
}

class LessonTableViewCell: FocusableCustomTableViewCell {

    static var reuseIdentifier: String { return "LessonTableViewCell" }
    static var estimatedSize: CGFloat { return CGFloat(90) }

    static func getHeightForCell(with viewData: LessonViewData, width: CGFloat) -> CGFloat {
        return UILabel.heightForLabelWithText(viewData.title, lines: 0, font: UIFont.systemFont(ofSize: 38, weight: UIFontWeightMedium), width: width - 430, alignment: .left) + 45
    }

    @IBOutlet var indexLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var progressIcon: UIImageView!

    @IBOutlet weak var progressLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var indexLabelWidth: NSLayoutConstraint!

    private var pressAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        changeToDefault()
    }

    func setup(with paragraphIndex: Int, _ lessonIndex: Int, viewData: LessonViewData) {
        self.indexLabel.text = "\(paragraphIndex).\(lessonIndex)."
        self.nameLabel.text = viewData.title
        self.progressLabel.text = viewData.progressText
        self.progressIcon.image = viewData.progressImage

        self.pressAction = viewData.action

        indexLabelWidth.constant = (indexLabel.textSize?.width ?? 0) + CGFloat(1)
        progressLabelWidth.constant = (progressLabel.textSize?.width ?? 0) + CGFloat(1)
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)

        guard presses.first!.type != UIPressType.menu else { return }
        pressAction?()
    }

    override func changeToDefault() {
        super.changeToDefault()

        let color = UIColor.black.withAlphaComponent(0.1)

        indexLabel?.textColor = color
        nameLabel?.textColor = color
        progressLabel?.textColor = color
        progressIcon?.tintColor = color
    }

    override func changeToFocused() {
        super.changeToFocused()

        let color = UIColor.white

        indexLabel?.textColor = color
        nameLabel?.textColor = color
        progressLabel?.textColor = color
        progressIcon?.tintColor = color
    }

}
