//
//  StepTabCollectionViewCell.swift
//  Stepic
//
//  Created by Anton Kondrashov on 28/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class StepTabCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "StepTabCollectionViewCell"
    static let nibName = "StepTabCollectionViewCell"
    
    @IBOutlet weak var stepImage: UIImageView!
    @IBOutlet weak var stepCompleteImage: UIImageView!
    
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTrailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 20
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        layer.borderWidth = 2
        layer.borderColor = isFocused ? UIColor.white.cgColor : UIColor.clear.cgColor
        
        imageTopConstraint.constant = isFocused ? -8 : -24
        imageBottomConstraint.constant = isFocused ? 8 : 24
        imageLeadingConstraint.constant = isFocused ? 8 : 24
        imageTrailingConstraint.constant = isFocused ? 8 : 24
        
        UIView.animate(withDuration: 0.2) { [unowned self] in
            self.stepImage.layoutIfNeeded()
        }
        
    }
}
