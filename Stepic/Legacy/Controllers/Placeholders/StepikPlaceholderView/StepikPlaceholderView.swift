//
//  StepikPlaceholderView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 16.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

protocol StepikPlaceholderViewDelegate: AnyObject {
    func buttonDidClick(_ button: UIButton)
}

extension StepikPlaceholderView {
    struct Appearance {
        var backgroundColor = UIColor.stepikBackground
        let textColor = UIColor.stepikSystemSecondaryText
        let actionButtonBorderColor = UIColor.stepikOpaqueSeparator
        let actionButtonTitleColor = UIColor.stepikPrimaryText
    }
}

final class StepikPlaceholderView: NibInitializableView {
    struct maxHeight {
        static let horizontal = CGFloat(500)
        static let vertical = CGFloat(500)
    }

    struct imageHeightToFrameHeightRatio {
        static let horizontal = CGFloat(0.75)
        static let vertical = CGFloat(0.5)
    }

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var actionsStackView: UIStackView!
    @IBOutlet weak var imageContainerView: UIView!

    private lazy var allPlaceholders: [StepikPlaceholderStyle.PlaceholderId: StepikPlaceholderStyle] = {
        var idToView: [StepikPlaceholderStyle.PlaceholderId: StepikPlaceholderStyle] = [:]
        for placeholder in StepikPlaceholderStyle.stepikStyledPlaceholders {
            idToView[placeholder.id] = placeholder
        }
        return idToView
    }()

    private var currentPlaceholder: StepikPlaceholderStyle?

    weak var delegate: StepikPlaceholderViewDelegate?

    var appearance = Appearance() {
        didSet {
            self.colorize()
        }
    }

    override var nibName: String { "StepikPlaceholderView" }

    convenience init(placeholder: StepikPlaceholderStyle) {
        self.init()
        set(placeholder: placeholder)
    }

    @IBAction
    func onActionButtonClick(_ sender: Any) {
        delegate?.buttonDidClick(actionButton)
    }

    override func setupSubviews() {
        self.actionButton.clipsToBounds = true
        self.actionButton.layer.cornerRadius = 8
        self.actionButton.layer.borderWidth = 0.5
        self.actionButton.accessibilityIdentifier = "loginButton"
        
        self.actionButton.contentEdgeInsets = UIEdgeInsets(top: 12.0, left: 23.0, bottom: 12.0, right: 23.0)

        self.colorize()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    private func colorize() {
        self.view.backgroundColor = self.appearance.backgroundColor
        self.textLabel.textColor = self.appearance.textColor
        self.actionButton.layer.borderColor = self.appearance.actionButtonBorderColor.cgColor
        self.actionButton.setTitleColor(self.appearance.actionButtonTitleColor, for: .normal)
    }

    private func rebuildConstraints(for placeholder: StepikPlaceholderStyle) {
        let isVertical = bounds.width < bounds.height

        let hasImage = placeholder.image != nil
        let imageRatio = (placeholder.image?.image?.size.width ?? 1) / (placeholder.image?.image?.size.height ?? 1)
        stackView.layoutIfNeeded()

        if hasImage {
            if !stackView.arrangedSubviews.contains(imageContainerView) {
                stackView.insertArrangedSubview(imageContainerView, at: 0)
            }
            imageContainerView.isHidden = false

            var framedImageHeight = CGFloat(0.0)
            var scaleFactor = CGFloat(1.0)

            if isVertical {
                framedImageHeight = min(maxHeight.vertical, bounds.height * imageHeightToFrameHeightRatio.vertical)
            } else {
                framedImageHeight = min(maxHeight.horizontal, bounds.height * imageHeightToFrameHeightRatio.horizontal)
            }

            let elementSizes = allPlaceholders.values
                .compactMap { $0.image }
                .map { $0.scale * framedImageHeight }

            let currentElementSize = placeholder.image!.scale * framedImageHeight
            let minElementSize = elementSizes.min() ?? 0.0
            scaleFactor = currentElementSize > 0 ? minElementSize / currentElementSize : 1

            imageViewHeightConstraint.constant = scaleFactor * framedImageHeight
            imageViewWidthConstraint.constant = imageViewHeightConstraint.constant * imageRatio
        } else {
            stackView.removeArrangedSubview(imageContainerView)
            imageContainerView.isHidden = true
        }

        if placeholder.buttonTitle != nil {
            actionButton.alpha = 1.0
            actionButton.isHidden = false
        } else {
            actionButton.alpha = 0.0
            actionButton.isHidden = !isVertical
        }

        if isVertical {
            stackView.axis = .vertical
            stackView.distribution = .equalCentering
            stackView.alignment = .fill
        } else {
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.alignment = .center
        }
    }

    override func updateConstraints() {
        super.updateConstraints()
        if let currentPlaceholder = self.currentPlaceholder {
            self.rebuildConstraints(for: currentPlaceholder)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsUpdateConstraints()
        self.updateConstraintsIfNeeded()
    }

    func set(placeholder: StepikPlaceholderStyle) {
        imageView.image = placeholder.image?.image

        textLabel.text = placeholder.text

        // If it's first load prevent button title change animation
        if currentPlaceholder == nil {
            UIView.performWithoutAnimation {
                self.actionButton.setTitle(placeholder.buttonTitle, for: .normal)
                self.actionButton.layoutIfNeeded()
            }
        } else {
            actionButton.setTitle(placeholder.buttonTitle, for: .normal)
        }

        currentPlaceholder = placeholder
        rebuildConstraints(for: placeholder)
    }
}
