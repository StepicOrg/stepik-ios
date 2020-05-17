//
//  RateAppViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 07.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import MessageUI
import Presentr
import SnapKit
import StoreKit
import UIKit

final class RateAppViewController: UIViewController {
    enum AfterRateActionType {
        case appStore
        case email
    }

    @IBOutlet weak var topLabel: StepikLabel!
    @IBOutlet weak var bottomLabel: StepikLabel!
    @IBOutlet weak var laterButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet var buttonsContainerView: UIView!
    @IBOutlet var buttonsSeparator: UIView!

    @IBOutlet weak var centerViewWidth: NSLayoutConstraint!

    @IBOutlet var starImageViews: [UIImageView]!

    @IBOutlet weak var buttonsContainerHeight: NSLayoutConstraint!

    var lessonProgress: String?

    private var defaultAnalyticsParams: [String: Any] {
        if let progress = self.lessonProgress {
            return ["lesson_progress": progress]
        } else {
            return [:]
        }
    }

    private var buttonState: AfterRateActionType? = nil {
        didSet {
            guard self.buttonState != nil else {
                return
            }

            switch self.buttonState! {
            case .appStore:
                self.rightButton.titleLabel?.text = NSLocalizedString("AppStore", comment: "")
                self.rightButton.setTitle(NSLocalizedString("AppStore", comment: ""), for: .normal)
                self.rightButton.setTitleColor(.stepikGreen, for: .normal)
            case .email:
                self.rightButton.titleLabel?.text = NSLocalizedString("Email", comment: "")
                self.rightButton.setTitle(NSLocalizedString("Email", comment: ""), for: .normal)
                self.rightButton.setTitleColor(.stepikRed, for: .normal)
            }
        }
    }

    private var bottomLabelWidth: Constraint?

    private let mailPresenter: Presentr = {
        let width = ModalSize.sideMargin(value: 0)
        let height = ModalSize.sideMargin(value: 0)
        let center = ModalCenterPosition.center
        let customType = PresentationType.custom(width: width, height: height, center: center)

        let presenter = Presentr(presentationType: customType)
        presenter.roundCorners = false

        return presenter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.centerViewWidth.constant = 0.5
        self.buttonsContainerHeight.constant = 0
        self.buttonsContainerView.alpha = 0

        self.laterButton.setTitle(NSLocalizedString("Later", comment: ""), for: .normal)
        self.topLabel.text = String(
            format: NSLocalizedString("HowWouldYouRate", comment: ""),
            Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Stepik"
        )
        self.bottomLabel.text = ""

        self.bottomLabel.snp.makeConstraints { make in
            self.bottomLabelWidth = make.width.lessThanOrEqualTo(UIScreen.main.bounds.width - 48).constraint
        }

        for star in self.starImageViews {
            print(star.tag)
            let tapG = UITapGestureRecognizer(target: self, action: #selector(RateAppViewController.didTap(_:)))
            star.isUserInteractionEnabled = true
            star.image = Images.star.empty
            star.highlightedImage = Images.star.filled
            star.addGestureRecognizer(tapG)
        }

        self.colorize()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.bottomLabelWidth?.update(offset: UIScreen.main.bounds.height - 48)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    private func colorize() {
        self.view.backgroundColor = .stepikAlertBackground
        self.buttonsContainerView.backgroundColor = .stepikAlertBackground
        self.buttonsSeparator.backgroundColor = .stepikOpaqueSeparator
        self.laterButton.setTitleColor(.stepikAccent, for: .normal)
    }

    @objc
    private func didTap(_ recognizer: UITapGestureRecognizer) {
        guard let tappedIndex = recognizer.view?.tag else {
            return
        }

        for star in self.starImageViews {
            if star.tag <= tappedIndex {
                star.isHighlighted = true
            }
            star.isUserInteractionEnabled = false
        }

        self.topLabel.text = NSLocalizedString("ThankYou", comment: "")
        let rating = tappedIndex + 1

        var params = defaultAnalyticsParams
        params["rating"] = rating
        StepikAnalytics.shared.send(.rateAppTapped(parameters: params))

        if rating < 4 {
            self.buttonState = .email
            self.bottomLabel.text = NSLocalizedString("PleaseLeaveFeedbackEmail", comment: "")
        } else {
            self.buttonState = .appStore
            self.bottomLabel.text = NSLocalizedString("PleaseLeaveFeedbackAppstore", comment: "")
        }

        self.buttonsContainerHeight.constant = 48
        self.buttonsContainerView.alpha = 1

        self.view.frame = CGRect(
            origin: self.view.frame.origin,
            size: CGSize(width: self.view.frame.width, height: self.view.frame.height + 48.0)
        )

        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.view.layoutIfNeeded()
            }
        )
    }

    private func showEmail() {
        StepikAnalytics.shared.send(.rateAppNegativeStateWriteEmailTapped(parameters: self.defaultAnalyticsParams))

        if !MFMailComposeViewController.canSendMail() {
            return self.dismiss(animated: true, completion: nil)
        }

        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["support@stepik.org"])
        composeVC.setSubject(
            String(
                format: NSLocalizedString("FeedbackAbout", comment: ""),
                Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? "Stepik"
            )
        )
        composeVC.setMessageBody("", isHTML: false)

        self.customPresentViewController(self.mailPresenter, viewController: composeVC, animated: true, completion: nil)
    }

    private func showAppStore() {
        StepikAnalytics.shared.send(.rateAppPositiveStateAppStoreTapped(parameters: self.defaultAnalyticsParams))
        self.dismiss(animated: true, completion: {
            SKStoreReviewController.requestReview()
        })
    }

    @IBAction
    func laterButtonPressed(_ sender: UIButton) {
        RoutingManager.rate.pressedShowLater()
        self.dismiss(animated: true, completion: nil)

        guard self.buttonState != nil else {
            return
        }

        switch self.buttonState! {
        case .appStore:
            StepikAnalytics.shared.send(.rateAppPositiveStateLaterTapped(parameters: self.defaultAnalyticsParams))
        case .email:
            StepikAnalytics.shared.send(.rateAppNegativeStateLaterTapped(parameters: self.defaultAnalyticsParams))
        }
    }

    @IBAction
    func rightButtonPressed(_ sender: UIButton) {
        guard self.buttonState != nil else {
            return
        }

        RoutingManager.rate.neverShow()

        switch self.buttonState! {
        case .appStore:
            self.showAppStore()
        case .email:
            self.showEmail()
        }
    }
}

extension RateAppViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        switch result {
        case .cancelled, .failed, .saved:
            StepikAnalytics.shared.send(.rateAppNegativeStateWriteEmailCancelled(parameters: self.defaultAnalyticsParams))
        case .sent:
            StepikAnalytics.shared.send(.rateAppNegativeStateWriteEmailSucceeded(parameters: self.defaultAnalyticsParams))
        @unknown default:
            break
        }

        controller.dismiss(
            animated: true,
            completion: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        )
    }
}
