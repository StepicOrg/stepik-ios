//
//  OnboardingPageView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class OnboardingPageView: NibInitializableView {
    enum NextButtonStyle {
        var title: String {
            switch self {
            case .next:
                return NSLocalizedString("OnboardingNextButton", comment: "")
            case .start:
                return NSLocalizedString("OnboardingStartButton", comment: "")
            }
        }

        var backgroundColor: UIColor {
            switch self {
            case .next:
                return .clear
            case .start:
                return UIColor.white.withAlphaComponent(0.1)
            }
        }

        var borderWidth: CGFloat {
            switch self {
            case .next:
                return 1.0
            case .start:
                return 0.0
            }
        }

        case next
        case start
    }

    override var nibName: String {
        return "OnboardingPageView"
    }

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageTitleLabel: StepikLabel!
    @IBOutlet weak var pageDescriptionLabel: StepikLabel!
    @IBOutlet private weak var buttonPaddingConstraint: NSLayoutConstraint!

    var buttonStyle: NextButtonStyle = .next {
        didSet {
            nextButton.backgroundColor = buttonStyle.backgroundColor
            nextButton.layer.borderWidth = buttonStyle.borderWidth
            nextButton.setTitle(buttonStyle.title, for: .normal)
        }
    }

    var onClick: (() -> Void)?

    var height: CGFloat {
        // 28 – 24 + 4, constraints from xib
        pageTitleLabel.sizeToFit()
        pageDescriptionLabel.sizeToFit()
        return 28 + pageDescriptionLabel.bounds.size.height + pageTitleLabel.bounds.size.height + nextButton.bounds.size.height + buttonPaddingConstraint.constant
    }

    @IBAction func onNextButtonClick(_ sender: Any) {
        onClick?()
    }

    override func setupSubviews() {
        pageTitleLabel.textColor = UIColor.white
        pageDescriptionLabel.textColor = UIColor.white.withAlphaComponent(0.6)

        nextButton.backgroundColor = .clear
        nextButton.layer.borderWidth = 1
        nextButton.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
    }

    func updateHeight(_ delta: CGFloat) {
        buttonPaddingConstraint.constant = 24 + delta
    }
}
