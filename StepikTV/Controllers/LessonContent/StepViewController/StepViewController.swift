//
//  StepViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 24.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

extension NSNotification.Name {
    static let stepUpdate = NSNotification.Name("stepUpdate")
}

class StepViewController: BlurredViewController {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewInsideVerticalSpacingConstraint: NSLayoutConstraint!

    @IBOutlet weak var quizPlaceholderView: UIView!
    @IBOutlet weak var stepText: TVFocusableText!
    @IBOutlet weak var stepTextMaxHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var scrollViewTopInset: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottomInset: NSLayoutConstraint!

    @IBOutlet weak var scrollView: UIScrollView!

    var stepViewData: StepViewData!

    private var hasQuiz: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        stepText.textColor = UIColor.white
        stepText.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightMedium)
        stepText.setTextWithHTMLString(stepViewData.block.text ?? "")

        let selectionAction: (TVFocusableText) -> Void = {
            [weak self] in
            guard let strongSelf = self else { return }

            let textPresenter = TVTextPresentationAlertController()
            textPresenter.setText($0.text ?? "")
            textPresenter.modalPresentationStyle = .overFullScreen
            strongSelf.present(textPresenter, animated: true, completion: {})
        }
        stepText.pressAction = selectionAction

        handleQuizType()
        contentView.setNeedsLayout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if hasQuiz {
            NotificationCenter.default.post(name: .stepUpdate, object: nil, userInfo: ["id": stepViewData.step.position])

            DispatchQueue.main.async {
                [weak self] in
                self?.stepViewData.step.progress?.isPassed = true
                CoreDataHelper.instance.save()
            }
        }
    }

    override func viewWillLayoutSubviews() {
        print("\(contentView.bounds.height) \(scrollView.bounds.height)")
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

    private func adaptStepText() {
        stepTextMaxHeightConstraint.isActive = false
        contentViewInsideVerticalSpacingConstraint.isActive = false
        stepText.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        stepText.isAnimatable = false
    }

    private func handleQuizType() {
        guard let quizVC = stepViewData.quizViewController else {
            hasQuiz = true
            adaptStepText()
            scrollView.panGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouchType.indirect.rawValue)]
            return
        }

        initQuizController(quizVC)
    }
}
