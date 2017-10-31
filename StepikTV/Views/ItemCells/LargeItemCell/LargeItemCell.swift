//
//  LargeItemCell.swift
//  stepik-tv
//
//  Created by Александр Пономарев on 19.10.17.
//  Copyright © 2017 Base team. All rights reserved.
//

import UIKit

class LargeItemCell: UICollectionViewCell, DynamicallyCreatedProtocol, ItemConfigurableProtocol {

    static var nibName: String { get { return "LargeItemCell" } }

    static var reuseIdentifier: String { get { return "LargeItemCell" } }

    static var size: CGSize { get { return CGSize(width: 860.0, height: 390.0) } }

    @IBOutlet var imageView: UIImageView!

    @IBOutlet var titleLabel: UILabel!

    @IBOutlet var subtitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
    }

    func configure(with data: CourseMock) {
        titleLabel.text = data.name
        subtitleLabel.text = data.host
    }

}
