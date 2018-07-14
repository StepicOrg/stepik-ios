//
//  EmptyAuthViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 12/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class EmptyAuthViewController: UIViewController {

    private let gradientLayer = CAGradientLayer(
        colors: [UIColor.stepicGreen, UIColor(hex: 0x4CAF50), UIColor(hex: 0x8BC34A)],
        rotationAngle: 0.0
    )

    // MARK: UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: Actions

    @IBAction func onSignIn(_ sender: Any) {
    }

    @IBAction func onSignUp(_ sender: Any) {
    }

    @IBAction func onLater(_ sender: Any) {
        dismiss(sender)
    }

    // MARK: Private API

    private func setup() {
        view.backgroundColor = .clear
        view.layer.insertSublayer(gradientLayer, at: 0)

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "close"),
            style: .plain,
            target: self,
            action: #selector(dismiss(_:))
        )
        navigationItem.leftBarButtonItem?.tintColor = .white
    }

    @objc private func dismiss(_ sender: Any) {
        dismiss(animated: true)
    }

}
