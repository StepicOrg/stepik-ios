//
//  MenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 05.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

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

        separator.snp.makeConstraints { make -> Void in
            make.bottom.equalTo(self.contentView)
            make.leading.equalTo(self.contentView).offset(24)
            make.trailing.equalTo(self.contentView).offset(-24)
            make.height.equalTo(1)
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
