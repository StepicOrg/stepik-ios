//
//  NarrowItemCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 11.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class NarrowItemCell: ImageConvertableCollectionViewCell {
    static var nibName: String { return "NarrowItemCell" }
    static var reuseIdentifier: String { return "NarrowItemCell" }
    static var size: CGSize { return CGSize(width: 308.0, height: 180.0) }

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    var pressAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false

        isGradientNeeded = false
    }
    func setup(with item: ItemViewData) {
        titleLabel.text = item.title
        pressAction = item.action

        imageView.image = item.placeholder
        self.imageView.image = generateImage(with: item.title, inImage: item.placeholder).getRoundedCornersImage(cornerRadius: 6.0)
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        guard presses.first!.type != UIPressType.menu else { return }

        pressAction?()
    }

    override func getTextRect(_ text: String) -> CGRect {
        let leading: CGFloat = 17.0
        let width: CGFloat = imageView.bounds.width - leading * 2
        let height = UILabel.heightForLabelWithText(text, lines: 0, font: UIFont.systemFont(ofSize: 31, weight: .medium), width: width, alignment: .center)
        let top: CGFloat = (imageView.bounds.height - height) / 2

        return CGRect(x: leading, y: top, width: width, height: height)
    }

    override func getTextAttributes() -> [NSAttributedStringKey : Any] {
        let textColor = UIColor.white
        let textFont = UIFont.systemFont(ofSize: 31.0, weight: .medium)
        let style = NSMutableParagraphStyle()
            style.alignment = .center
            style.lineBreakMode = .byWordWrapping
            style.lineHeightMultiple = 0.95
        let offset = NSNumber(value: 5)

        return [NSAttributedStringKey.font: textFont, NSAttributedStringKey.foregroundColor: textColor, NSAttributedStringKey.paragraphStyle: style, NSAttributedStringKey.baselineOffset: offset]
    }
}
