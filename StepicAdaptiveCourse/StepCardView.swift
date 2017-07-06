//
//  StepCardView.swift
//  CardsDemo
//
//  Created by Vladislav Kiryukhin on 04.04.17.
//  Copyright © 2017 Vladislav Kiryukhin. All rights reserved.
//

import UIKit
import FLAnimatedImage

protocol StepCardViewDelegate: class {
    func onControlButtonClick(with state: StepCardView.ControlButtonState)
}

class StepCardView: UIView {
    let loadingLabelTexts = stride(from: 1, to: 5, by: 1).map { NSLocalizedString("ReactionTransition\($0)", comment: "") }
    
    @IBOutlet weak var whitePadView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var loadingImageView: FLAnimatedImageView!
    
    var gradientLayer: CAGradientLayer?
    weak var delegate: StepCardViewDelegate?
    
    var controlButtonState: ControlButtonState = .submit {
        didSet {
            switch controlButtonState {
            case .submit:
                controlButton.setTitle(NSLocalizedString("Submit", comment: ""), for: .normal)
                break
            case .tryAgain:
                controlButton.setTitle(NSLocalizedString("TryAgain", comment: ""), for: .normal)
                break
            case .next:
                controlButton.setTitle(NSLocalizedString("NextTask", comment: ""), for: .normal)
                break
            }
        }
    }
    
    var cardState: CardState = .loading {
        didSet {
            titleLabel.isHidden = cardState == .loading
            loadingView.isHidden = cardState != .loading
            whitePadView.isHidden = cardState != .loading
            
            if cardState == .normal {
                UIView.transition(with: contentView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.controlButton.isHidden = false
                    self.contentView.isHidden = false
                    self.gradientLayer = CAGradientLayer()
                    if let gradient = self.gradientLayer {
                        gradient.frame = self.contentView.bounds
                        gradient.colors = [UIColor.white.withAlphaComponent(0.0).cgColor,
                                           UIColor.white.withAlphaComponent(0.15).cgColor,
                                           UIColor.white.withAlphaComponent(1.0).cgColor]
                        gradient.locations = [0.0, 0.95, 1.0]
                        self.contentView.layer.addSublayer(gradient)
                    }
                }, completion: nil)
            } else {
                self.controlButton.isHidden = true
                self.contentView.isHidden = true
            }
        }
    }
    
    @IBAction func onControlButtonClick(_ sender: Any) {
        delegate?.onControlButtonClick(with: controlButtonState)
    }

    override func draw(_ rect: CGRect) {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.stepicGreenColor().cgColor
        
        let gifFile = FileManager.default.contents(atPath: Bundle.main.path(forResource: "loading_robot", ofType: "gif")!)
        loadingImageView.animatedImage = FLAnimatedImage(animatedGIFData: gifFile)
        loadingLabel.text = loadingLabelTexts[Int(arc4random_uniform(UInt32(loadingLabelTexts .count)))]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = contentView.bounds
    }
    
    func addContentSubview(_ view: UIView) {
        contentView.addSubview(view)
        view.align(to: contentView)
        
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func updateLabel(_ text: String) {
        titleLabel.text = text
    }
    
    enum ControlButtonState {
        case submit
        case tryAgain
        case next
    }
    
    enum CardState {
        case loading
        case normal
    }
}
