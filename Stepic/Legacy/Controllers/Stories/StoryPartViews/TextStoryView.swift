//
//  TextStoryView.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 03.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import Nuke
import SnapKit
import UIKit

extension TextStoryView {
    struct Appearance {
        let titleLabelFont = Typography.largeTitleFont
        let titleLabelInsets = LayoutInsets(left: 16, bottom: 8, right: 16)

        let textLabelFont = Typography.title2Font
        let textLabelInsets = LayoutInsets(left: 16, bottom: 16, right: 16)

        let buttonFont = Typography.bodyFont
    }
}

final class TextStoryView: UIView, UIStoryPartViewProtocol {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    var appearance = Appearance()

    var completion: (() -> Void)?
    weak var urlNavigationDelegate: StoryURLNavigationDelegate?

    private var elementsStackView: UIStackView?
    private var imagePath: String = ""
    private var storyPart: TextStoryPart?

    private let analytics: Analytics = StepikAnalytics.shared

    override func awakeFromNib() {
        super.awakeFromNib()
        self.activityIndicator.isHidden = true
    }

    func setup(storyPart: TextStoryPart, urlNavigationDelegate: StoryURLNavigationDelegate?) {
        self.imagePath = storyPart.imagePath
        self.urlNavigationDelegate = urlNavigationDelegate

        var storyContentViews: [UIView] = []
        if let text = storyPart.text {
            storyContentViews += [self.makeTextContainerView(text: text)]
        }
        if let button = storyPart.button {
            storyContentViews += [self.makeButtonView(button: button)]
        }

        let stackView = UIStackView(arrangedSubviews: storyContentViews)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 16

        self.addSubview(stackView)
        // TODO: Check for translatesAutoresizingMaskIntoConstraints
        stackView.snp.makeConstraints { make in
            make.leadingMargin.trailingMargin.equalTo(self)
            make.bottomMargin.equalTo(self).offset(-12)
        }

        self.elementsStackView = stackView
        self.elementsStackView?.isHidden = true

        self.storyPart = storyPart
    }

    private func makeTextContainerView(text textModel: TextStoryPart.Text) -> UIView {
        let containerView = UIView()
        var views: [UIView] = []

        if let text = textModel.text {
            let label = UILabel()
            label.text = text
            label.textColor = textModel.textColor
            label.font = self.appearance.textLabelFont
            label.numberOfLines = 0

            containerView.addSubview(label)
            // TODO: Check for translatesAutoresizingMaskIntoConstraints
            label.snp.makeConstraints { make in
                make.leading.equalTo(containerView).offset(self.appearance.textLabelInsets.left)
                make.bottom.equalTo(containerView).offset(-self.appearance.textLabelInsets.bottom)
                make.trailing.equalTo(containerView).offset(-self.appearance.textLabelInsets.right)
            }

            views += [label]
        }

        if let title = textModel.title {
            let label = UILabel()
            label.text = title
            label.textColor = textModel.textColor
            label.font = self.appearance.titleLabelFont
            label.numberOfLines = 0

            containerView.addSubview(label)
            // TODO: Check for translatesAutoresizingMaskIntoConstraints
            label.snp.makeConstraints { make in
                make.leading.equalTo(containerView).offset(self.appearance.titleLabelInsets.left)
                make.trailing.equalTo(containerView).offset(-self.appearance.titleLabelInsets.right)
                if let lastView = views.last {
                    make.bottom.equalTo(lastView.snp.top).offset(-self.appearance.titleLabelInsets.bottom)
                }
            }

            views += [label]
        }

        containerView.backgroundColor = textModel.backgroundStyle.backgroundColor
        containerView.setRoundedCorners(cornerRadius: 8)

        views.last?.snp.makeConstraints { make in
            make.top.equalTo(containerView).offset(16)
        }

        return containerView
    }

    private func makeButtonView(button buttonModel: TextStoryPart.Button) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear

        let storyButton = StepikButton(type: .system)
        storyButton.backgroundColor = buttonModel.backgroundColor
        storyButton.titleLabel?.font = self.appearance.buttonFont
        storyButton.setTitleColor(buttonModel.titleColor, for: .normal)
        storyButton.setTitle(buttonModel.title, for: .normal)

        containerView.addSubview(storyButton)
        storyButton.translatesAutoresizingMaskIntoConstraints = false
        storyButton.snp.makeConstraints { make in
            make.bottom.top.equalTo(containerView)
            make.centerX.equalTo(containerView)
            make.width.equalTo(180)
            make.height.equalTo(48)
        }

        storyButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)

        return containerView
    }

    func startLoad() {
        if self.activityIndicator.isHidden != false {
            self.activityIndicator.isHidden = false
            self.elementsStackView?.isHidden = true
            self.activityIndicator.startAnimating()
        }

        guard let url = URL(string: self.imagePath) else {
            return
        }

        Nuke.loadImage(with: url, options: .shared, into: self.imageView, completion:  { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.activityIndicator.stopAnimating()
            strongSelf.activityIndicator.isHidden = true
            strongSelf.elementsStackView?.isHidden = false
            strongSelf.completion?()
        })
    }

    @objc
    func buttonClicked() {
        guard let part = self.storyPart,
              let path = part.button?.urlPath,
              let url = URL(string: path) else {
            return
        }

        self.analytics.send(.storyButtonPressed(id: part.storyID, position: part.position))
        self.urlNavigationDelegate?.open(url: url)
    }
}

protocol StoryURLNavigationDelegate: AnyObject {
    func open(url: URL)
}

protocol UIStoryPartViewProtocol {
    var completion: (() -> Void)? { get set }
    func startLoad()
}
