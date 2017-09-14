//
//  EmailAuthViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class EmailAuthViewController: UIViewController {

    @IBOutlet var alertLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var alertBottomLabelConstraint: NSLayoutConstraint!

    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var textFieldPassword: AuthTextField!
    @IBOutlet weak var inputGroupPad: UIView!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var separatorHeight: NSLayoutConstraint!

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

    @IBAction func onLogInClick(_ sender: Any) {
        error = !error
    }

    @IBAction func onCloseClick(_ sender: Any) {
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .email, to: nil)
        }
    }

    @IBAction func onSignInWithSocialClick(_ sender: Any) {
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .email, to: .social)
        }
    }

    @IBAction func onSignUpClick(_ sender: Any) {
        if let navigationController = self.navigationController as? AuthNavigationViewController {
            navigationController.route(from: .email, to: .registration)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    private func setup() {
        // Title
        let attributedString = NSMutableAttributedString(string: "Sign In with e-mail")
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: titleLabel.font.pointSize, weight: UIFontWeightMedium), range: NSRange(location: 0, length: 7))
        titleLabel.attributedText = attributedString

        // Input group
        separatorHeight.constant = 0.5
        inputGroupPad.layer.borderWidth = 0.5
        inputGroupPad.layer.borderColor = UIColor(red: 151 / 255, green: 151 / 255, blue: 151 / 255, alpha: 1.0).cgColor
        textFieldPassword.fieldType = .password
    }
}
