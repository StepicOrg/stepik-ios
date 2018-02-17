//
//  RegularItemCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 11.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class RegularItemCell: ImageConvertableCollectionViewCell {
    static var nibName: String { return "RegularItemCell" }
    static var reuseIdentifier: String { return "RegularItemCell" }
    static var size: CGSize { return CGSize(width: 548.0, height: 308.0) }

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

        imageView.setImageWithURL(url: item.backgroundImageURL, placeholder: item.placeholder) {
            let data = UIImageJPEGRepresentation(self.imageView.image!, 1)
            let image = UIImage(data: data!)!
            self.imageView.image = self.generateImage(with: item.title, inImage: image)
        }
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        guard presses.first!.type != UIPressType.menu else { return }

        pressAction?()
    }

    override func getTextRect(_ text: String) -> CGRect {
        let leading: CGFloat = 38.0
        let top: CGFloat = 204.0
        let width: CGFloat = imageView.bounds.width - leading * 2
        let height: CGFloat = 72.0

        return CGRect(x: leading, y: top, width: width, height: height)
    }

    override func getTextAttributes() -> [NSAttributedStringKey: Any] {
        let textColor = UIColor.white
        let textFont = UIFont.systemFont(ofSize: 31.0, weight: .heavy)
        let style = NSMutableParagraphStyle()
            style.lineBreakMode = .byWordWrapping
        let offset = NSNumber(value: 0)

        return [NSAttributedStringKey.font: textFont, NSAttributedStringKey.foregroundColor: textColor, NSAttributedStringKey.paragraphStyle: style, NSAttributedStringKey.baselineOffset: offset]
    }
}
