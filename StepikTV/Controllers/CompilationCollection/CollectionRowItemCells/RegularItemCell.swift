//
//  RegularItemCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 11.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class RegularItemCell: FocusableCustomCollectionViewCell {
    static var nibName: String { return "RegularItemCell" }
    static var reuseIdentifier: String { return "RegularItemCell" }
    static var size: CGSize { return CGSize(width: 548.0, height: 308.0) }

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = imageView.bounds;
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.black.cgColor];
        imageView.layer.addSublayer(gradientLayer);
    }

    func setup(with item: ItemViewData) {
        titleLabel.text = item.title

        imageView.setImageWithURL(url: item.backgroundImageURL, placeholder: item.placeholder, completion: {
            let data = UIImageJPEGRepresentation(self.imageView.image!, 1)
            self.imageView.image = UIImage(data: data!)
        });
    }
}
