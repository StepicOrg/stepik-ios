//
//  CourseTagCollectionViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 21.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CourseTagCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tagLabel: StepikLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.setRoundedCorners(cornerRadius: 20)
        tagLabel.colorMode = .dark
        contentView.backgroundColor = UIColor.mainLight
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                tagLabel.colorMode = .light
                contentView.backgroundColor = UIColor.mainDark
            } else {
                tagLabel.colorMode = .dark
                contentView.backgroundColor = UIColor.mainLight
            }
        }
    }
}
