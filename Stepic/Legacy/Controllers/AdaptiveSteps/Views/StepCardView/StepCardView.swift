//
//  StepCardView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

protocol StepCardViewDelegate: AnyObject {
    func onControlButtonClick()
    func onTitleButtonClick()
}

extension StepCardViewDelegate {
    func onControlButtonClick() {}
    func onTitleButtonClick() {}
}

final class StepCardView: NibInitializableView {
    override var nibName: String { "StepCardView" }

    enum ControlState {
        case unsolved
        case wrong
        case successful
    }

    enum CardState {
        case loading
        case normal
    }

    let loadingLabelTexts = stride(from: 1, to: 5, by: 1)
        .map { NSLocalizedString("ReactionTransition\($0)", comment: "") }

    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var titlePadView: UIView!
    @IBOutlet var titleSeparatorView: UIView!
    @IBOutlet weak var whitePadView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var bottomSeparatorView: UIView!
    @IBOutlet weak var controlButton: UIButton!

    weak var delegate: StepCardViewDelegate?

    var cardPadView: UIView!

    var cardState: CardState = .loading {
        didSet {
            self.titlePadView.isHidden = cardState == .loading
            self.loadingView.isHidden = cardState != .loading
            self.whitePadView.isHidden = cardState != .loading

            if self.cardState == .normal {
                UIView.transition(
                    with: self.contentView,
                    duration: 0.5,
                    options: .transitionCrossDissolve,
                    animations: {
                        self.controlButton.isHidden = false
                        self.contentView.isHidden = false
                    },
                    completion: nil
                )
            } else {
                self.controlButton.isHidden = true
                self.contentView.isHidden = true
            }
        }
    }

    var controlState: ControlState = .unsolved {
        didSet {
            switch self.controlState {
            case .unsolved:
                self.controlButton.setTitle(NSLocalizedString("Submit", comment: ""), for: .normal)
            case .wrong:
                self.controlButton.setTitle(NSLocalizedString("TryAgain", comment: ""), for: .normal)
            case .successful:
                self.controlButton.setTitle(NSLocalizedString("NextTask", comment: ""), for: .normal)
            }
        }
    }

    @IBAction
    func onControlButtonClick(_ sender: Any) {
        self.delegate?.onControlButtonClick()
    }

    @IBAction
    func onTitleButtonClick(_ sender: Any) {
        self.delegate?.onTitleButtonClick()
    }

    override func setupSubviews() {
        self.controlState = .unsolved

        self.colorize()

        self.loadingLabel.text = self.loadingLabelTexts[Int(arc4random_uniform(UInt32(self.loadingLabelTexts.count)))]

        if self.cardPadView == nil {
            self.backgroundColor = .clear
            self.layer.shadowPath = UIBezierPath(
                roundedRect: self.layer.bounds,
                cornerRadius: self.layer.cornerRadius
            ).cgPath
            self.layer.shouldRasterize = true
            self.layer.rasterizationScale = UIScreen.main.scale
            self.layer.shadowOffset = CGSize(width: 0.0, height: 3)
            self.layer.shadowOpacity = 0.2
            self.layer.shadowRadius = 4.5

            self.cardPadView = UIView(frame: bounds)
            self.cardPadView.backgroundColor = .stepikTertiaryBackground
            self.cardPadView.clipsToBounds = true
            self.cardPadView.layer.cornerRadius = 10
            self.insertSubview(self.cardPadView, at: 0)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.cardPadView != nil {
            self.cardPadView.frame = self.bounds
            self.layer.shadowPath = UIBezierPath(
                roundedRect: self.bounds,
                cornerRadius: self.layer.cornerRadius
            ).cgPath
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    func addContentSubview(_ view: UIView) {
        self.contentView.addSubview(view)

        view.snp.makeConstraints { $0.edges.equalTo(self.contentView) }

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    func updateLabel(_ text: String) {
        self.titleLabel.text = text
    }

    private func colorize() {
        self.contentView.backgroundColor = .stepikTertiaryBackground

        if let cardPadView = self.cardPadView {
            cardPadView.backgroundColor = .stepikTertiaryBackground
        }

        self.titlePadView.backgroundColor = .clear
        self.titleLabel.textColor = .stepikSystemLabel
        self.titleButton.superview?.tintColor = .stepikAccent
        self.titleSeparatorView.backgroundColor = .stepikSeparator

        self.whitePadView.backgroundColor = .clear

        self.loadingView.backgroundColor = .clear
        self.loadingActivityIndicator.color = .stepikLoadingIndicator
        self.loadingLabel.textColor = .stepikAccent

        self.bottomSeparatorView.backgroundColor = .stepikSeparator
        self.controlButton.tintColor = .stepikAccent
    }
}
