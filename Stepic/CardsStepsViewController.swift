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
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var expLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var labelsStackView: UIStackView!

    var canSwipeCurrentCardUp = false
    private var shouldToggleNavigationBar = true

    var course: Course!

    fileprivate var topCard: StepCardView?
    fileprivate var currentStepViewController: CardStepViewController?
    fileprivate var statusBarPad: UIView?

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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = ""

        statusBarPad = UIView()
        statusBarPad?.backgroundColor = UIColor.mainLight
        if let padView = statusBarPad {
            view.addSubview(padView)
        }
        navigationBar.layer.zPosition = kolodaView.layer.zPosition - 1
        statusBarPad?.layer.zPosition = kolodaView.layer.zPosition - 1
        progressBar.layer.zPosition = kolodaView.layer.zPosition - 1
        progressBar.progress = 0

        if presenter == nil {
            presenter = CardsStepsPresenter(stepsAPI: StepsAPI(), lessonsAPI: LessonsAPI(), recommendationsAPI: RecommendationsAPI(), unitsAPI: UnitsAPI(), viewsAPI: ViewsAPI(), ratingManager: AdaptiveRatingManager(courseId: course.id), statsManager: AdaptiveStatsManager(courseId: course.id), course: course, view: self)
            presenter?.refresh()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        statusBarPad?.frame = UIApplication.shared.statusBarFrame

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
        shouldToggleNavigationBar = true
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if shouldToggleNavigationBar {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }

    @IBAction func onBackButtonClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func onTrophyButtonClick(_ sender: Any) {
        guard let vc = ControllerHelper.instantiateViewController(identifier: "Stats", storyboardName: "Adaptive") as? AdaptiveStatsPagerViewController else {
            return
        }

        shouldToggleNavigationBar = false

        vc.ratingsManager = AdaptiveRatingManager(courseId: course.id)
        vc.statsManager = AdaptiveStatsManager(courseId: course.id)

        let navigationVC = StyledNavigationViewController(rootViewController: vc)
        present(navigationVC, animated: true, completion: nil)
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
        guard let card = topCard else {
            return
        }

        currentStepViewController?.removeFromParentViewController()
        currentStepViewController = stepViewController

        self.addChildViewController(stepViewController)

        card.addContentSubview(stepViewController.view)
    }

    func updateTopCardTitle(title: String) {
        guard let card = topCard else {
            return
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
        let currentLevel = level

        expLabel.text = String(format: NSLocalizedString("RatingProgress", comment: ""), "\(rating)", "\(maxRating)")
        levelLabel.text = String(format: NSLocalizedString("RatingProgressLevel", comment: ""), "\(currentLevel)")

        let newProgress = Float(rating - prevMaxRating) / Float(maxRating - prevMaxRating)
        let shouldFulfill = progressBar.progress > newProgress

        progressBar.progress = shouldFulfill ? 100.0 : newProgress + 0.005
        UIView.animate(withDuration: 1.2, animations: {
            self.progressBar.layoutIfNeeded()
        }, completion: { _ in
            if !shouldFulfill {
                return
            }

            self.progressBar.progress = 0
            self.progressBar.layoutIfNeeded()

            self.progressBar.progress = newProgress + 0.005
            UIView.animate(withDuration: 1.2, animations: {
                self.progressBar.layoutIfNeeded()
            }, completion: nil)
        })
    }

    func showCongratulation(for rating: Int, isSpecial: Bool, completion: (() -> Void)? = nil) {
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

        transitionToText(String(format: NSLocalizedString("RatingCongratulationText", comment: ""), "\(rating)"), color: UIColor(hex: 0x008040), duration: 0.4, completionBlock: { _ in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                transitionToText(text, color: color, duration: 0.4, completionBlock: { completion?() })
            })
        })
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
            topCard = StepCardView()
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

extension CardsStepsViewController: CardStepDelegate {
    func stepSubmissionDidCorrect() {
        //AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.Step.correctAnswer)
        presenter?.sendReaction(.solved)
        presenter?.updateRatingWhenSuccess()
        topCard?.controlState = .successful
    }

    func stepSubmissionDidWrong() {
        //AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.Step.wrongAnswer)
        presenter?.updateRatingWhenFail()
        topCard?.controlState = .wrong
    }

    func stepSubmissionDidRetry() {
        //AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.Step.retry)
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
