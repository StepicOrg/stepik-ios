//
//  CardsStepsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 21.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Koloda
import PromiseKit

class CardsStepsViewController: UIViewController, CardsStepsView, ControllerWithStepikPlaceholder {
    var placeholderContainer = StepikPlaceholderControllerContainer()
    var presenter: CardsStepsPresenter?

    @IBOutlet weak var kolodaView: KolodaView!

    var canSwipeCurrentCardUp = false

    private var topCard: StepCardView?
    private var currentStepViewController: CardStepViewController?

    var state: CardsStepsViewState = .normal {
        didSet {
            switch self.state {
            case .normal:
                self.isPlaceholderShown = false
            case .connectionError:
                self.showPlaceholder(for: .connectionError)
            case .coursePassed:
                self.showPlaceholder(for: .adaptiveCoursePassed)
            default:
                break
            }
        }
    }

    // Can be overriden in the children classes (for adaptive app)
    var cardView: StepCardView { StepCardView() }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnectionQuiz,
                action: { [weak self] in
                    self?.presenter?.tryAgain()
                }
            ),
            for: .connectionError
        )
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(.adaptiveCoursePassed),
            for: .adaptiveCoursePassed
        )
    }

    func refreshCards() {
        if self.kolodaView.delegate == nil {
            self.kolodaView.dataSource = self
            self.kolodaView.delegate = self
        } else {
            self.kolodaView.reloadData()
        }
    }

    func swipeCardUp() {
        self.canSwipeCurrentCardUp = true
        self.kolodaView.swipe(.up)
        self.canSwipeCurrentCardUp = false
    }

    func swipeCardLeft() {
        self.kolodaView.swipe(.left)
    }

    func swipeCardRight() {
        self.kolodaView.swipe(.right)
    }

    func updateTopCardContent(stepViewController: CardStepViewController) {
        guard let card = self.topCard else {
            return
        }

        self.currentStepViewController?.removeFromParent()
        self.currentStepViewController = stepViewController

        self.addChild(stepViewController)

        card.addContentSubview(stepViewController.view)
    }

    func updateTopCardTitle(title: String, showControls: Bool) {
        guard let card = self.topCard else {
            return
        }

        if !showControls {
            card.titleButton.isHidden = true
        }

        card.updateLabel(title)
    }

    func presentDiscussions(stepId: Int, discussionProxyId: String) {
        let assembly = DiscussionsAssembly(
            discussionThreadType: .default,
            discussionProxyID: discussionProxyId,
            stepID: stepId
        )
        self.push(module: assembly.makeModule())
    }

    func updateProgress(rating: Int, prevMaxRating: Int, maxRating: Int, level: Int) {}

    func showCongratulation(for rating: Int, isSpecial: Bool, completion: (() -> Void)? = nil) {}

    func presentShareDialog(for link: String) {
        let activityViewController = SharingHelper.getSharingController(link)
        activityViewController.popoverPresentationController?.sourceView = topCard?.titleButton ?? view
        self.present(activityViewController, animated: true)
    }

    func showCongratulationPopup(type: CongratulationType, completion: (() -> Void)? = nil) {
        if self.state == .congratulation {
            completion?()
            return
        }

        let controller = Alerts.congratulation.construct(
            congratulationType: type,
            continueHandler: { [weak self] in
                self?.state = .normal
                completion?()
            }
        )

        self.state = .congratulation

        Alerts.congratulation.present(alert: controller, inController: ControllerHelper.getTopViewController() ?? self)
    }
}

// MARK: - CardsStepsViewController: KolodaViewDelegate -

extension CardsStepsViewController: KolodaViewDelegate {
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if direction == .right {
            self.presenter?.sendReaction(.neverAgain)
        } else if direction == .left {
            self.presenter?.sendReaction(.maybeLater)
        }

        self.kolodaView.resetCurrentCardIndex()
    }

    func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool {
        if !(self.presenter?.canSwipeCard ?? false) {
            return false
        }

        return true
    }

    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        self.canSwipeCurrentCardUp
            ? [.up, .left, .right]
            : [.left, .right]
    }

    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool { false }

    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool { false }
}

// MARK: - CardsStepsViewController: KolodaViewDataSource -

extension CardsStepsViewController: KolodaViewDataSource {
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed { .`default` }

    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int { 2 }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        if index > 0 {
            return StepReversedCardView()
        } else {
            self.topCard = self.cardView
            self.topCard?.delegate = self.presenter
            self.topCard?.cardState = .loading
            self.presenter?.refreshTopCard()

            return self.topCard ?? UIView()
        }
    }

    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? { CardOverlayView() }
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
