//
//  StandardButton.swift
//  StepikTV
//
//  Created by Александр Пономарев on 29.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

enum ButtonState {
    case Default
    case Focused
    case Highlighted
}

class StandardButton: UIButton {

    // Default state properties

    var defaultStateFont: UIFont { get { return UIFont.systemFont(ofSize: 38, weight: UIFontWeightMedium ) } }

    var defaultStateBackgroundColor: UIColor { get { return UIColor.clear } }

    var defaultStateTitleColor: UIColor { get { return UIColor.black.withAlphaComponent(0.2) } }

    // Focused state properties

    var focusStateFont: UIFont { get { return UIFont.systemFont(ofSize: 40, weight: UIFontWeightSemibold) } }

    var focusStateBackgroundColor: UIColor { get { return UIColor(red:0.50, green:0.79, blue:0.45, alpha:1.00) } }

    var focusScale: CGFloat { get { return 1.09 } }

    var focusStateTitleColor: UIColor { get { return UIColor.white } }

    // Initialize uibutton style
    private func initStyle() {
        self.layer.cornerRadius = 6
        setTitleColor(defaultStateTitleColor, for: .normal)
        setTitleColor(focusStateTitleColor, for: .focused)
        setTitleColor(focusStateTitleColor, for: .highlighted)

        changeState(to: .Default)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initStyle()
    }

    func changeState(to state: ButtonState) {
        switch state {

        case .Focused:
            self.transform = CGAffineTransform(scaleX: focusScale, y: focusScale)
            self.layer.masksToBounds = false
            self.layer.shadowOffset = CGSize(width: 0, height: 10)
            self.layer.shadowRadius = 15
            self.layer.shadowOpacity = 0.3
            self.backgroundColor = focusStateBackgroundColor
            titleLabel?.font = focusStateFont

        case .Highlighted:
            self.transform = CGAffineTransform.identity
            self.layer.shadowOffset = CGSize(width: 0, height: 5)
            self.layer.shadowOpacity = 0.15

        default:
            self.transform = CGAffineTransform.identity
            self.layer.shadowOpacity = 0.0
            self.backgroundColor = defaultStateBackgroundColor
            titleLabel?.font = defaultStateFont
        }
    }

    // TODO: Highlighted state animation

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        UIView.animate(withDuration: 0.1, animations: { self.changeState(to: .Highlighted)})

        super.pressesBegan(presses, with: event)
    }

    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        UIView.animate(withDuration: 0.1, animations: { self.changeState(to: .Focused) })

        super.pressesCancelled(presses, with: event)
    }

    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {

        // Mimik system focus/unfocus animation besides backgroundColor and title font

        if context.nextFocusedView == self {

            let animation: ((UIFocusAnimationContext) -> Void) = {
                let duration = $0.duration
                UIView.animate(withDuration: duration, animations: { self.changeState(to: .Focused) })
            }
            coordinator.addCoordinatedFocusingAnimations(animation, completion: nil)

        } else if context.previouslyFocusedView == self {

            let animation: ((UIFocusAnimationContext) -> Void) = {
                let duration = $0.duration
                UIView.animate(withDuration: duration, animations: { self.changeState(to: .Default) })
            }
            coordinator.addCoordinatedUnfocusingAnimations( animation, completion: nil)
        }
    }

}
