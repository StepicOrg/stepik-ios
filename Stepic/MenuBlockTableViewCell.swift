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

        let selectedView = UIView()
        selectedView.backgroundColor = .stepikGrey
        self.selectedBackgroundView = selectedView

        separator.isHidden = false
        separator.backgroundColor = UIColor.stepikSeparator
        self.contentView.addSubview(separator)

        separator.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(self.contentView)
            make.leading.equalTo(self.contentView).offset(24)
            make.trailing.equalTo(self.contentView).offset(-24)
            make.height.equalTo(0.5)
        }
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
        hidingView.snp.makeConstraints { $0.edges.equalTo(self.contentView) }
        UIView.animate(withDuration: 0.2, animations: {
            [weak self] in
            self?.hidingView.alpha = 1
        })
    }
}
