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
            guard let preJpegImage = self.imageView.image,
                let jpegData = UIImageJPEGRepresentation(preJpegImage, 1),
                let jpegImage = UIImage(data:jpegData) else {
                    print("Problem with converting image: \(self.description)")
                    return
            }

            self.imageView.image = self.generateImage(with: item.title, additionalText: item.subtitle ?? "", inImage: jpegImage).getRoundedCornersImage(cornerRadius: 6.0)
        }
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesEnded(presses, with: event)

        guard presses.first!.type == UIPressType.select else { return }
        
        pressAction?()
    }

    override func getTextRect(_ text: String) -> CGRect {
        let leading: CGFloat = 38.0
        let top: CGFloat = 280.0
        let width: CGFloat = imageView.bounds.width - leading * 2
        let height: CGFloat = 72.0

        return CGRect(x: leading, y: top, width: width, height: height)
    }

    override func getTextAttributes() -> [NSAttributedStringKey : Any] {
        let textColor = UIColor.white
        let textFont = UIFont.systemFont(ofSize: 31.0, weight: .heavy)
        let style = NSMutableParagraphStyle()
            style.lineBreakMode = .byWordWrapping

        return [NSAttributedStringKey.font: textFont, NSAttributedStringKey.foregroundColor: textColor]
    }

    override func getAdditionalTextRect(_ text: String) -> CGRect {
        let leading: CGFloat = 38.0
        let top: CGFloat = 315.0
        let width: CGFloat = imageView.bounds.width - leading * 2
        let height: CGFloat = 72.0

        return CGRect(x: leading, y: top, width: width, height: height)
    }

    override func getAdditionalTextAttributes() -> [NSAttributedStringKey : Any] {
        let textColor = UIColor.white
        let textFont = UIFont.preferredFont(forTextStyle: .callout)
        let style = NSMutableParagraphStyle()
            style.lineBreakMode = .byWordWrapping

        return [NSAttributedStringKey.font: textFont, NSAttributedStringKey.foregroundColor: textColor, NSAttributedStringKey.paragraphStyle: style]
    }
}
