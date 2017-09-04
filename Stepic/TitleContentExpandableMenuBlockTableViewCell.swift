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
    @IBOutlet weak var arrowButton: UIButton!

    var bottomTitleConstraint: NSLayoutConstraint?

    var labels: [UILabel] = []
    var block: TitleContentExpandableMenuBlock?

    var isExpanded: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bottomTitleConstraint = titleLabel.alignBottomEdge(with: self.contentView, predicate: "-12").first as? NSLayoutConstraint
    }

    @IBAction func arrowButtonPressed(_ sender: UIButton) {
        guard let block = block else {
            return
        }
        for label in labels {
            label.isHidden = true
        }
        block.onExpanded?(!block.isExpanded)
    }

    func expandPressed() {
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
                    return UIFont.systemFont(ofSize: 15, weight: UIFontWeightThin)
                } else {
                    return UIFont.systemFont(ofSize: 15)
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
        _ = labels.last?.alignBottomEdge(with: self.contentView, predicate: "-12")
        arrowButton.setImage(#imageLiteral(resourceName: "menu_arrow_top"), for: .normal)
    }

    func shrink(block: TitleContentExpandableMenuBlock) {
        cleanLabels()
        bottomTitleConstraint?.isActive = true
        arrowButton.setImage(#imageLiteral(resourceName: "menu_arrow_bottom"), for: .normal)
    }

}
