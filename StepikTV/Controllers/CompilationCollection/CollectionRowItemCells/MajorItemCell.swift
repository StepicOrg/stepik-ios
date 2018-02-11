//
//  MajorItemCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 11.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class MajorItemCell: ImageConvertableCollectionViewCell {
    static var nibName: String { return "MajorItemCell" }
    static var reuseIdentifier: String { return "MajorItemCell" }
    static var size: CGSize { return CGSize(width: 860.0, height: 390.0) }

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!

    var pressAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.adjustsImageWhenAncestorFocused = true
        imageView.clipsToBounds = false
    }

    func setup(with item: ItemViewData) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        pressAction = item.action

        imageView.setImageWithURL(url: item.backgroundImageURL, placeholder: item.placeholder) {
            let data = UIImageJPEGRepresentation(self.imageView.image!, 1)
            let image = UIImage(data: data!)!
            self.imageView.image = self.generateImage(with: item.title, additionalText: item.subtitle!, inImage: image)
        }
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        guard presses.first!.type != UIPressType.menu else { return }

        pressAction?()
    }

    override func getTextRect(_ text: String) -> CGRect {
        let leading: CGFloat = 38.0
        let top: CGFloat = 280.0
        let width: CGFloat = imageView.bounds.width - leading * 2
        let height: CGFloat = 72.0

        return CGRect(x: leading, y: top, width: width, height: height)
    }

    override func getTextAttributes() -> [String : Any] {
        let textColor = UIColor.white
        let textFont = UIFont.systemFont(ofSize: 31.0, weight: UIFontWeightHeavy)
        let style = NSMutableParagraphStyle()
            style.lineBreakMode = .byWordWrapping

        return [NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor] as [String : Any]
    }

    override func getAdditionalTextRect(_ text: String) -> CGRect {
        let leading: CGFloat = 38.0
        let top: CGFloat = 315.0
        let width: CGFloat = imageView.bounds.width - leading * 2
        let height: CGFloat = 72.0

        return CGRect(x: leading, y: top, width: width, height: height)
    }

    override func getAdditionalTextAttributes() -> [String : Any] {
        let textColor = UIColor.white
        let textFont = UIFont.preferredFont(forTextStyle: .callout)
        let style = NSMutableParagraphStyle()
            style.lineBreakMode = .byWordWrapping

        return [NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor, NSParagraphStyleAttributeName: style] as [String : Any]
    }
}
