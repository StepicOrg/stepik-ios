//
//  TitleContentExpandableMenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class TitleContentExpandableMenuBlockTableViewCell: MenuBlockTableViewCell {
    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var arrowButton: UIButton!

    var bottomTitleConstraint: NSLayoutConstraint?

    var labels: [StepikLabel] = []
    var block: TitleContentExpandableMenuBlock?

    var isExpanded: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bottomTitleConstraint = titleLabel.alignBottomEdge(withView: self.contentView, predicate: "-26")
    }

    @IBAction func arrowButtonPressed(_ sender: UIButton) {
        expandPressed()
    }

    func expandPressed() {
        guard let block = block else {
            return
        }
        for label in labels {
            label.isHidden = true
        }
        block.onExpanded?(!block.isExpanded)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWithBlock(block: TitleContentExpandableMenuBlock) {
        super.initWithBlock(block: block)
        self.block = block
        titleLabel.text = block.title
        titleLabel.textColor = block.titleColor
        if block.isExpanded {
            expand(block: block)
        } else {
            shrink(block: block)
        }
    }

    enum LabelType {
        case title
        case content

        var font: UIFont {
            switch self {
            case .title:
                return UIFont.systemFont(ofSize: 17, weight: UIFontWeightLight)
            case .content:
                return UIFont.systemFont(ofSize: 15, weight: UIFontWeightLight)
            }
        }
    }

    private func buildLabel(type: LabelType, text: String) -> StepikLabel {
        let label = StepikLabel(frame: CGRect.zero)
        label.text = text
        label.font = type.font
        if let titleColor = block?.titleColor {
            label.textColor = titleColor
        }

        return label
    }

    private func addLabel(type: LabelType, text: String, after topView: UIView?) {
        guard let topView = topView else {
            return
        }
        let l = buildLabel(type: type, text: text)
        self.contentView.addSubview(l)
        _ = l.constrainTopSpace(toView: topView, predicate: type == .content ? "8" : "16")
        l.alignLeading("24", trailing: "-24", toView: self.contentView)
        l.numberOfLines = 0
        labels += [l]
    }

    private func cleanLabels() {
        for label in labels {
            DispatchQueue.main.async {
                label.isHidden = true
                label.removeFromSuperview()
            }
        }
        labels = []
    }

    func expand(block: TitleContentExpandableMenuBlock) {
        guard block.content.count > 0 else {
            return
        }

        if labels.count != 0 {
            cleanLabels()
        }

        let firstContent = block.content[0]
        titleLabel.text = firstContent.title
        addLabel(type: .content, text: firstContent.content, after: titleLabel)
        bottomTitleConstraint?.isActive = false

        for (index, labelText) in block.content.enumerated() {
            if index != 0 {
                addLabel(type: .title, text: labelText.title, after: labels.last)
                addLabel(type: .content, text: labelText.content, after: labels.last)
            }
        }
        _ = labels.last?.alignBottomEdge(withView: self.contentView, predicate: "-26")
        arrowButton.setImage(#imageLiteral(resourceName: "menu_arrow_top"), for: .normal)
    }

    func shrink(block: TitleContentExpandableMenuBlock) {
        cleanLabels()
        bottomTitleConstraint?.isActive = true
        arrowButton.setImage(#imageLiteral(resourceName: "menu_arrow_bottom"), for: .normal)
    }

}
