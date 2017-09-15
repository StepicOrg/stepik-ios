//
//  StepTabView.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.04.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

let StepDoneNotificationKey: String = "StepDoneNotificationKey"

class StepTabView: NibInitializableView {

    @IBOutlet weak var stepIconImageView: UIImageView!

    @IBOutlet weak var solvedImageWidth: NSLayoutConstraint!
    @IBOutlet weak var solvedImageHeight: NSLayoutConstraint!

    let solvedViewHeight: CGFloat = 15
    var stepId: Int?

    override var nibName: String {
        return "StepTabView"
    }

    override func setupSubviews() {
        NotificationCenter.default.addObserver(self, selector: #selector(StepTabView.stepDone(_:)), name: NSNotification.Name(rawValue: StepDoneNotificationKey), object: nil)
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

    func stepDone(_ notification: Foundation.Notification) {
        if let notificationStepId = (notification as NSNotification).userInfo?["id"] as? Int,
            let stepId = self.stepId {
            if notificationStepId == stepId {
                setTab(selected: true, animated: true)
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: StepDoneNotificationKey), object: nil)
    }
}
