//
//  GreetingAuthViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 12/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class GreetingAuthViewController: UIViewController {

    // MARK: Instance Properties

    var router: AuthorizationGreetingRouter?

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
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: Actions

    @IBAction private func onSignIn(_ sender: Any) {
        router?.showSignIn()
    }

    @IBAction private func onSignUp(_ sender: Any) {
        router?.showSignUp()
    }

    @IBAction private func onLater(_ sender: Any) {
        dismiss(sender)
    }

    @objc private func dismiss(_ sender: Any) {
        router?.dismiss()
    }

}
