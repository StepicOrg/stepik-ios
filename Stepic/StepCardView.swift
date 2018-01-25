//
//  StepCardView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

protocol StepCardViewDelegate: class {
    func onControlButtonClick()
    func onTitleButtonClick()
}

extension StepCardViewDelegate {
    func onControlButtonClick() { }
    func onTitleButtonClick() { }
}

class StepCardView: NibInitializableView {
    override var nibName: String {
        return "StepCardView"
    }

    enum ControlState {
        case unsolved, wrong, successful
    }

    let loadingLabelTexts = stride(from: 1, to: 5, by: 1).map { NSLocalizedString("ReactionTransition\($0)", comment: "") }

    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var titlePadView: UIView!
    @IBOutlet weak var whitePadView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var controlButton: UIButton!

    weak var delegate: StepCardViewDelegate?

    var cardPadView: UIView!

    var cardState: CardState = .loading {
        didSet {
            titlePadView.isHidden = cardState == .loading
            loadingView.isHidden = cardState != .loading
            whitePadView.isHidden = cardState != .loading

            if cardState == .normal {
                UIView.transition(with: contentView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.controlButton.isHidden = false
                    self.contentView.isHidden = false
                }, completion: nil)
            } else {
                self.controlButton.isHidden = true
                self.contentView.isHidden = true
            }
        }
    }

    var controlState: ControlState = .unsolved {
        didSet {
            switch controlState {
            case .unsolved:
                controlButton.setTitle(NSLocalizedString("Submit", comment: ""), for: .normal)
                break
            case .wrong:
                controlButton.setTitle(NSLocalizedString("TryAgain", comment: ""), for: .normal)
                break
            case .successful:
                controlButton.setTitle(NSLocalizedString("NextTask", comment: ""), for: .normal)
                break
            }
        }
    }

    @IBAction func onControlButtonClick(_ sender: Any) {
        delegate?.onControlButtonClick()
    }

    @IBAction func onTitleButtonClick(_ sender: Any) {
        delegate?.onTitleButtonClick()
    }

    override func setupSubviews() {
        controlState = .unsolved

        colorize()

        loadingLabel.text = loadingLabelTexts[Int(arc4random_uniform(UInt32(loadingLabelTexts .count)))]

        if cardPadView == nil {
            backgroundColor = .clear
            layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
            layer.shouldRasterize = true
            layer.rasterizationScale = UIScreen.main.scale
            layer.shadowOffset = CGSize(width: 0.0, height: 3)
            layer.shadowOpacity = 0.2
            layer.shadowRadius = 4.5

            cardPadView = UIView(frame: bounds)
            cardPadView.backgroundColor = .white
            cardPadView.clipsToBounds = true
            cardPadView.layer.cornerRadius = 10
            insertSubview(cardPadView, at: 0)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if cardPadView != nil {
            cardPadView.frame = bounds
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        }
    }

    func addContentSubview(_ view: UIView) {
        contentView.addSubview(view)
        view.align(toView: contentView)

        setNeedsLayout()
        layoutIfNeeded()
    }

    func updateLabel(_ text: String) {
        titleLabel.text = text
    }

    fileprivate func colorize() {
        loadingLabel.textColor = UIColor.mainDark
        controlButton.tintColor = UIColor.mainDark
        titleButton.superview?.tintColor = UIColor.mainDark
    }

    enum CardState {
        case loading
        case normal
    }
}
