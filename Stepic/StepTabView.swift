//
//  StepTabView.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.04.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import Foundation

class StepTabView: NibInitializableView {

    @IBOutlet weak var stepIconImageView: UIImageView!

    @IBOutlet weak var solvedImageWidth: NSLayoutConstraint!
    @IBOutlet weak var solvedImageHeight: NSLayoutConstraint!

    let solvedViewHeight: CGFloat = 15
    var stepId: Int?
    private var token: NotificationToken?

    override var nibName: String {
        return "StepTabView"
    }

    override func setupSubviews() {
        token = NotificationCenter.default.addObserver(descriptor: Step.progressNotification) { [weak self] payload in
            guard let `self` = self,
                  let stepId = self.stepId, stepId == payload.id else {
                return
            }

            self.setTab(selected: payload.isPassed, animated: true)
        }
    }

    convenience init(frame: CGRect, image: UIImage, stepId: Int, passed: Bool) {
        self.init(frame: frame)
        stepIconImageView.image = image
        self.stepId = stepId
        if passed {
            setTab(selected: passed, animated: false)
        }
    }

    func setTab(selected isSelected: Bool, animated: Bool) {
        let targetSize: CGFloat = isSelected ? solvedViewHeight : 0
        solvedImageHeight.constant = targetSize
        solvedImageWidth.constant = targetSize
        view.setNeedsLayout()
        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            self.view.layoutIfNeeded()
        }
    }
}
