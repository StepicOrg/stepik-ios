//
//  AdaptiveCardsStepsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 01.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class AdaptiveCardsStepsViewController: CardsStepsViewController {
    @IBOutlet weak var levelProgress: RatingProgressView!
    @IBOutlet weak var tapProxyView: TapProxyView!
    @IBOutlet weak var trophyButton: UIButton!

    override var cardView: StepCardView {
        return AdaptiveStepCardView()
    }

    @IBAction func onTrophyButtonClick(_ sender: Any) {
        guard let navVC = ControllerHelper.instantiateViewController(identifier: "Stats", storyboardName: "AdaptiveMain") as? StyledNavigationViewController else {
            return
        }

        guard let vc = navVC.childViewControllers.first as? AdaptiveAdaptiveStatsPagerViewController else {
            return
        }

        guard let course = presenter?.course else {
            return
        }

        vc.ratingsManager = AdaptiveRatingManager(courseId: course.id)
        vc.statsManager = AdaptiveStatsManager(courseId: course.id)

        let rating = vc.ratingsManager?.rating ?? 0
        let streak = vc.ratingsManager?.streak ?? 1
        // Migration from old version
        let isOnboardingPassed = AdaptiveStorageManager.shared.isAdaptiveOnboardingPassed || DefaultsStorageManager.shared.isRatingOnboardingFinished

        vc.achievementsManager = AchievementManager.createAndRegisterAchievements(currentRating: rating, currentStreak: streak, currentLevel: AdaptiveRatingHelper.getLevel(for: rating), isOnboardingPassed: isOnboardingPassed)

        present(navVC, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tapProxyView.targetView = trophyButton
        trophyButton.tintColor = StepicApplicationsInfo.adaptiveMainColor

        presenter?.refresh()
    }

    override func updateProgress(rating: Int, prevMaxRating: Int, maxRating: Int, level: Int) {
        levelProgress.text = String(format: NSLocalizedString("RatingProgress", comment: ""), "\(rating)", "\(maxRating)") + " • " + String(format: NSLocalizedString("RatingProgressLevel", comment: ""), "\(level)")
        let newProgress = Float(rating - prevMaxRating) / Float(maxRating - prevMaxRating)
        levelProgress.hideCongratulation(force: true) {
            self.levelProgress.setProgress(value: newProgress, animated: true)
        }
    }

    override func showCongratulation(for rating: Int, isSpecial: Bool, completion: (() -> Void)? = nil) {
        levelProgress.showCongratulation(text: String(format: NSLocalizedString("RatingCongratulationText", comment: ""), "\(rating)"), duration: 1.0, isSpecial: isSpecial) {
            completion?()
        }
    }
}
