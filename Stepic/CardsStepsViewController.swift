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

class CardsStepsViewController: UIViewController {
    var presenter: CardsStepsPresenter?

    @IBOutlet weak var kolodaView: KolodaView!

    var canSwipeCurrentCardUp = false

    fileprivate var topCard: StepCardView?
    fileprivate var currentStepViewController: CardStepViewController?

    var state: CardsStepsViewState = .normal {
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

        presenter = CardsStepsPresenter(stepsAPI: StepsAPI(), lessonsAPI: LessonsAPI(), recommendationsAPI: RecommendationsAPI(), unitsAPI: UnitsAPI(), viewsAPI: ViewsAPI(), course: Course(), view: self)
    }
}

extension CardsStepsViewController: CardsStepsView {
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
        guard let currentStepUIViewController = currentStepViewController as? UIViewController,
              let selfUIViewController = self as? UIViewController,
              let card = topCard else {
            return
        }

        currentStepUIViewController.removeFromParentViewController()
        selfUIViewController?.addChildViewController(currentStepUIViewController)

        card.addContentSubview(currentStepUIViewController.view)
    }

    func updateTopCardTitle(title: String) {
        guard let card = topCard else {
            return
        }

        card.updateLabel(title)
    }

    func presentShareDialog(for link: String) {
        let activityViewController = SharingHelper.getSharingController(link)
        activityViewController.popoverPresentationController?.sourceView = card?.shareButton ?? view
        present(activityViewController, animated: true, completion: nil)
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
            return card!
        } else {
            topCard = StepCardView()
            topCard.delegate = presenter
            presenter?.refreshTopCard()
            return topCard
        }
    }

    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return CardOverlayView()
    }
}

extension CardsStepsViewController: PlaceholderViewDataSource {
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

extension CardsStepsViewController: PlaceholderViewDelegate {
    func placeholderButtonDidPress() {
        switch state {
        case .connectionError:
            presenter?.tryAgain()
        default:
            return
        }
    }
}
