//
//  ContentLanguageCollectionViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class ContentLanguageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var languageLabel: StepikLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.setRoundedCorners(cornerRadius: 4)
        languageLabel.colorMode = .dark
        contentView.backgroundColor = UIColor.mainLight
    }

    var language: String = "" {
        didSet {
            languageLabel.text = language
        }
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                languageLabel.colorMode = .light
                contentView.backgroundColor = UIColor.mainDark
            } else {
                languageLabel.colorMode = .dark
                contentView.backgroundColor = UIColor.mainLight
            }
        }
    }
}
