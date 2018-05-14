//
//  PersonalDeadlineModeCollectionViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 15.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class PersonalDeadlineModeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var loadLabel: StepikLabel!

    @IBOutlet weak var modeImage: UIImageView!

    func setup(deadlineMode: DeadlineMode) {
        let modeInfo = deadlineMode.getMode()
        titleLabel.text = modeInfo.title
        loadLabel.text = "\(modeInfo.load) hrs/week"
        modeImage.image = modeInfo.image
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.setRoundedCorners(cornerRadius: 8, borderWidth: 1, borderColor: UIColor.mainDark)
    }
}
