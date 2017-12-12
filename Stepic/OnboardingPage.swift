//
//  OnboardingPage.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class OnboardingPage: NibInitializableView {
    override var nibName: String {
        return "OnboardingPage"
    }

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var pageDescriptionLabel: UILabel!

    override func setupSubviews() {
        super.setupSubviews()
        nextButton.backgroundColor = .clear
        nextButton.layer.cornerRadius = 5
        nextButton.layer.borderWidth = 1
        nextButton.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor

    }
}
