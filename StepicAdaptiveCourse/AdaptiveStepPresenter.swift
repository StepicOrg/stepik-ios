//
//  AdaptiveStepPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 07.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

enum AdaptiveStepState {
    case unsolved
    case wrong
    case successful
}

protocol AdaptiveStepView: class {
    var baseScrollView: UIScrollView { get }
    
    func updateProblem(with htmlText: String)
    func updateQuiz(with view: UIView)
    
    func scrollToQuizBottom(quizHintHeight: CGFloat, quizHintTop: CGPoint)
    func updateQuizHeight(newHeight: CGFloat, completion: (() -> ())?)
}

class AdaptiveStepPresenter {
    weak var view: AdaptiveStepView?
    weak var delegate: AdaptiveStepDelegate?
    
    var step: Step!
    
    var quizViewController: ChoiceQuizViewController?
    
    init(view: AdaptiveStepView, step: Step) {
        self.step = step
        self.view = view
    }
    
    func refreshStep() {
        // Set up problem
        view?.updateProblem(with: step.block.text ?? "")
        
        // Set up quiz view controller
        quizViewController = ChoiceQuizViewController(nibName: "QuizViewController", bundle: nil)
        guard let quizViewController = quizViewController else {
            print("quizVC init failed")
            delegate?.contentLoadingDidFail()
            return
        }
        quizViewController.step = step
        quizViewController.delegate = self
        view?.updateQuiz(with: quizViewController.view)
        
        quizViewController.isSubmitButtonHidden = true
    }
    
    func problemDidLoad() {
        delegate?.contentLoadingDidComplete()
    }
    
    // :(
    func needsQuizHeightUpdate() {
        // Maybe quiz vc should update its height itself ???
        needsHeightUpdate((quizViewController?.expectedQuizHeight ?? 0) + (quizViewController?.heightWithoutQuiz ?? 0), animated: true, breaksSynchronizationControl: false)
    }
    
    func submit() {
        // TODO: this check only for choices
        var isSelected = false
        quizViewController?.choices.forEach { isSelected = isSelected || $0 }
        
        if quizViewController?.attempt != nil && isSelected {
            quizViewController?.submitAttempt()
        }
    }
    
    func retry() {
        if quizViewController?.attempt != nil {
            quizViewController?.retrySubmission()
        }
    }
}

extension AdaptiveStepPresenter: QuizControllerDelegate {
    func needsHeightUpdate(_ newHeight: CGFloat, animated: Bool, breaksSynchronizationControl: Bool) {
        view?.updateQuizHeight(newHeight: newHeight) { [weak self] in
            if self?.quizViewController?.submission?.status != nil {
                // :(
                let sPoint = self?.quizViewController?.statusLabel.superview?.convert(self?.quizViewController?.statusLabel.frame.origin ?? CGPoint.zero, to: self?.view?.baseScrollView)
                self?.view?.scrollToQuizBottom(quizHintHeight: self?.quizViewController?.hintView.frame.height ?? 0, quizHintTop: sPoint ?? CGPoint.zero)
            }
        }
    }
    
    func submissionDidCorrect() {
        delegate?.stepSubmissionDidCorrect()
        quizViewController?.isSubmitButtonHidden = true
    }
    
    func submissionDidWrong() {
        delegate?.stepSubmissionDidWrong()
        quizViewController?.isSubmitButtonHidden = true
    }
    
    func submissionDidRetry() {
        delegate?.stepSubmissionDidRetry()
    }
    
    func didWarningPlaceholderShow() {
        delegate?.contentLoadingDidFail()
    }
}
