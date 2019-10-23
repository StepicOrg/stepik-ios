//
//  HeaderMenuBlockTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class HeaderMenuBlockTableViewCell: MenuBlockTableViewCell {
    @IBOutlet weak var titleLabel: StepikLabel!

    func initWithBlock(block: HeaderMenuBlock) {
        titleLabel.text = block.title
        titleLabel.textColor = block.titleColor
    }
}
