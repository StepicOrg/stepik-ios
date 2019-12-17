//
//  AuthTextField.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

extension AuthTextField {
    enum Appearance {
        static let tintColor = UIColor.mainText

        static let eyeButtonSize = CGSize(width: 50, height: 50)
        static let imageEyeOpened = UIImage(named: "eye_opened")
        static let imageEyeClosed = UIImage(named: "eye_closed")
    }
}

final class AuthTextField: UITextField {
    private lazy var eyeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Appearance.imageEyeOpened, for: .normal)
        button.tintColor = Appearance.tintColor
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        button.frame = CGRect(
            x: self.frame.size.width - Appearance.eyeButtonSize.width,
            y: self.insetDelta,
            width: Appearance.eyeButtonSize.width,
            height: Appearance.eyeButtonSize.height
        )
        button.addTarget(self, action: #selector(self.togglePasswordField), for: .touchUpInside)
        return button
    }()

    var fieldType: Type = .text {
        didSet {
            switch self.fieldType {
            case .password:
                self.rightView = self.eyeButton
                self.rightViewMode = .always
            default:
                rightView = nil
            }
        }
    }

    // dx and dy for inset = 1/3 * height (empirical)
    var insetDelta: CGFloat { self.bounds.height / 3 }

    override func textRect(forBounds bounds: CGRect) -> CGRect { self.contentRect(for: bounds) }

    override func editingRect(forBounds bounds: CGRect) -> CGRect { self.contentRect(for: bounds) }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        if self.fieldType == .text {
            return .zero
        } else {
            return CGRect(
                x: bounds.width - Appearance.eyeButtonSize.width,
                y: (bounds.size.height - Appearance.eyeButtonSize.height) / 2,
                width: Appearance.eyeButtonSize.width,
                height: Appearance.eyeButtonSize.height
            )
        }
    }

    @IBAction
    func togglePasswordField(_ sender: Any) {
        self.isSecureTextEntry.toggle()

        if let button = self.rightView as? UIButton {
            button.setImage(
                self.isSecureTextEntry ? Appearance.imageEyeOpened : Appearance.imageEyeClosed,
                for: .normal
            )
        }
    }

    private func contentRect(for bounds: CGRect) -> CGRect {
        let newBounds = bounds.insetBy(dx: self.insetDelta, dy: self.insetDelta)

        if self.fieldType == .text {
            return newBounds
        } else {
            return CGRect(
                x: newBounds.origin.x,
                y: newBounds.origin.y,
                width: bounds.width - Appearance.eyeButtonSize.width - 10,
                height: newBounds.height
            )
        }
    }

    enum `Type` {
        case text
        case password
    }
}
