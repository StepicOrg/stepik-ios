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
                self.rightView = eyeButton
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

    lazy var eyeButton: UIButton? = { [weak self] in
        guard let s = self else { return nil }

        let rightButton = UIButton(type: .system)
        rightButton.setImage(#imageLiteral(resourceName: "eye_opened"), for: .normal)
        rightButton.tintColor = UIColor.mainText
        rightButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        rightButton.frame = CGRect(x: s.frame.size.width - s.eyeButtonSize.width, y: s.insetDelta, width: s.eyeButtonSize.width, height: s.eyeButtonSize.height)
        rightButton.addTarget(self, action: #selector(s.togglePasswordField), for: .touchUpInside)

        return rightButton
    }()

    @IBAction func togglePasswordField(_ sender: Any) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        if let button = self.rightView as? UIButton {
            button.setImage(isSecureTextEntry ? #imageLiteral(resourceName: "eye_opened") : #imageLiteral(resourceName: "eye_closed"), for: .normal)
        }
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return contentRect(for: bounds)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return contentRect(for: bounds)
    }

    private func contentRect(for bounds: CGRect) -> CGRect {
        let newBounds = bounds.insetBy(dx: insetDelta, dy: insetDelta)
        return fieldType == .text ? newBounds : CGRect(x: newBounds.origin.x, y: newBounds.origin.y, width: bounds.width - eyeButtonSize.width - 10, height: newBounds.height)
    }
}
