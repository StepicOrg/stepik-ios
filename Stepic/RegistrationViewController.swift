//
//  RegistrationViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {
    @IBOutlet weak var alertBottomLabelConstraint: NSLayoutConstraint!
    @IBOutlet var alertLabelHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var textFieldPassword: AuthTextField!
    @IBOutlet weak var inputGroupPad: UIView!

    @IBOutlet weak var separatorFirstHeight: NSLayoutConstraint!
    @IBOutlet weak var separatorSecondHeight: NSLayoutConstraint!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tosLabel: UILabel!

    var error: Bool = false {
        didSet {
            if error {
                alertBottomLabelConstraint.constant = 16
                alertLabelHeightConstraint.isActive = false
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.layoutIfNeeded()
                })
                inputGroupPad.backgroundColor = inputGroupPad.backgroundColor?.withAlphaComponent(0.05)
            } else {
                alertBottomLabelConstraint.constant = 0
                alertLabelHeightConstraint.isActive = true
                UIView.animate(withDuration: 0.1, animations: {
                    self.view.layoutIfNeeded()
                })
                inputGroupPad.backgroundColor = inputGroupPad.backgroundColor?.withAlphaComponent(0.0)
            }
        }
    }

    @IBAction func onCloseClick(_ sender: Any) {
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .registration, to: nil)
        }
    }

    @IBAction func onLogInClick(_ sender: Any) {
        error = !error
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        // Title
        var attributedString = NSMutableAttributedString(string: "Sign Up")
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: titleLabel.font.pointSize, weight: UIFontWeightMedium), range: NSRange(location: 0, length: 7))
        titleLabel.attributedText = attributedString

        // Input group
        separatorFirstHeight.constant = 0.5
        separatorSecondHeight.constant = 0.5
        inputGroupPad.layer.borderWidth = 0.5
        inputGroupPad.layer.borderColor = UIColor(red: 151 / 255, green: 151 / 255, blue: 151 / 255, alpha: 1.0).cgColor
        textFieldPassword.fieldType = .password

        // Term of service warning
        attributedString = NSMutableAttributedString(string: "By registering you agree to the Terms of service and Privacy policy.")
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 102.0 / 255.0, green: 204.0 / 255.0, blue: 102.0 / 255.0, alpha: 1.0), range: NSRange(location: 32, length: 16))
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 102.0 / 255.0, green: 204.0 / 255.0, blue: 102.0 / 255.0, alpha: 1.0), range: NSRange(location: 53, length: 14))
        tosLabel.attributedText = attributedString
    }
}
