//
//  CodeInputAccessoryCollectionViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 18.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Foundation

class CodeInputAccessoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var textLabel: UILabel!
    var text: String?
    var size: CodeInputAccessorySize?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    fileprivate func setRoundedStyle() {
        self.layer.cornerRadius = 4.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
    }

    class func width(for text: String, size: CodeInputAccessorySize) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 1
        label.text = text
        label.font = UIFont(name: "Courier", size: size.realSizes.textSize)!
        label.textAlignment = .center
        label.sizeToFit()

        return max(size.realSizes.minAccessoryWidth, label.bounds.width + 10)
    }

    func initialize(text: String, size: CodeInputAccessorySize) {
        self.text = text
        self.size = size
        textLabel.text = text
        let regularCourier = UIFont(name: "Courier", size: size.realSizes.textSize)!
        textLabel.font = regularCourier
        setRoundedStyle()
    }
}
