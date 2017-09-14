//
//  SocialAuthCollectionViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class SocialAuthCollectionViewCell: UICollectionViewCell {
    static let reuseId = "socialAuthCell"

    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        isUserInteractionEnabled = true
        contentView.isUserInteractionEnabled = false

        contentView.layer.cornerRadius = layer.cornerRadius
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor(hex: 0xBBBBBB).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.5)
        layer.shadowRadius = 1.7
        layer.shadowOpacity = 0.3
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
    }

    override var isHighlighted: Bool {
        didSet {
            contentView.backgroundColor = isHighlighted ? UIColor.lightGray : UIColor.white
        }
    }
}
