//
//  MediumItemCell.swift
//  stepik-tv
//
//  Created by Александр Пономарев on 20.10.17.
//  Copyright © 2017 Base team. All rights reserved.
//

import Foundation
import UIKit

class MediumItemCell: UICollectionViewCell, CollectionViewCellProtocol {
    
    static var nibName: String { get { return "MediumItemCell" } }
    
    static var reuseIdentifier: String { get { return "MediumItemCell" } }
    
    static var size: CGSize { get { return CGSize(width: 548.0, height: 308.0) } }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
    }
    
}
