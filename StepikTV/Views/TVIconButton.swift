//
//  IconButton.swift
//  StepikTV
//
//  Created by Александр Пономарев on 29.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class TVIconButton: UIView, FocusAnimatable {

    override var canBecomeFocused: Bool { return isEnabled }

    @IBOutlet private var button: IconButton!
    @IBOutlet private var label: UILabel!

    var isEnabled: Bool = false {
        didSet {
            button.isEnabled = isEnabled
            if isEnabled {
                button.alpha = 1
            } else {
                button.alpha = 0.6
            }
        }
    }

    var pressAction : (() -> Void)?

    func configure(with icon: UIImage, _ title: String) {
        button.setImage(icon, for: .normal)
        label.text = title
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        super.pressesBegan(presses, with: event)
        guard presses.first!.type != UIPressType.menu else { return }

        if isEnabled { pressAction?() }
    }

    func changeToDefault() {
        button.changeToDefault()
        self.label.transform = CGAffineTransform.identity
    }

    func changeToFocused() {
        button.changeToFocused()
        self.label.transform = CGAffineTransform.identity.translatedBy(x: 0, y: 10).scaledBy(x: 1.15, y: 1.15)
    }

    func changeToHighlighted() {
        button.changeToHighlighted()
        self.changeToFocused()
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        self.updateFocus(in: context, with: coordinator)
    }

}

class IconButton: UIButton {

    override var canBecomeFocused: Bool { return false }

    func changeToDefault() {
        let color = UIColor(hex: 0x80c972)
        let imageColor = UIColor.white

        self.transform = CGAffineTransform.identity
        self.layer.shadowOpacity = 0.0
        self.imageView?.tintColor = imageColor
        self.backgroundColor = color
    }

    func changeToFocused() {
        let color = UIColor(hex: 0x80c972)
        let imageColor = UIColor.white
        let scale = CGFloat(1.25)

        self.transform = CGAffineTransform(scaleX: scale, y: scale)
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 15)
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.25
        self.imageView?.tintColor = imageColor
        self.backgroundColor = color
    }

    func changeToHighlighted() {
        self.transform = CGAffineTransform.identity
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowOpacity = 0.15
    }

    func initStyle() {
        self.setRoundedCorners(cornerRadius: 6)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initStyle()
        changeToDefault()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initStyle()
        changeToDefault()
    }

}
