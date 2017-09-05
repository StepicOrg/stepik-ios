//
//  MenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 05.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class MenuBlockTableViewCell: UITableViewCell {

    var hidingView: UIView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWithBlock(block: MenuBlock) {
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        hidingView.removeFromSuperview()
    }

    func animateHide() {
        hidingView = UIView()
        hidingView.backgroundColor = UIColor.white
        hidingView.alpha = 0
        self.contentView.addSubview(hidingView)
        hidingView.align(to: self.contentView)
        UIView.animate(withDuration: 0.2, animations: {
            [weak self] in
            self?.hidingView.alpha = 1
        })
    }

}
