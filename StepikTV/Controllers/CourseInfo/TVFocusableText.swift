//
//  TVFocusableText.swift
//  StepikTV
//
//  Created by Александр Пономарев on 24.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class TVFocusableText: UILabel {

    let substrateView: UIView = UIView()

    var lastText: String = ""

    override var canBecomeFocused: Bool {
        return true
    }

    override func drawText(in rect: CGRect) {

        guard lastText != text else {
            super.drawText(in: rect)
            return
        }

        /*
        let height = rect.size.height + 40
        let width = rect.size.width + 40
        //bounds.size = CGSize(width: width, height: height)
        print(frame.origin)
        frame = frame.insetBy(dx: -20, dy: -20)
        print(frame.origin)
        //layer.cornerRadius = 10
        //layer.masksToBounds = true
        //backgroundColor = UIColor.white.withAlphaComponent(0.2)
 */
        substrateView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        substrateView.frame = rect.insetBy(dx: -20, dy: -20)
        substrateView.center = center
        substrateView.layer.cornerRadius = 10
        substrateView.clipsToBounds = true
        superview?.insertSubview(substrateView, belowSubview: self)

        lastText = text ?? ""
        super.drawText(in: rect)
    }

    var changeToDefault: () -> Void {
        return {
            self.transform = CGAffineTransform.identity
            self.substrateView.transform = CGAffineTransform.identity
            self.substrateView.alpha = 0
        }
    }

    var changeToFocused: () -> Void {
        return {
            self.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            self.substrateView.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            self.substrateView.alpha = 1
        }
    }

    var changeToHighlighted: () -> Void {
        return {
            self.transform = CGAffineTransform.identity
            self.substrateView.transform = CGAffineTransform.identity
            self.layer.shadowOffset = CGSize(width: 0, height: 10)
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

class TextPresentationViewController: UIViewController {
    let label = UILabel()
    let blurStyle = UIBlurEffectStyle.dark

    override func viewDidLoad() {

        let blurEffect = UIBlurEffect(style: blurStyle)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.addSubview(blurEffectView)

        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        view.addSubview(vibrancyEffectView)

        vibrancyEffectView.addSubview(label)

        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        label.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 1.0).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 1.0).isActive = true
    }
}
