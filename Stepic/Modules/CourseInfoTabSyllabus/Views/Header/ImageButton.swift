//
//  ImageButton.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 16/11/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class ImageButton: UIControl {
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.font
        return label
    }()

    private var additionalVerticalOffset: CGFloat = 0.0

    var imageSize = CGSize(width: 15, height: 15) {
        didSet {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    var imageInsets = UIEdgeInsets.zero {
        didSet {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    var titleInsets = UIEdgeInsets.zero {
        didSet {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    override var tintColor: UIColor? {
        didSet {
            self.titleLabel.textColor = self.tintColor
            self.iconImageView.tintColor = self.tintColor
        }
    }

    var font = UIFont.systemFont(ofSize: 16) {
        didSet {
            self.titleLabel.font = font
            self.titleLabel.sizeToFit()

            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
            self.titleLabel.sizeToFit()

            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }

    var image: UIImage? {
        didSet {
            self.iconImageView.image = self.image
        }
    }

    // To store private titleLabel
    // but sometimes we want to get direct reference to title view
    var titleContentView: UIView {
        return self.titleLabel
    }

    override var intrinsicContentSize: CGSize {
        let width = self.titleLabel.frame.maxX + self.titleInsets.right
        let height = max(
            self.iconImageView.frame.maxY + self.imageInsets.bottom,
            self.titleLabel.frame.maxY + self.titleInsets.bottom
        )
        return CGSize(
            width: width,
            height: height + self.additionalVerticalOffset
        )
    }

    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.alpha = 0.3
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.alpha = 1.0
                }
            }
        }
    }

    override var isEnabled: Bool {
        didSet {
            self.alpha = self.isEnabled ? 1.0 : 0.5
        }
    }

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let realHeight = max(
            self.imageInsets.top + self.imageSize.height + self.imageInsets.bottom,
            self.titleInsets.top + self.titleLabel.intrinsicContentSize.height + self.titleInsets.bottom
        )
        let heightDelta = self.frame.height - realHeight
        let additionalVerticalOffset = max(heightDelta, 0) / 2

        self.iconImageView.frame = CGRect(
            origin: CGPoint(
                x: self.imageInsets.left,
                y: additionalVerticalOffset + self.imageInsets.top
            ),
            size: self.imageSize
        )

        self.titleLabel.frame = CGRect(
            x: self.iconImageView.frame.maxX + self.titleInsets.left + self.imageInsets.right,
            y: additionalVerticalOffset + self.titleInsets.top,
            width: self.titleLabel.frame.width,
            height: self.titleLabel.frame.height
        )

        self.additionalVerticalOffset = additionalVerticalOffset

        self.invalidateIntrinsicContentSize()
    }

    private func setupView() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.titleLabel)
    }
}
