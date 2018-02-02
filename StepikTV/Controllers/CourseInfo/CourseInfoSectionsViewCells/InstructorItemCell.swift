//
//  InstructorItemCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 09.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class InstructorItemCell: UICollectionViewCell, FocusAnimatable {

    static var nibName: String { return "InstructorItemCell" }
    static var reuseIdentifier: String { return "InstructorItemCell" }
    static var size: CGSize { return CGSize(width: 250.0, height: 326.0) }

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    var pressAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.layer.cornerRadius = imageView.bounds.height / 2
        imageView.layer.masksToBounds = true

        changeToDefault()
    }

    func setup(with item: ItemViewData) {
        titleLabel.text = item.title
        pressAction = item.action

        imageView.setImageWithURL(url: item.backgroundImageURL, placeholder: item.placeholder, completion: {
            let data = UIImageJPEGRepresentation(self.imageView.image!, 1)
            self.imageView.image = UIImage(data: data!)
        })
    }

    func changeToDefault() {
        self.transform = CGAffineTransform.identity
        self.layer.shadowOpacity = 0.0
        self.titleLabel.textColor = UIColor.black
    }

    func changeToFocused() {
        self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        self.layer.shadowOffset = CGSize(width: 0, height: 10)
        self.layer.shadowRadius = 25
        self.layer.shadowOpacity = 0.2
        self.layer.shadowPath = UIBezierPath(roundedRect: self.imageView.bounds, cornerRadius: self.imageView.bounds.height / 2).cgPath

        self.titleLabel.textColor = UIColor.white
    }

    func changeToHighlighted() {
        self.transform = CGAffineTransform.identity
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowOpacity = 0.15
    }

    // Events to look for a Highlighted state

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        guard presses.first!.type != UIPressType.menu else { return }

        pressAction?()
    }
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        self.updateFocus(in: context, with: coordinator)
    }

}
