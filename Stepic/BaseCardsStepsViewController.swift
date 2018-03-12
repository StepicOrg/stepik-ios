//
//  BaseCardsStepsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 02.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class BaseCardsStepsViewController: CardsStepsViewController {
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var expLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var labelsStackView: UIStackView!
    @IBOutlet weak var shadowViewHeight: NSLayoutConstraint!
    @IBOutlet weak var trophyButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shadowView: UIView!

    fileprivate var statusBarPad: UIView?
    private var shouldToggleNavigationBar = true

    // For init View-Presenter via view creating
    var course: Course!
    var didJustSubscribe: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""

        shadowViewHeight.constant = 0.5

        statusBarPad = UIView()
        statusBarPad?.backgroundColor = UIColor.mainLight
        if let padView = statusBarPad {
            view.insertSubview(padView, at: 0)
        }

        trophyButton.layer.zPosition = kolodaView.layer.zPosition - 1
        backButton.layer.zPosition = kolodaView.layer.zPosition - 1
        statusBarPad?.layer.zPosition = kolodaView.layer.zPosition - 1
        progressBar.layer.zPosition = kolodaView.layer.zPosition - 1
        labelsStackView.layer.zPosition = kolodaView.layer.zPosition - 1
        shadowView.layer.zPosition = kolodaView.layer.zPosition - 1

        progressBar.progress = 0

        if presenter == nil {
            presenter = BaseCardsStepsPresenter(stepsAPI: StepsAPI(), lessonsAPI: LessonsAPI(), recommendationsAPI: RecommendationsAPI(), unitsAPI: UnitsAPI(), viewsAPI: ViewsAPI(), ratingsAPI: AdaptiveRatingsAPI(), ratingManager: AdaptiveRatingManager(courseId: course.id), statsManager: AdaptiveStatsManager(courseId: course.id), storageManager: AdaptiveStorageManager(), lastViewedUpdater: LocalProgressLastViewedUpdater(), notificationSuggestionManager: NotificationSuggestionManager(), notificationPermissionManager: NotificationPermissionManager(), course: course, view: self)
            presenter?.refresh()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        statusBarPad?.frame = CGRect(x: UIApplication.shared.statusBarFrame.origin.x, y: UIApplication.shared.statusBarFrame.origin.y, width: UIApplication.shared.statusBarFrame.width, height: progressBar.frame.origin.y)

        if DeviceInfo.current.orientation.interface.isLandscape && !DeviceInfo.current.isPad {
            labelsStackView.axis = .horizontal
            labelsStackView.spacing = 8
        } else {
            labelsStackView.axis = .vertical
            labelsStackView.spacing = 0
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shouldToggleNavigationBar = false
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if shouldToggleNavigationBar {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if didJustSubscribe {
            didJustSubscribe = false
            presenter?.appearedAfterSubscription()
        }
    }

    @IBAction func onBackButtonClick(_ sender: Any) {
        shouldToggleNavigationBar = true
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onTrophyButtonClick(_ sender: Any) {
        guard let vc = ControllerHelper.instantiateViewController(identifier: "Stats", storyboardName: "Adaptive") as? AdaptiveStatsPagerViewController else {
            return
        }

        guard let course = presenter?.course else {
            return
        }

        shouldToggleNavigationBar = true

        vc.ratingsManager = AdaptiveRatingManager(courseId: course.id)
        vc.statsManager = AdaptiveStatsManager(courseId: course.id)

        navigationController?.pushViewController(vc, animated: true)
    }

    override func updateProgress(rating: Int, prevMaxRating: Int, maxRating: Int, level: Int) {
        super.updateProgress(rating: rating, prevMaxRating: prevMaxRating, maxRating: maxRating, level: level)

        let currentLevel = level

        expLabel.text = String(format: NSLocalizedString("RatingProgress", comment: ""), "\(rating)", "\(maxRating)")
        levelLabel.text = String(format: NSLocalizedString("RatingProgressLevel", comment: ""), "\(currentLevel)")

        let newProgress = Float(rating - prevMaxRating) / Float(maxRating - prevMaxRating)
        let shouldFulfill = progressBar.progress > newProgress
        let progressAddition: Float = 0.005

        guard !progressBar.progress.isEqual(to: newProgress + progressAddition) else {
            return
        }

        progressBar.progress = shouldFulfill ? 100.0 : newProgress + progressAddition
        UIView.animate(withDuration: 1.2, animations: {
            self.progressBar.layoutIfNeeded()
        }, completion: { _ in
            if !shouldFulfill {
                return
            }

            self.progressBar.progress = 0
            self.progressBar.layoutIfNeeded()

            self.progressBar.progress = newProgress + progressAddition
            UIView.animate(withDuration: 1.2, animations: {
                self.progressBar.layoutIfNeeded()
            }, completion: nil)
        })
    }

    override func showCongratulation(for rating: Int, isSpecial: Bool, completion: (() -> Void)? = nil) {
        let text = self.expLabel.text ?? ""
        let color = self.expLabel.textColor ?? UIColor.mainDark

        func transitionToText(_ text: String, color: UIColor, duration: Double, completionBlock: (() -> Void)? = nil) {
            UIView.transition(with: self.expLabel, duration: duration, options: .transitionCrossDissolve, animations: {
                self.expLabel.textColor = UIColor.clear
            }, completion: { _ in
                self.expLabel.text = text
                UIView.transition(with: self.expLabel, duration: duration, options: .transitionCrossDissolve, animations: {
                    self.expLabel.textColor = color
                }, completion: { _ in completionBlock?() })
            })
        }

        transitionToText(String(format: NSLocalizedString("RatingCongratulationText", comment: ""), "\(rating)"), color: UIColor(hex: 0x008040), duration: 0.4, completionBlock: { () -> Void in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                transitionToText(text, color: color, duration: 0.4, completionBlock: { completion?() })
            })
        })
    }

    override func presentDiscussions(stepId: Int, discussionProxyId: String) {
        shouldToggleNavigationBar = true
        super.presentDiscussions(stepId: stepId, discussionProxyId: discussionProxyId)
    }
}
