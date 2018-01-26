//
//  TVChoiceQuizTableViewCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 26.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

enum CheckStatus {
    case on, off

    mutating func invert() {
        switch self {
        case .on: self = .off
        case .off: self = .on
        }
    }

    var inverted: CheckStatus {
        switch self {
        case .on: return .off
        case .off: return .on
        }
    }
}

protocol CheckStatusDelegate: class {

    func statusWillChange(_ cell: TVChoiceQuizTableViewCell, to: CheckStatus)
}

class TVChoiceQuizTableViewCell: UITableViewCell {

    static var nibName: String { return "TVChoiceQuizTableViewCell" }
    static var reuseIdentifier: String { return "TVChoiceQuizTableViewCell" }
    static func getHeightForText(text: String, width: CGFloat) -> CGFloat {
        return max(45, UILabel.heightForLabelWithText(text, lines: 0, font: UIFont.systemFont(ofSize: 40, weight: UIFontWeightMedium), width: width - 100, html: true, alignment: .left)) + 30
    }

    @IBOutlet weak var containerLabel: UILabel!
    @IBOutlet weak var checkBox: UIView!

    var index: Int!
    var status: CheckStatus = .off

    func setStatus(to status: CheckStatus) {
        self.status = status

        let statusColor: UIColor
        switch status {
        case .on: statusColor = UIColor.white.withAlphaComponent(1)
        case .off: statusColor = UIColor.white.withAlphaComponent(0.3)
        }

        containerLabel.textColor = statusColor
        checkBox.backgroundColor = statusColor
    }

    weak var delegate: CheckStatusDelegate?

    func setup(text: String, width: CGFloat, finishedBlock: @escaping (CGFloat) -> Void) {
        containerLabel.setTextWithHTMLString(text)

        let height = TVChoiceQuizTableViewCell.getHeightForText(text: containerLabel.text!, width: width)

        finishedBlock(height)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        containerLabel.textColor = UIColor.white.withAlphaComponent(0.3)
        containerLabel.numberOfLines = 0
        containerLabel.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightMedium)
        containerLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        containerLabel.baselineAdjustment = UIBaselineAdjustment.alignBaselines
        containerLabel.textAlignment = NSTextAlignment.left

        checkBox.setRoundedCorners(cornerRadius: checkBox.bounds.height / 2)
    }

    var changeToDefault: () -> Void {
        return { self.transform = CGAffineTransform.identity }
    }

    var changeToFocused: () -> Void {
        return { self.transform = CGAffineTransform(scaleX: 1.02, y: 1.02) }
    }

    var changeToHighlighted: () -> Void {
        return { self.transform = CGAffineTransform.identity }
    }

    // Events to look for a Highlighted state

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard presses.first!.type != UIPressType.menu else {
            super.pressesBegan(presses, with: event)
            return
        }

        UIView.animate(withDuration: 0.1, animations: self.changeToHighlighted )
        super.pressesBegan(presses, with: event)
    }

    override func pressesCancelled(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard presses.first!.type != UIPressType.menu else {
            super.pressesBegan(presses, with: event)
            return
        }

        UIView.animate(withDuration: 0.1, animations: self.changeToFocused )
        super.pressesCancelled(presses, with: event)
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard presses.first!.type != UIPressType.menu else {
            super.pressesBegan(presses, with: event)
            return
        }

        UIView.animate(withDuration: 0.1, animations: self.changeToFocused )
        super.pressesEnded(presses, with: event)

        delegate?.statusWillChange(self, to: status.inverted)
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
