//
//  MajorItemCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 11.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class MajorItemCell: UICollectionViewCell {
    static var nibName: String { return "MajorItemCell" }
    static var reuseIdentifier: String { return "MajorItemCell" }
    static var size: CGSize { return CGSize(width: 860.0, height: 390.0) }

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
    }

    func setup(with item: ItemViewData) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle

        if item.isEmpty {
            guard let image = item.backgroundImage else { fatalError() }
            imageView.image = image
        }

        //...
    }
}
