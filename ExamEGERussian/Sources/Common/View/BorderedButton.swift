//
//  RoundedButton.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 13/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

@IBDesignable
public final class BorderedButton: UIButton {

    @IBInspectable
    public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable
    public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable
    public var borderColor: UIColor? {
        get {
            guard let cgColor = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: cgColor)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable
    public var bottomInset: CGFloat {
        get {
            return contentInsets.bottom
        }
        set {
            contentInsets.bottom = newValue
        }
    }
    @IBInspectable
    public var leftInset: CGFloat {
        get {
            return contentInsets.left
        }
        set {
            contentInsets.left = newValue
        }
    }
    @IBInspectable
    public var rightInset: CGFloat {
        get {
            return contentInsets.right
        }
        set {
            contentInsets.right = newValue
        }
    }
    @IBInspectable
    public var topInset: CGFloat {
        get {
            return contentInsets.top
        }
        set {
            contentInsets.top = newValue
        }
    }

    private var contentInsets = UIEdgeInsets.zero {
        didSet {
            contentEdgeInsets = contentInsets
        }
    }

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: - Private API

    private func commonInit() {
        clipsToBounds = true
        contentEdgeInsets = contentInsets
    }

}
