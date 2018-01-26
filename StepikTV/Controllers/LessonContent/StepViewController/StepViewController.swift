//
//  StepViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 24.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class StepViewController: BlurredViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var quizPlaceholderView: UIView!
    @IBOutlet weak var stepText: UILabel!
    @IBOutlet weak var contentViewInsideVerticalSpacingConstraint: NSLayoutConstraint!

    @IBOutlet weak var scrollViewTopInset: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomInset: NSLayoutConstraint!

    @IBOutlet weak var scrollView: UIScrollView!

    var stepViewData: StepViewData!

    override func viewDidLoad() {
        super.viewDidLoad()

        stepText.textColor = UIColor.white
        stepText.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightMedium)
        stepText.setTextWithHTMLString(stepViewData.block.text ?? "")

        scrollView.panGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouchType.indirect.rawValue)]

        scrollView.alwaysBounceVertical = false

        handleQuizType()
        contentView.layoutIfNeeded()
    }

    override func viewWillLayoutSubviews() {

        if contentView.bounds.height <= scrollView.bounds.height {
            let insetValue = (scrollView.bounds.height - contentView.bounds.height) / 2
            scrollViewTopInset.constant = insetValue
            scrollViewBottomInset.constant = insetValue

            //contentView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor).isActive = true
        }
    }

    private func initQuizController(_ quizController: TVQuizViewController) {
        quizController.step = self.stepViewData.step
        self.addChildViewController(quizController)
        quizPlaceholderView.addSubview(quizController.view)
        quizController.view.translatesAutoresizingMaskIntoConstraints = false
        quizController.view.align(to: quizPlaceholderView)
    }

    private func handleQuizType() {
        guard let quizVC = stepViewData.quizViewController else {
            contentViewInsideVerticalSpacingConstraint.isActive = false
            stepText.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            return
        }

        //stepText.heightForLabelWithText
        initQuizController(quizVC)
    }

    /*
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {

        print(context.nextFocusedView)
        for subview in quizPlaceholderView.allSubviews {
            if context.nextFocusedView == subview {
                scrollView.isScrollEnabled = false
                print(false)
                return
            }
        }

        scrollView.isScrollEnabled = true
        print(true)
    }
 */
}
