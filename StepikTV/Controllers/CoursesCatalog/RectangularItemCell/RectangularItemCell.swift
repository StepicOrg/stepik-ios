//
//  RectangularItemCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 25.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class RectangularItemCell: UICollectionViewCell {

    static var nibName: String { get { return "RectangularItemCell" } }
    static var reuseIdentifier: String { get { return "RectangularItemCell" } }
    static var size: CGSize { get { return CGSize(width: 310.0, height: 350.0) } }

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    var pressAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
    }

    func setup(with item: ItemViewData) {
        titleLabel.text = item.title
        pressAction = item.action

        imageView.setImageWithURL(url: item.backgroundImageURL, placeholder: item.placeholder)
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)

        guard presses.first!.type != UIPressType.menu else { return }
        pressAction?()
    }
}
