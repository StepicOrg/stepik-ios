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
    
    var canSwipeCurrentCardUp = false
    
    fileprivate var topCard: StepCardView?
    
    var state: AdaptiveStepsViewState = .normal {
        didSet {
            self.placeholderView.isHidden = state == .normal || state == .congratulation
            self.kolodaView.isHidden = state != .normal && state != .congratulation
            self.congratsView.isHidden = state != .congratulation
        }
    }
    
    lazy var placeholderView: UIView = {
        let v = PlaceholderView()
        self.view.insertSubview(v, aboveSubview: self.view)
        v.align(to: self.kolodaView)
        v.delegate = self
        v.datasource = self
        v.backgroundColor = UIColor.white
        return v
    }()
    
    lazy var congratsPresentr: Presentr = {
        let presenter = Presentr(presentationType: .alert)
        presenter.backgroundOpacity = 0.0
        presenter.dismissOnTap = false
        presenter.dismissAnimated = true
        presenter.dismissTransitionType = TransitionType.custom(CrossDissolveAnimation(options: .normal(duration: 0.4)))
        presenter.roundCorners = true
        presenter.cornerRadius = 10
        // TODO: clipsToBounds == false for button?
        // presenter.dropShadow = PresentrShadow(shadowColor: .black, shadowOpacity: 0.4, shadowOffset: CGSize(width: 0.0, height: 2), shadowRadius: 1.8)
        return presenter
    }()
    
    lazy var congratsView: UIView = {
        let congratsView = CongratsView(frame: self.view.bounds)
        congratsView.isHidden = true
        self.view.addSubview(congratsView)
        return congratsView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        presenter = AdaptiveStepsPresenter(coursesAPI: ApiDataDownloader.courses, stepsAPI: ApiDataDownloader.steps, lessonsAPI: ApiDataDownloader.lessons, progressesAPI: ApiDataDownloader.progresses, stepicsAPI: ApiDataDownloader.stepics, recommendationsAPI: ApiDataDownloader.recommendations, view: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func updateProgress(for rating: Int, presentCongratulation: Bool = false) {
        let currentLevel = RatingHelper.getLevel(for: rating)
        let ratingForCurrentLevel = RatingHelper.getRating(for: currentLevel)
        let ratingForNextLevel = RatingHelper.getRating(for: currentLevel + 1)
        
        levelProgress.text = String(format: NSLocalizedString("RatingProgress", comment: ""), "\(rating)", "\(ratingForNextLevel)") + " • " + String(format: NSLocalizedString("RatingProgressLevel", comment: ""), "\(currentLevel)")
        
        if presentCongratulation && rating == ratingForCurrentLevel {
            // Level up
            let congratsText = String(format: NSLocalizedString("NewLevelCongratulationText", comment: ""), "\(currentLevel)")
            let controller = Presentr.alertViewController(title: NSLocalizedString("NewLevelCongratulationTitle", comment: ""), body: congratsText)
            let continueAction = AlertAction(title: NSLocalizedString("Continue", comment: ""), style: .default) { [weak self] in
                self?.state = .normal
            }
            controller.addAction(continueAction)
            state = .congratulation
            customPresentViewController(self.congratsPresentr, viewController: controller, animated: true, completion: nil)
        }
        
        let newProgress = Float(rating - ratingForCurrentLevel) / Float(ratingForNextLevel - ratingForCurrentLevel)
        levelProgress.hideCongratulation(force: true) {
            self.levelProgress.setProgress(value: newProgress, animated: true)
        }
    }
    
    func showCongratulation(for rating: Int, isSpecial: Bool) {
        levelProgress.showCongratulation(text: String(format: NSLocalizedString("RatingCongratulationText", comment: ""), "\(rating)"), duration: 1.0)
    }
    
    func presentShareDialog(for link: String) {
        let activityViewController = SharingHelper.getSharingController(link)
        activityViewController.popoverPresentationController?.sourceView = topCard?.shareButton ?? view
        present(activityViewController, animated: true, completion: nil)
    }
}

extension AdaptiveStepsViewController: KolodaViewDelegate {
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        kolodaView.resetCurrentCardIndex()
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool {
        if direction == .right {
            presenter?.lastReaction = .neverAgain
        } else if direction == .left {
            presenter?.lastReaction = .maybeLater
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
            return Images.noWifiImage.size100x100
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
        case .coursePassed:
            return NSLocalizedString("GoToStepikAppStore", comment: "")
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
        return stepicPlaceholderStyle
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
        case .coursePassed:
            presenter?.goToAppStore()
        default:
            return
        }
    }
}
