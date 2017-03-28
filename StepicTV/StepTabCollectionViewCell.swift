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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 20
    }
}
