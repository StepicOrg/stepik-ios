//
//  MenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 05.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

class MenuBlockTableViewCell: UITableViewCell {
    var hidingView = UIView()
    var separator = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.separator.isHidden = false
        self.contentView.addSubview(separator)

        self.separator.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(self.contentView)
            make.leading.equalTo(self.contentView).offset(24)
            make.trailing.equalTo(self.contentView).offset(-24)
            make.height.equalTo(0.5)
        }

        self.colorize()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.hidingView.removeFromSuperview()
        self.separator.isHidden = false
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    func initWithBlock(block: MenuBlock) {
        self.separator.isHidden = !block.hasSeparatorOnBottom
    }

    func animateHide() {
        self.hidingView = UIView()
        self.hidingView.backgroundColor = .stepikBackground
        self.hidingView.alpha = 0

        self.contentView.addSubview(self.hidingView)
        self.hidingView.snp.makeConstraints { $0.edges.equalTo(self.contentView) }

        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.hidingView.alpha = 1
        })
    }

    func colorize() {
        self.separator.backgroundColor = .stepikSeparator
    }
}
