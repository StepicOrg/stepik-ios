//
//  AdaptiveCardsStepsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 01.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

extension StepikPlaceholder.Style {
    static let adaptiveCoursePassedAdaptive = StepikPlaceholderStyle(id: "adaptiveCoursePassedAdaptive",
                                                                     image: nil,
                                                                     text: NSLocalizedString("NoRecommendations", comment: ""),
                                                                     buttonTitle: nil)
}

class AdaptiveCardsStepsViewController: CardsStepsViewController {
    @IBOutlet weak var levelProgress: RatingProgressView!
    @IBOutlet weak var tapProxyView: TapProxyView!
    @IBOutlet weak var trophyButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tapBackProxyView: TapProxyView!

    override var cardView: StepCardView {
        return AdaptiveStepCardView()
    }

    var isBackActionAllowed = true

    @IBAction func onTrophyButtonClick(_ sender: Any) {
        guard let navVC = ControllerHelper.instantiateViewController(identifier: "Stats", storyboardName: "AdaptiveMain") as? StyledNavigationController else {
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
        vc.achievementsManager = AchievementManager.shared

        present(navVC, animated: true, completion: nil)
    }

    @IBAction func onBackButtonClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        registerPlaceholder(placeholder: StepikPlaceholder(.adaptiveCoursePassedAdaptive), for: .adaptiveCoursePassed)

        tapProxyView.targetView = trophyButton
        tapBackProxyView.targetView = backButton
        trophyButton.tintColor = UIColor.mainDark
        backButton.tintColor = UIColor.mainDark

        if !isBackActionAllowed {
            tapBackProxyView.removeFromSuperview()
            backButton.removeFromSuperview()
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: levelProgress, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 10)
            ])
        }

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
