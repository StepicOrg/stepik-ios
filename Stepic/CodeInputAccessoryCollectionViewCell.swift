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
        // Initialization code
        guard let text = self.text, let size = self.size else {
            return
        }
        
        textLabel.text = text
        let regularCourier = UIFont(name: "Courier", size: size.realSizes.textSize)!
        textLabel.font = regularCourier
        setRoundedStyle()
    }

    fileprivate func setRoundedStyle() {
        self.contentView.layer.cornerRadius = 2.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    class func width(for text: String, size: CodeInputAccessorySize) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 1
        label.text = text
        label.font = UIFont(name: "Courier", size: size.realSizes.textSize)!
        label.textAlignment = .center
        label.sizeToFit()
        
        return label.bounds.width
    }
    
    func initialize(text: String, size: CodeInputAccessorySize) {
        self.text = text
        self.size = size
    }
}

