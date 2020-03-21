//
//  BaseCardsStepsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 02.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class BaseCardsStepsViewController: CardsStepsViewController {
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var expLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var labelsStackView: UIStackView!
    @IBOutlet weak var shadowViewHeight: NSLayoutConstraint!
    @IBOutlet weak var trophyButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shadowView: UIView!

    private var statusBarPad: UIView?
    private var shouldToggleNavigationBar = true

    // For init View-Presenter via view creating
    var course: Course!
    var didJustSubscribe: Bool = false

    override var state: CardsStepsViewState {
        set {
            super.state = newValue
            if newValue != .normal {
                bringElementsToFront()
            } else {
                sendElementsToBack()
            }
        }
        get {
            super.state
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.statusBarPad?.frame = CGRect(
            x: UIApplication.shared.statusBarFrame.origin.x,
            y: UIApplication.shared.statusBarFrame.origin.y,
            width: UIApplication.shared.statusBarFrame.width,
            height: progressBar.frame.origin.y
        )

        if DeviceInfo.current.orientation.interface.isLandscape && !DeviceInfo.current.isPad {
            self.labelsStackView.axis = .horizontal
            self.labelsStackView.spacing = 8
        } else {
            self.labelsStackView.axis = .vertical
            self.labelsStackView.spacing = 0
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.shouldToggleNavigationBar = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.shouldToggleNavigationBar {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.didJustSubscribe {
            self.didJustSubscribe = false
            self.presenter?.appearedAfterSubscription()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateAppearance()
        }
    }

    private func setup() {
        self.title = ""

        self.shadowViewHeight.constant = 0.5

        self.statusBarPad = UIView()
        self.statusBarPad?.backgroundColor = .stepikBackground
        if let padView = self.statusBarPad {
            self.view.insertSubview(padView, at: 0)
        }

        self.sendElementsToBack()

        self.progressBar.progress = 0

        self.updateAppearance()

        if self.presenter == nil {
            self.presenter = BaseCardsStepsPresenter(
                stepsAPI: StepsAPI(),
                lessonsAPI: LessonsAPI(),
                recommendationsAPI: RecommendationsAPI(),
                unitsAPI: UnitsAPI(),
                viewsAPI: ViewsAPI(),
                ratingsAPI: AdaptiveRatingsAPI(),
                ratingManager: AdaptiveRatingManager(courseId: self.course.id),
                statsManager: AdaptiveStatsManager(courseId: self.course.id),
                storageManager: AdaptiveStorageManager(),
                lastViewedUpdater: LocalProgressLastViewedUpdater(),
                notificationSuggestionManager: NotificationSuggestionManager(),
                notificationsRegistrationService: NotificationsRegistrationService(
                    presenter: NotificationsRequestAlertPresenter(context: .courseSubscription),
                    analytics: .init(source: .courseSubscription)
                ),
                stepFontSizeStorageManager: StepFontSizeStorageManager(),
                course: self.course,
                view: self
            )
            self.presenter?.refresh()
        }
    }

    private func updateAppearance() {
        self.view.backgroundColor = .stepikBackground
        self.kolodaView.backgroundColor = .clear
        self.progressBar.progressTintColor = .stepikGreen
        self.shadowView.backgroundColor = .stepikSeparator
        self.trophyButton.tintColor = .stepikAccent
        self.backButton.tintColor = .stepikAccent
        self.expLabel.textColor = .stepikAccent
        self.levelLabel.textColor = .stepikAccent
    }

    @IBAction
    func onBackButtonClick(_ sender: Any) {
        self.shouldToggleNavigationBar = true
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction
    func onTrophyButtonClick(_ sender: Any) {
        guard let viewController = ControllerHelper.instantiateViewController(
            identifier: "Stats",
            storyboardName: "Adaptive"
        ) as? AdaptiveStatsPagerViewController else {
            return
        }

        guard let course = self.presenter?.course else {
            return
        }

        self.shouldToggleNavigationBar = true

        viewController.ratingsManager = AdaptiveRatingManager(courseId: course.id)
        viewController.statsManager = AdaptiveStatsManager(courseId: course.id)

        self.navigationController?.pushViewController(viewController, animated: true)
    }

    override func updateProgress(rating: Int, prevMaxRating: Int, maxRating: Int, level: Int) {
        super.updateProgress(rating: rating, prevMaxRating: prevMaxRating, maxRating: maxRating, level: level)

        let currentLevel = level

        self.expLabel.text = String(
            format: NSLocalizedString("RatingProgress", comment: ""), "\(rating)", "\(maxRating)"
        )
        self.levelLabel.text = String(
            format: NSLocalizedString("RatingProgressLevel", comment: ""), "\(currentLevel)"
        )

        let newProgress = Float(rating - prevMaxRating) / Float(maxRating - prevMaxRating)
        let progressAddition: Float = 0.005
        let shouldFulfill = self.progressBar.progress - progressAddition > newProgress

        guard !self.progressBar.progress.isEqual(to: newProgress + progressAddition) else {
            return
        }

        self.progressBar.progress = shouldFulfill ? 100.0 : newProgress + progressAddition

        UIView.animate(
            withDuration: 1.2,
            animations: {
                self.progressBar.layoutIfNeeded()
            },
            completion: { _ in
                if !shouldFulfill {
                    return
                }

                self.progressBar.progress = 0
                self.progressBar.layoutIfNeeded()

                self.progressBar.progress = newProgress + progressAddition
                UIView.animate(withDuration: 1.2, animations: { self.progressBar.layoutIfNeeded() })
            }
        )
    }

    override func showCongratulation(for rating: Int, isSpecial: Bool, completion: (() -> Void)? = nil) {
        let text = self.expLabel.text ?? ""
        let color = self.expLabel.textColor ?? .stepikAccent

        func transitionToText(_ text: String, color: UIColor, duration: Double, completionBlock: (() -> Void)? = nil) {
            UIView.transition(
                with: self.expLabel,
                duration: duration,
                options: .transitionCrossDissolve,
                animations: { self.expLabel.textColor = .clear },
                completion: { _ in
                    self.expLabel.text = text
                    UIView.transition(
                        with: self.expLabel,
                        duration: duration,
                        options: .transitionCrossDissolve,
                        animations: { self.expLabel.textColor = color },
                        completion: { _ in completionBlock?() }
                    )
                }
            )
        }

        transitionToText(
            String(format: NSLocalizedString("RatingCongratulationText", comment: ""), "\(rating)"),
            color: .stepikDarkGreen,
            duration: 0.4,
            completionBlock: { () -> Void in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    transitionToText(text, color: color, duration: 0.4, completionBlock: { completion?() })
                })
            }
        )
    }

    override func presentDiscussions(stepId: Int, discussionProxyId: String) {
        self.shouldToggleNavigationBar = true
        super.presentDiscussions(stepId: stepId, discussionProxyId: discussionProxyId)
    }

    private func changeZPositionForElements(change: CGFloat, relativeTo layer: CALayer) {
        self.trophyButton.layer.zPosition = layer.zPosition + change
        self.backButton.layer.zPosition = layer.zPosition + change
        self.statusBarPad?.layer.zPosition = layer.zPosition + change
        self.progressBar.layer.zPosition = layer.zPosition + change
        self.labelsStackView.layer.zPosition = layer.zPosition + change
        self.shadowView.layer.zPosition = layer.zPosition + change
    }

    private func bringElementsToFront() {
        self.backButton.superview?.bringSubviewToFront(self.backButton)
        self.trophyButton.superview?.bringSubviewToFront(self.trophyButton)

        self.changeZPositionForElements(change: 1.0, relativeTo: self.placeholderContainer.placeholderView.layer)
    }

    private func sendElementsToBack() {
        self.changeZPositionForElements(change: -1.0, relativeTo: self.kolodaView.layer)
    }
}
