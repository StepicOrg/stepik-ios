//
//  CustomMenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Ivan Magda on 10/8/19.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

final class CustomMenuBlockTableViewCell: MenuBlockTableViewCell {
    @IBOutlet var containerView: UIView!

    override func prepareForReuse() {
        super.prepareForReuse()
        self.containerView.subviews.forEach { $0.removeFromSuperview() }
    }

    override func initWithBlock(block: MenuBlock) {
        super.initWithBlock(block: block)

        guard let block = block as? CustomMenuBlock else {
            return
        }

        if let contentView = block.contentView {
            self.containerView.addSubview(contentView)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            self.layoutIfNeeded()
        }
    }
}
