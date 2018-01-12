//
//  InstructorItemCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 09.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class InstructorItemCell: UICollectionViewCell {

    static var nibName: String { return "InstructorItemCell" }
    static var reuseIdentifier: String { return "InstructorItemCell" }
    static var size: CGSize { return CGSize(width: 250.0, height: 326.0) }

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!

    var pressAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.layer.cornerRadius = imageView.bounds.height / 2
        imageView.layer.masksToBounds = true

        changeToDefault()
    }

    func setup(with item: ItemViewData) {
        titleLabel.text = item.title
        pressAction = item.action

        imageView.setImageWithURL(url: item.backgroundImageURL, placeholder: item.placeholder)
    }

    var changeToDefault: () -> Void {
        return {
            self.transform = CGAffineTransform.identity
            self.layer.shadowOpacity = 0.0
        }
    }

    var changeToFocused: () -> Void {
        return {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.layer.shadowOffset = CGSize(width: 0, height: 10)
            self.layer.shadowRadius = 25
            self.layer.shadowOpacity = 0.2
            self.layer.shadowPath = UIBezierPath(roundedRect: self.imageView.bounds, cornerRadius: self.imageView.bounds.height / 2).cgPath
        }
    }

    var changeToHighlighted: () -> Void {
        return {
            self.transform = CGAffineTransform.identity
            self.layer.shadowOffset = CGSize(width: 0, height: 5)
            self.layer.shadowOpacity = 0.15
        }
    }

    // Events to look for a Highlighted state

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        UIView.animate(withDuration: 0.1, animations: self.changeToHighlighted )
        super.pressesBegan(presses, with: event)

        pressAction?()
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
