//
//  MenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 05.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class MenuBlockTableViewCell: UITableViewCell {

    var hidingView: UIView = UIView()
    var separator: UIView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()

        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.mainLight.withAlphaComponent(0.75)
        self.selectedBackgroundView = selectedView

        separator.isHidden = false
        separator.backgroundColor = UIColor(hex: 0x535366).withAlphaComponent(0.05)
        self.contentView.addSubview(separator)
        _ = separator.alignBottomEdge(withView: self.contentView, predicate: "0")
        _ = separator.constrainHeight("1")
        _ = separator.alignLeadingEdge(withView: self.contentView, predicate: "24")
        _ = separator.alignTrailingEdge(withView: self.contentView, predicate: "-24")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWithBlock(block: MenuBlock) {
        separator.isHidden = !block.hasSeparatorOnBottom
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        hidingView.removeFromSuperview()
        separator.isHidden = false
    }

    func animateHide() {
        hidingView = UIView()
        hidingView.backgroundColor = UIColor.white
        hidingView.alpha = 0
        self.contentView.addSubview(hidingView)
        hidingView.align(toView: self.contentView)
        UIView.animate(withDuration: 0.2, animations: {
            [weak self] in
            self?.hidingView.alpha = 1
        })
    }

}
