//
//  GreetingAuthViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 12/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class AuthGreetingViewController: UIViewController {
    @IBOutlet var signInButton: BorderedButton!
    @IBOutlet var signUpButton: BorderedButton!
    @IBOutlet var laterButton: UIButton!

    var presenter: AuthGreetingPresenterProtocol?

    private let gradientLayer = CAGradientLayer(
        colors: [UIColor.stepicGreen, UIColor(hex: 0x4CAF50), UIColor(hex: 0x8BC34A)],
        rotationAngle: 0.0
    )

    // MARK: UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        view.layer.insertSublayer(gradientLayer, at: 0)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Dismiss Auth"),
            style: .plain,
            target: self,
            action: #selector(dismiss(_:))
        )
        navigationItem.leftBarButtonItem?.tintColor = .white

        localize()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    private func localize() {
        signInButton.setTitle(NSLocalizedString("SignIn", comment: ""), for: .normal)
        signUpButton.setTitle(NSLocalizedString("SignUp", comment: ""), for: .normal)
        laterButton.setTitle(NSLocalizedString("Later", comment: ""), for: .normal)
    }

    // MARK: Actions

    @IBAction private func onSignIn(_ sender: Any) {
        presenter?.signIn()
    }

    @IBAction private func onSignUp(_ sender: Any) {
        presenter?.signUp()
    }

    @IBAction private func onLater(_ sender: Any) {
        dismiss(sender)
    }

    @objc private func dismiss(_ sender: Any) {
        presenter?.cancel()
    }
}
