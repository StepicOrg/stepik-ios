//
//  CardsStepsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 21.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import Koloda

class CardsStepsViewController: UIViewController, CardsStepsView, ControllerWithStepikPlaceholder {

    var placeholderContainer: StepikPlaceholderControllerContainer = StepikPlaceholderControllerContainer()
    var presenter: CardsStepsPresenter?

    @IBOutlet weak var kolodaView: KolodaView!

    var canSwipeCurrentCardUp = false

    fileprivate var topCard: StepCardView?
    fileprivate var currentStepViewController: CardStepViewController?

    var state: CardsStepsViewState = .normal {
        didSet {
            switch state {
            case .normal:
                isPlaceholderShown = false
            case .connectionError:
                showPlaceholder(for: .connectionError)
            case .coursePassed:
                showPlaceholder(for: .adaptiveCoursePassed)
            default:
                break
            }
        }
    }

    // Can be overriden in the children classes (for adaptive app)
    var cardView: StepCardView {
        return StepCardView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        registerPlaceholder(placeholder: StepikPlaceholder(.noConnectionQuiz, action: { [weak self] in
            self?.presenter?.tryAgain()
        }), for: .connectionError)

        registerPlaceholder(placeholder: StepikPlaceholder(.adaptiveCoursePassed), for: .adaptiveCoursePassed)
    }

    func refreshCards() {
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

    func updateTopCardContent(stepViewController: CardStepViewController) {
        guard let card = topCard else {
            return
        }

        currentStepViewController?.removeFromParent()
        currentStepViewController = stepViewController

        self.addChild(stepViewController)

        card.addContentSubview(stepViewController.view)
    }

    func updateTopCardTitle(title: String, showControls: Bool) {
        guard let card = topCard else {
            return
        }

        if !showControls {
            card.titleButton.isHidden = true
        }

        card.updateLabel(title)
    }

    func presentDiscussions(stepId: Int, discussionProxyId: String) {
        let vc = DiscussionsViewController(nibName: "DiscussionsViewController", bundle: nil)
        vc.discussionProxyId = discussionProxyId
        vc.target = stepId
        navigationController?.pushViewController(vc, animated: true)
    }

    func updateProgress(rating: Int, prevMaxRating: Int, maxRating: Int, level: Int) {

    }

    func showCongratulation(for rating: Int, isSpecial: Bool, completion: (() -> Void)? = nil) {

    }

    func presentShareDialog(for link: String) {
        let activityViewController = SharingHelper.getSharingController(link)
        activityViewController.popoverPresentationController?.sourceView = topCard?.titleButton ?? view
        present(activityViewController, animated: true, completion: nil)
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
}

extension CardsStepsViewController: KolodaViewDelegate {
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if direction == .right {
            presenter?.sendReaction(.neverAgain)
        } else if direction == .left {
            presenter?.sendReaction(.maybeLater)
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

extension CardsStepsViewController: KolodaViewDataSource {
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .`default`
    }

    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return 2
    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        if index > 0 {
            let card = StepReversedCardView()
            return card
        } else {
            topCard = cardView
            topCard?.delegate = presenter
            topCard?.cardState = .loading
            presenter?.refreshTopCard()
            return topCard ?? UIView()
        }
    }

    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return CardOverlayView()
    }
}

extension CardsStepsViewController: CardStepDelegate {
    func stepSubmissionDidCorrect() {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.Step.correctAnswer)
        AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.Step.submission)
        presenter?.sendReaction(.solved)
        presenter?.updateRatingWhenSuccess()
        topCard?.controlState = .successful
    }

    func stepSubmissionDidWrong() {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.Step.wrongAnswer)
        AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.Step.submission)
        presenter?.updateRatingWhenFail()
        topCard?.controlState = .wrong
    }

    func stepSubmissionDidRetry() {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.Step.retry)
        topCard?.controlState = .unsolved
    }

    func contentLoadingDidFail() {
        state = .connectionError
    }

    func contentLoadingDidComplete() {
        presenter?.state = .loaded
        topCard?.cardState = .normal
    }
}
