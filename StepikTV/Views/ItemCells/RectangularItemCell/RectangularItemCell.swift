//
//  RectangularItemCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 25.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class RectangularItemCell: UICollectionViewCell, DynamicallyCreatedProtocol, ItemConfigurableProtocol {
    
    static var nibName: String { get { return "RectangularItemCell" } }
    
    static var reuseIdentifier: String { get { return "RectangularItemCell" } }
    
    static var size: CGSize { get { return CGSize(width: 310.0, height: 350.0) } }
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
    }
    
    func configure(with data: Course) {
        titleLabel.text = data.name
    }
    
}
