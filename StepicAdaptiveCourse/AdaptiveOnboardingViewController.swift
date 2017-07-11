//
//  AdaptiveOnboardingViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 07.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Koloda

class AdaptiveOnboardingViewController: UIViewController, AdaptiveOnboardingView {
    var presenter: AdaptiveOnboardingPresenter?
    
    @IBOutlet weak var kolodaView: KolodaView!
    
    fileprivate var requiredActions: [AdaptiveOnboardingAction] = []
    fileprivate var canSwipeCurrentCardUp = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        presenter = AdaptiveOnboardingPresenter(view: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
    }
    
    func finishOnboarding() {
        dismiss(animated: false, completion: {})
    }
}

extension AdaptiveOnboardingViewController: KolodaViewDelegate {
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        kolodaView.resetCurrentCardIndex()
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool {
        return canSwipeCurrentCardUp || (direction == .left && requiredActions.contains(.swipeLeft)) || (direction == .right && requiredActions.contains(.swipeRight))
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return (canSwipeCurrentCardUp ? [.up] : []) + [.left, .right]
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
}

extension AdaptiveOnboardingViewController: KolodaViewDataSource {
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return 2
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        if index > 0 {
            let card = Bundle.main.loadNibNamed("StepReversedCardView", owner: self, options: nil)?.first as? StepReversedCardView
            return card!
        } else {
            let card = Bundle.main.loadNibNamed("StepCardView", owner: self, options: nil)?.first as? StepCardView
            if let cardData = presenter?.getNextCardData() {
                card?.cardState = .normal
                card?.delegate = self
                card?.updateLabel(cardData.title)
                
                requiredActions = cardData.requiredActions
                
                let webview = UIWebView()
                webview.backgroundColor = UIColor.clear
                card?.addContentSubview(webview)
                
                // Add small top padding
                var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: "<style>\nbody{padding-top: 8px;}</style>\n", body: cardData.content.text ?? "", width: Int(UIScreen.main.bounds.width))
                html = html.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                webview.loadHTMLString(html, baseURL: cardData.content.baseURL ?? nil)
                
                card?.controlButton.setTitle(cardData.buttonTitle, for: .normal)
                card?.controlButton.isHidden = cardData.isButtonHidden
            } else {
                presenter?.finishOnboarding()
            }
            return card!
        }
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("CardOverlayView", owner: self, options: nil)?.first as? CardOverlayView
    }
}

extension AdaptiveOnboardingViewController: StepCardViewDelegate {
    func onControlButtonClick() {
        canSwipeCurrentCardUp = true
        kolodaView.swipe(.up)
        canSwipeCurrentCardUp = false
    }
}
