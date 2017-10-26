//
//  AdaptiveStepsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Koloda
import Presentr

class AdaptiveStepsViewController: UIViewController, AdaptiveStepsView {
    var presenter: AdaptiveStepsPresenter?

    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var levelProgress: RatingProgressView!
    @IBOutlet weak var tapProxyView: TapProxyView!
    @IBOutlet weak var trophyButton: UIButton!

    var canSwipeCurrentCardUp = false

    fileprivate var topCard: StepCardView?

    var state: AdaptiveStepsViewState = .normal {
        didSet {
            switch state {
            case .normal:
                self.placeholderView.isHidden = true
                self.kolodaView.isHidden = false
            case .connectionError, .coursePassed:
                self.placeholderView.isHidden = false
                self.kolodaView.isHidden = true
            default:
                break
            }
        }
    }

    lazy var placeholderView: UIView = {
        let v = PlaceholderView()
        self.view.insertSubview(v, aboveSubview: self.view)
        v.align(toView: self.kolodaView)
        v.delegate = self
        v.datasource = self
        v.backgroundColor = self.view.backgroundColor
        return v
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        presenter = AdaptiveStepsPresenter(coursesAPI: ApiDataDownloader.courses, stepsAPI: ApiDataDownloader.steps, lessonsAPI: ApiDataDownloader.lessons, progressesAPI: ApiDataDownloader.progresses, stepicsAPI: ApiDataDownloader.stepics, recommendationsAPI: ApiDataDownloader.recommendations, unitsAPI: ApiDataDownloader.units, viewsAPI: ApiDataDownloader.views, profilesAPI: ApiDataDownloader.profiles, ratingManager: RatingManager.shared, statsManager: StatsManager.shared, achievementsManager: AchievementManager.shared, defaultsStorageManager: DefaultsStorageManager.shared, ratingsAPI: ApiDataDownloader.adaptiveRatings, view: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tapProxyView.targetView = trophyButton

        trophyButton.tintColor = StepicApplicationsInfo.adaptiveMainColor
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter?.refreshContent()
    }

    func initCards() {
        if kolodaView.delegate == nil {
            kolodaView.dataSource = self
            kolodaView.delegate = self
        } else {
            kolodaView.reloadData()
        }
    }

    func swipeCardUp() {
        canSwipeCurrentCardUp = true
        kolodaView.swipe(.up)
        canSwipeCurrentCardUp = false
    }

    func swipeCardLeft() {
        kolodaView.swipe(.left)
    }

    func swipeCardRight() {
        kolodaView.swipe(.right)
    }

    func updateTopCardControl(stepState: AdaptiveStepState) {
        switch stepState {
        case .unsolved:
            topCard?.controlButton.setTitle(NSLocalizedString("Submit", comment: ""), for: .normal)
            break
        case .wrong:
            topCard?.controlButton.setTitle(NSLocalizedString("TryAgain", comment: ""), for: .normal)
            break
        case .successful:
            topCard?.controlButton.setTitle(NSLocalizedString("NextTask", comment: ""), for: .normal)
            break
        }
    }

    func updateTopCard(cardState: StepCardView.CardState) {
        topCard?.cardState = cardState
    }

    func updateProgress(for rating: Int) {
        let currentLevel = RatingHelper.getLevel(for: rating)
        let ratingForCurrentLevel = RatingHelper.getRating(for: currentLevel - 1)
        let ratingForNextLevel = RatingHelper.getRating(for: currentLevel)

        levelProgress.text = String(format: NSLocalizedString("RatingProgress", comment: ""), "\(rating)", "\(ratingForNextLevel)") + " • " + String(format: NSLocalizedString("RatingProgressLevel", comment: ""), "\(currentLevel)")
        let newProgress = Float(rating - ratingForCurrentLevel) / Float(ratingForNextLevel - ratingForCurrentLevel)
        levelProgress.hideCongratulation(force: true) {
            self.levelProgress.setProgress(value: newProgress, animated: true)
        }
    }

    func showCongratulationPopup(type: CongratulationType, completion: (() -> Void)? = nil) {
        if state == .congratulation {
            completion?()
            return
        }

        let controller = Alerts.congratulation.construct(congratulationType: type, continueHandler: { [weak self] in
            self?.state = .normal
            completion?()
        })
        state = .congratulation
        Alerts.congratulation.present(alert: controller, inController: ControllerHelper.getTopViewController() ?? self)
    }

    func showCongratulation(for rating: Int, isSpecial: Bool, completion: (() -> Void)? = nil) {
        levelProgress.showCongratulation(text: String(format: NSLocalizedString("RatingCongratulationText", comment: ""), "\(rating)"), duration: 1.0, isSpecial: isSpecial) {
            completion?()
        }
    }

    func presentShareDialog(for link: String) {
        let activityViewController = SharingHelper.getSharingController(link)
        activityViewController.popoverPresentationController?.sourceView = topCard?.shareButton ?? view
        present(activityViewController, animated: true, completion: nil)
    }
}

extension AdaptiveStepsViewController: KolodaViewDelegate {
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if direction == .right {
            presenter?.lastReaction = .neverAgain
        } else if direction == .left {
            presenter?.lastReaction = .maybeLater
        }
        kolodaView.resetCurrentCardIndex()
    }

    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return false
    }

    func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool {
        if !(presenter?.canSwipeCard ?? false) {
            return false
        }

        return true
    }

    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return canSwipeCurrentCardUp ? [.up, .left, .right] : [.left, .right]
    }

    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return false
    }
}

extension AdaptiveStepsViewController: KolodaViewDataSource {
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .`default`
    }

    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return 2
    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        if index > 0 {
            let card = Bundle.main.loadNibNamed("StepReversedCardView", owner: self, options: nil)?.first as? StepReversedCardView
            return card!
        } else {
            let card = Bundle.main.loadNibNamed("StepCardView", owner: self, options: nil)?.first as? StepCardView
            topCard = presenter?.updateCard(card!)
            return topCard ?? UIView()
        }
    }

    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("CardOverlayView", owner: self, options: nil)?.first as? CardOverlayView
    }
}

extension AdaptiveStepsViewController: PlaceholderViewDataSource {
    func placeholderImage() -> UIImage? {
        switch state {
        case .connectionError:
            return Images.placeholders.connectionError
        case .coursePassed:
            return Images.placeholders.coursePassed
        default:
            return nil
        }
    }

    func placeholderButtonTitle() -> String? {
        switch state {
        case .connectionError:
            return NSLocalizedString("TryAgain", comment: "")
        default:
            return nil
        }
    }

    func placeholderDescription() -> String? {
        switch state {
        case .connectionError:
            return nil
        case .coursePassed:
            return NSLocalizedString("NoRecommendations", comment: "")
        default:
            return nil
        }
    }

    func placeholderStyle() -> PlaceholderStyle {
        var style = PlaceholderStyle()
        style.button.textColor = StepicApplicationsInfo.adaptiveMainColor
        return style
    }

    func placeholderTitle() -> String? {
        switch state {
        case .connectionError:
            return NSLocalizedString("ConnectionErrorText", comment: "")
        case .coursePassed:
            return NSLocalizedString("CoursePassed", comment: "")
        default:
            return nil
        }
    }
}

extension AdaptiveStepsViewController: PlaceholderViewDelegate {
    func placeholderButtonDidPress() {
        switch state {
        case .connectionError:
            presenter?.tryAgain()
        default:
            return
        }
    }
}
