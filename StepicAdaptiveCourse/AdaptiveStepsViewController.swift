//
//  AdaptiveStepsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Koloda
import SVProgressHUD

class AdaptiveStepsViewController: UIViewController, AdaptiveStepsView {
    var presenter: AdaptiveStepsPresenter?
    
    @IBOutlet weak var userMenuButton: UIBarButtonItem!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var canSwipeCurrentCardUp = false
    
    fileprivate var topCard: StepCardView?
    
    var state: AdaptiveStepsViewState = .normal {
        didSet {
            self.placeholderView.isHidden = state == .normal
            self.kolodaView.isHidden = state != .normal
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

    lazy var alertController: UIAlertController = { [weak self] in
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        alertController.addAction(cancelAction)
        
        let aboutCourseAction = UIAlertAction(title: NSLocalizedString("AboutCourse", comment: ""), style: .default) { action in
            if let aboutCourse = self?.presenter?.aboutCourseController {
                self?.present(aboutCourse, animated: true)
            }
        }
        alertController.addAction(aboutCourseAction)
        
        let destroyAction = UIAlertAction(title: NSLocalizedString("SignOut", comment: ""), style: .destructive) { action in
            self?.presenter?.logout()
        }
        alertController.addAction(destroyAction)
        
        return alertController
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        presenter = AdaptiveStepsPresenter(view: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage(named: "shadow-pixel")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.refreshContent()
    }

    @IBAction func onUserMenuButtonClick(_ sender: Any) {
        alertController.popoverPresentationController?.barButtonItem = userMenuButton
        self.present(alertController, animated: true, completion: nil)
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
        topCard?.controlButtonState = stepState
    }
    
    func updateTopCard(cardState: StepCardView.CardState) {
        topCard?.cardState = cardState
    }
    
    func showHud(withStatus: String) {
        SVProgressHUD.show(withStatus: withStatus)
    }
    
    func hideHud() {
        SVProgressHUD.dismiss()
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
        return true
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

