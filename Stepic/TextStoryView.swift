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

class TextStoryView: UIView, UIStoryPartViewProtocol {
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    var completion: (() -> Void)?
    weak var urlNavigationDelegate: StoryURLNavigationDelegate?

    private var elementsStackView: UIStackView?
    private var imagePath: String = ""
    private var storyPart: TextStoryPart?

    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.isHidden = true
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
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leadingMargin.trailingMargin.equalTo(self)
            make.bottomMargin.equalTo(self).offset(-12)
        }
        elementsStackView = stackView
        elementsStackView?.isHidden = true
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
        if activityIndicator.isHidden != false {
            activityIndicator.isHidden = false
            elementsStackView?.isHidden = true
            activityIndicator.startAnimating()
        }
        guard let url = URL(string: imagePath) else { return }
        Nuke.loadImage(with: url, options: .shared, into: imageView) { [weak self] (_, _) in
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
            self?.elementsStackView?.isHidden = false
            self?.completion?()
        }
    }

    @objc
    func buttonClicked() {
        guard
            let path = storyPart?.button?.urlPath,
            let url = URL(string: path)
        else {
            return
        }
        urlNavigationDelegate?.open(url: url)
    }
}

protocol StoryURLNavigationDelegate: class {
    func open(url: URL)
}

protocol UIStoryPartViewProtocol {
    var completion: (() -> Void)? { get set }
    func startLoad()
}
