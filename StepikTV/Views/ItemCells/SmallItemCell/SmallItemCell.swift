//
//  SmallItemCell.swift
//  stepik-tv
//
//  Created by Александр Пономарев on 20.10.17.
//  Copyright © 2017 Base team. All rights reserved.
//

import Foundation
import UIKit

class SmallItemCell: UICollectionViewCell, DynamicallyCreatedProtocol, ItemConfigurableProtocol {

    static var nibName: String { get { return "SmallItemCell" } }

    static var reuseIdentifier: String { get { return "SmallItemCell" } }

    static var size: CGSize { get { return CGSize(width: 308.0, height: 180.0) } }

    @IBOutlet var imageView: UIImageView!

    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
    }

    func configure(with data: CourseMock) {
        titleLabel.text = data.name
    }

}
