//
//  AuthTextField.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AuthTextField: UITextField {
    let eyeButtonSize = CGSize(width: 50, height: 50)

    enum `Type` {
        case text, password
    }

    var fieldType: Type = .text {
        didSet {
            switch fieldType {
            case .password:
                self.rightView = createEyeButton()
                self.rightViewMode = .always
            default:
                rightView = nil
            }
        }
    }

    // dx and dy for inset = 1/3 * height (empirical)
    var insetDelta: CGFloat {
        return self.bounds.height / 3
    }

    @IBAction func togglePasswordField(_ sender: Any) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        if let button = self.rightView as? UIButton {
            button.setImage(isSecureTextEntry ? #imageLiteral(resourceName: "eye_opened") : #imageLiteral(resourceName: "eye_closed"), for: .normal)
        }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let newBounds = bounds.insetBy(dx: insetDelta, dy: insetDelta)
        return fieldType == .text ? newBounds : CGRect(x: newBounds.origin.x, y: newBounds.origin.y, width: bounds.width - eyeButtonSize.width - 10, height: newBounds.height)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let newBounds = bounds.insetBy(dx: insetDelta, dy: insetDelta)
        return fieldType == .text ? newBounds : CGRect(x: newBounds.origin.x, y: newBounds.origin.y, width: bounds.width - eyeButtonSize.width - 10, height: newBounds.height)
    }

    private func createEyeButton() -> UIButton {
        let rightButton = UIButton(type: .system)
        rightButton.setImage(#imageLiteral(resourceName: "eye_opened"), for: .normal)
        rightButton.tintColor = UIColor(red: 83 / 255, green: 83 / 255, blue: 102 / 255, alpha: 1.0)
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        rightButton.frame = CGRect(x: frame.size.width - eyeButtonSize.width, y: insetDelta, width: eyeButtonSize.width, height: eyeButtonSize.height)
        rightButton.addTarget(self, action: #selector(self.togglePasswordField), for: .touchUpInside)

        return rightButton
    }
}
