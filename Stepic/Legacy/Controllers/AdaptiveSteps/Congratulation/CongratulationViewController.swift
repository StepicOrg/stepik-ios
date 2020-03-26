//
//  CongratulationViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class CongratulationViewController: UIViewController {
    enum CongratulationType {
        var image: UIImage {
            switch self {
            case .achievement(_, _, let cover):
                return cover
            case .level:
                return Images.placeholders.coursePassed
            }
        }

        var congratulationText: String {
            switch self {
            case .level(let level):
                return String(format: NSLocalizedString("NewLevelCongratulationText", comment: ""), "\(level)")
            case .achievement(let name, _, _):
                return String(format: NSLocalizedString("AchievementCongratulationText", comment: ""), "\(name)")
            }
        }
        var shareText: String {
            switch self {
            case .level(let level):
                return String(format: NSLocalizedString("NewLevelCongratulationShareText", comment: ""), "\(level)", "\(CongratulationViewController.shareAppName)")
            case .achievement(let name, _, _):
                return String(format: NSLocalizedString("AchievementCongratulationShareText", comment: ""), "\(name)", "\(CongratulationViewController.shareAppName)")
            }
        }

        case level(level: Int)
        case achievement(name: String, info: String, cover: UIImage)
    }

    private static let shareAppName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "Stepik"

    var continueHandler: (() -> Void)?

    var congratulationType: CongratulationType!

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet var separatorView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.colorize()
        self.localize()

        self.textLabel.text = self.congratulationType.congratulationText
        self.coverImageView.image = self.congratulationType.image
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    @IBAction
    func onShareButtonClick(_ sender: Any) {
        guard let url = URL(string: "https://itunes.apple.com/app/id\(StepikApplicationsInfo.appId)") else {
            return
        }

        let activityViewController = UIActivityViewController(
            activityItems: [self.congratulationType.shareText, url],
            applicationActivities: nil
        )
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
        activityViewController.popoverPresentationController?.sourceView = shareButton

        self.present(activityViewController, animated: true)
    }

    @IBAction
    func onContinueButtonClick(_ sender: Any) {
        dismiss(animated: true, completion: { [weak self] in
            self?.continueHandler?()
        })
    }

    private func localize() {
        self.shareButton.setTitle(NSLocalizedString("ShareAchievement", comment: ""), for: .normal)
        self.continueButton.setTitle(NSLocalizedString("Continue", comment: ""), for: .normal)
    }

    private func colorize() {
        self.view.backgroundColor = .stepikAlertBackground
        self.shareButton.tintColor = .stepikAccent
        self.separatorView.backgroundColor = .stepikSeparator
        self.continueButton.tintColor = .stepikAccent
    }
}
