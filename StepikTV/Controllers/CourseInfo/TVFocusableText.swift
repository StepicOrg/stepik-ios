//
//  TVFocusableText.swift
//  StepikTV
//
//  Created by Александр Пономарев on 24.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class TVFocusableText: UILabel {

    var pressAction: ((TVFocusableText) -> Void)?

    private let substrateView: UIView = UIView()
    private var lastText: String = ""

    override var canBecomeFocused: Bool {
        return true
    }

    override func drawText(in rect: CGRect) {

        guard lastText != text || text != "" else {
            super.drawText(in: rect)
            return
        }

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
        guard presses.first!.type != UIPressType.menu else {
            super.pressesBegan(presses, with: event)
            return
        }

        UIView.animate(withDuration: 0.1, animations: self.changeToHighlighted )
        super.pressesBegan(presses, with: event)

        pressAction?(self)
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

class TVTextPresentationAlertController: UIViewController {

    private var contentLabel: UILabel!
    private var blurView: UIVisualEffectView!
    private var vibrancyView: UIVisualEffectView!

    let blurStyle = UIBlurEffectStyle.dark
    let contentWidth: CGFloat = 900

    func initBlur() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: blurStyle)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds

        return blurEffectView
    }

    func initVibrancy() -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: blurStyle)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)

        return vibrancyEffectView
    }

    func setText(_ text: String) {
        blurView = initBlur()
        vibrancyView = initVibrancy()
        contentLabel = initMainLabel(with: text)

        arrangeViews()
    }

    private func initMainLabel(with text: String) -> UILabel {
        let label = UILabel(frame: CGRect.zero)

        label.text = text
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 38, weight: UIFontWeightRegular)

        return label
    }

    private func arrangeViews() {
        view.addSubview(blurView)
        view.addSubview(vibrancyView)

        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentLabel)

        contentLabel.widthAnchor.constraint(equalToConstant: contentWidth).isActive = true
        contentLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contentLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    /*
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        print("Alert")
        super.pressesBegan(presses, with: event)
    }*/

    /*
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard presses.first!.type == UIPressType.menu else {
            super.pressesBegan(presses, with: event)
            return
        }
        print("Alert")
        leaveAlert(self)
    }

    @objc func leaveAlert(_: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    } */
}
