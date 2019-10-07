//
//  TextStoryView.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 03.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import UIKit
import Nuke
import SnapKit

final class TextStoryView: UIView, UIStoryPartViewProtocol {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    var completion: (() -> Void)?
    weak var urlNavigationDelegate: StoryURLNavigationDelegate?

    private var elementsStackView: UIStackView?
    private var imagePath: String = ""
    private var storyPart: TextStoryPart?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.activityIndicator.isHidden = true
    }

    func setup(storyPart: TextStoryPart, urlNavigationDelegate: StoryURLNavigationDelegate?) {
        self.imagePath = storyPart.imagePath
        self.urlNavigationDelegate = urlNavigationDelegate

        var storyContentViews: [UIView] = []
        if let text = storyPart.text {
            storyContentViews += [buildTextContainerView(text: text)]
        }
        if let button = storyPart.button {
            storyContentViews += [buildButtonView(button: button)]
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

    private func buildTextContainerView(text textModel: TextStoryPart.Text) -> UIView {
        let containerView = UIView()
        var views: [UIView] = []

        if let text = textModel.text {
            let label = UILabel()
            label.text = text
            label.textColor = textModel.textColor
            label.font = UIFont.systemFont(ofSize: 16, weight: .light)
            label.numberOfLines = 0

            containerView.addSubview(label)
            // TODO: Check for translatesAutoresizingMaskIntoConstraints
            label.snp.makeConstraints { make in
                make.leading.equalTo(containerView).offset(16)
                make.bottom.trailing.equalTo(containerView).offset(-16)
            }

            views += [label]
        }

        if let title = textModel.title {
            let label = UILabel()
            label.text = title
            label.textColor = textModel.textColor
            label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
            label.numberOfLines = 0

            containerView.addSubview(label)
            // TODO: Check for translatesAutoresizingMaskIntoConstraints
            label.snp.makeConstraints { make in
                make.leading.equalTo(containerView).offset(16)
                make.trailing.equalTo(containerView).offset(-16)
                if let lastView = views.last {
                    make.bottom.equalTo(lastView.snp.top).offset(-8)
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

    private func buildButtonView(button buttonModel: TextStoryPart.Button) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.clear

        let storyButton = StepikButton(type: .system)
        storyButton.backgroundColor = buttonModel.backgroundColor
        storyButton.setTitleColor(buttonModel.titleColor, for: .normal)
        storyButton.setTitle(buttonModel.title, for: .normal)

        containerView.addSubview(storyButton)
        // TODO: Check for translatesAutoresizingMaskIntoConstraints
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

        Nuke.loadImage(with: url, options: .shared, into: self.imageView) { [weak self] (_, _) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.activityIndicator.stopAnimating()
            strongSelf.activityIndicator.isHidden = true
            strongSelf.elementsStackView?.isHidden = false
            strongSelf.completion?()
        }
    }

    @objc
    func buttonClicked() {
        guard let part = self.storyPart,
              let path = part.button?.urlPath,
              let url = URL(string: path) else {
            return
        }

        AmplitudeAnalyticsEvents.Stories.buttonPressed(id: part.storyID, position: part.position).send()
        self.urlNavigationDelegate?.open(url: url)
    }
}

protocol StoryURLNavigationDelegate: class {
    func open(url: URL)
}

protocol UIStoryPartViewProtocol {
    var completion: (() -> Void)? { get set }
    func startLoad()
}
