//
//  OnboardingPageView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class OnboardingPageView: NibInitializableView {
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

    override var nibName: String { "OnboardingPageView" }

    @IBOutlet weak var nextButton: StepikButton!
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
        self.pageTitleLabel.sizeToFit()
        self.pageDescriptionLabel.sizeToFit()

        let topOffset: CGFloat = 28
        let height: CGFloat = topOffset
            + self.pageDescriptionLabel.bounds.size.height
            + self.pageTitleLabel.bounds.size.height
            + self.nextButton.bounds.size.height
            + self.buttonPaddingConstraint.constant

        return height
    }

    var descriptionHeight: CGFloat {
        pageDescriptionLabel.sizeToFit()
        pageDescriptionLabel.layoutIfNeeded()
        return UILabel.heightForLabelWithText(pageDescriptionLabel.text ?? "", lines: 0, standardFontOfSize: pageDescriptionLabel.font.pointSize, width: pageDescriptionLabel.bounds.width)
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
        nextButton.setTitleColor(.white, for: .normal)

        // For iPhone 4s decrease font size
        if DeviceInfo.current.diagonal <= 3.5 {
            pageTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
            pageDescriptionLabel.font = UIFont.systemFont(ofSize: 15)
        }

        nextButton.accessibilityIdentifier = AccessibilityIdentifiers.Onboarding.nextButton
    }

    func updateHeight(_ delta: CGFloat) {
        // For iPhone 4s decrease padding: 16px instead of 24px
        buttonPaddingConstraint.constant = (DeviceInfo.current.diagonal <= 3.5 ? 16 : 24) + delta
    }
}
