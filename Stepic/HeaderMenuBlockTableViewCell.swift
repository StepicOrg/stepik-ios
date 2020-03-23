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
        self.titleLabel.text = block.title
        self.titleLabel.textColor = block.titleColor
    }
}
