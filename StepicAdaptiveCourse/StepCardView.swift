//
//  StepCardView.swift
//  CardsDemo
//
//  Created by Vladislav Kiryukhin on 04.04.17.
//  Copyright © 2017 Vladislav Kiryukhin. All rights reserved.
//

import UIKit

class StepCardView: UIView {

    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    var gradientLayer: CAGradientLayer?

    var step: Step!
    var course: Course!
    var lesson: Lesson!
    
    fileprivate var stepViewController: AdaptiveStepViewController?
    
    var controlButtonState: ControlButtonState = .submit {
        didSet {
            switch controlButtonState {
            case .submit:
                controlButton.setTitle(NSLocalizedString("Submit", comment: ""), for: .normal)
                break
            case .tryAgain:
                controlButton.setTitle(NSLocalizedString("TryAgain", comment: ""), for: .normal)
                break
            case .next:
                controlButton.setTitle(NSLocalizedString("NextTask", comment: ""), for: .normal)
                break
            }
        }
    }
 
    lazy var parentViewController: UIViewController? = {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }()
    
    @IBAction func onControlButtonClick(_ sender: Any) {
        switch controlButtonState {
        case .submit:
            stepViewController?.quizViewController?.submitAttempt()
            break
        case .tryAgain:
            stepViewController?.quizViewController?.retrySubmission()
            break
        case .next:
            (parentViewController as? AdaptiveStepsViewController)?.swipeSolvedCard()
            break
        }
    }

    override func draw(_ rect: CGRect) {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.stepicGreenColor().cgColor
    }
    
    func hideContent() {
        contentView.isHidden = true
        titleLabel.isHidden = true
    }
    
    func showContent() {
        UIView.transition(with: contentView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.contentView.isHidden = false
            self.titleLabel.isHidden = false
            
            // Set up title
            self.titleLabel.text = self.lesson.title
            
            // Set up step vc
            self.stepViewController = ControllerHelper.instantiateViewController(identifier: "AdaptiveStepViewController", storyboardName: "AdaptiveMain") as? AdaptiveStepViewController
            guard let parentVC = self.parentViewController,
                let stepVC = self.stepViewController else {
                print("stepVC init failed")
                return
            }
            
            stepVC.recommendedLesson = self.lesson
            stepVC.step = self.step
            stepVC.course = self.course
            stepVC.delegate = self
            stepVC.isSendButtonHidden = true
            
            parentVC.addChildViewController(stepVC)
            self.contentView.addSubview(stepVC.view)
            stepVC.view.align(to: self.contentView)
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
            
            // Add gradient
            self.gradientLayer = CAGradientLayer()
            if let gradient = self.gradientLayer {
                gradient.frame = self.contentView.bounds
                gradient.colors = [UIColor.white.withAlphaComponent(0.0).cgColor,
                                             UIColor.white.withAlphaComponent(0.15).cgColor,
                                             UIColor.white.withAlphaComponent(1.0).cgColor]
                gradient.locations = [0.0, 0.95, 1.0]
                self.contentView.layer.addSublayer(gradient)
            }
        }, completion: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer?.frame = contentView.bounds
    }
    
    enum ControlButtonState {
        case submit
        case tryAgain
        case next
    }
}

extension StepCardView: AdaptiveStepViewControllerDelegate {
    func stepSubmissionDidCorrect() {
        controlButtonState = .next
    }
    
    func stepSubmissionDidWrong() {
        controlButtonState = .tryAgain
    }
    
    func stepSubmissionDidRetry() {
        controlButtonState = .submit
    }
    
    func contentLoadingDidFail() {
        (parentViewController as? AdaptiveStepsViewController)?.isWarningHidden = false
    }
}
