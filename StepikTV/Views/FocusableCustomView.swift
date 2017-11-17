//
//  FocusableCustomView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 07.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class FocusableCustomView: UIView {

    override var canBecomeFocused: Bool {
        return true
    }

    var changeToDefault: () -> Void {
        return {
            self.transform = CGAffineTransform.identity
            self.layer.cornerRadius = 6
            self.layer.shadowOpacity = 0.0
        }
    }

    var changeToFocused: () -> Void {
        return {
            self.transform = CGAffineTransform(scaleX: 1.09, y: 1.09)
            self.layer.masksToBounds = false
            self.layer.shadowOffset = CGSize(width: 0, height: 40)
            self.layer.shadowRadius = 30
            self.layer.shadowOpacity = 0.3
        }
    }

    var changeToHighlighted: () -> Void {
        return {
            self.transform = CGAffineTransform.identity
            self.layer.shadowOffset = CGSize(width: 0, height: 10)
            self.layer.shadowOpacity = 0.15
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        changeToDefault()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        changeToDefault()
    }

    // Events to look for a Highlighted state

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        UIView.animate(withDuration: 0.1, animations: self.changeToHighlighted )
        super.pressesBegan(presses, with: event)
    }

    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        UIView.animate(withDuration: 0.1, animations: self.changeToFocused )
        super.pressesCancelled(presses, with: event)
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        UIView.animate(withDuration: 0.1, animations: self.changeToFocused )
        super.pressesEnded(presses, with: event)
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {

        // Mimik system focus/unfocus animation besides backgroundColor and title font

        if context.nextFocusedView == self {

            let animation: ((UIFocusAnimationContext) -> Void) = {
                let duration = $0.duration
                UIView.animate(withDuration: duration, animations: self.changeToFocused)
            }
            coordinator.addCoordinatedFocusingAnimations(animation, completion: nil)

        } else if context.previouslyFocusedView == self {

            let animation: ((UIFocusAnimationContext) -> Void) = {
                let duration = $0.duration
                UIView.animate(withDuration: duration, animations: self.changeToDefault)
            }
            coordinator.addCoordinatedUnfocusingAnimations( animation, completion: nil)
        }
    }
}
