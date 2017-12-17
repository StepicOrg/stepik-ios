//
//  NarrowItemCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 11.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class NarrowItemCell: UICollectionViewCell {

    static var nibName: String { return "NarrowItemCell" }
    static var reuseIdentifier: String { return "NarrowItemCell" }
    static var size: CGSize { return CGSize(width: 308.0, height: 180.0) }

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
    }

    func setup(with item: ItemViewData) {
        titleLabel.text = item.title

        if item.isEmpty {
            guard let image = item.backgroundImage else { fatalError() }
            imageView.image = image
        }

        //...
    }
}
