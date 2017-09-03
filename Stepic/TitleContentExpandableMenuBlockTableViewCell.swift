//
//  TitleContentExpandableMenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class TitleContentExpandableMenuBlockTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!

    var bottomTitleConstraint: NSLayoutConstraint?

    var labels: [UILabel] = []

    var block: TitleContentExpandableMenuBlock?

    var isExpanded: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bottomTitleConstraint = titleLabel.alignBottomEdge(with: self.contentView, predicate: "-12").first as? NSLayoutConstraint
        let tapG = UITapGestureRecognizer(target: self, action: #selector(TitleContentExpandableMenuBlockTableViewCell.expandPressed))
        arrowImageView.isUserInteractionEnabled = true
        arrowImageView.addGestureRecognizer(tapG)
    }

    func expandPressed() {
        guard let block = block else {
            return
        }
        block.onExpanded?(!block.isExpanded)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWithBlock(block: TitleContentExpandableMenuBlock) {
        self.block = block
        titleLabel.text = block.title
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
                return UIFont.systemFont(ofSize: 17)
            case .content:
                if #available(iOS 8.2, *) {
                    return UIFont.systemFont(ofSize: 17, weight: UIFontWeightThin)
                } else {
                    return UIFont.systemFont(ofSize: 17)
                }
            }
        }
    }

    private func buildLabel(type: LabelType, text: String) -> UILabel {
        let label = UILabel(frame: CGRect.zero)
        label.text = text
        label.font = type.font
        return label
    }

    private func addLabel(type: LabelType, text: String, after topView: UIView?) {
        guard let topView = topView else {
            return
        }
        let l = buildLabel(type: type, text: text)
        self.contentView.addSubview(l)
        _ = l.constrainTopSpace(to: topView, predicate: "4")
        l.alignLeading("24", trailing: "-24", to: self.contentView)
        l.numberOfLines = 0
        labels += [l]
    }

    func expand(block: TitleContentExpandableMenuBlock) {
        guard block.content.count > 0 else {
            return
        }

        labels = []
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
        _ = labels.last?.alignBottomEdge(with: self.contentView, predicate: "-12")
    }

    func shrink(block: TitleContentExpandableMenuBlock) {
        for label in labels {
            label.removeFromSuperview()
        }
        labels = []
        self.layoutIfNeeded()
        bottomTitleConstraint?.isActive = true
    }

}
