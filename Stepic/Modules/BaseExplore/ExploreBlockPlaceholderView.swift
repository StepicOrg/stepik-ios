//
//  ExploreBlockPlaceholderView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 04.10.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

extension ExploreBlockPlaceholderView {
    struct Appearance {
        let insets = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        let height: CGFloat = 104
        let cornerRadius: CGFloat = 8
    }
}

final class ExploreBlockPlaceholderView: UIView {
    let appearance: Appearance
    private let message: GradientCoursesPlaceholderViewFactory.InfoPlaceholderMessage

    private lazy var placeholderView: UIView = {
        let view = GradientCoursesPlaceholderViewFactory().makeInfoPlaceholder(message: self.message)
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.cornerRadius
        return view
    }()

    private lazy var overlayButton: UIButton = {
        let button = HighlightFakeButton()
        button.isEnabled = false
        button.addTarget(self, action: #selector(self.overlayButtonClicked), for: .touchUpInside)
        return button
    }()

    var onPlaceholderClick: (() -> Void)? {
        didSet {
            self.overlayButton.isEnabled = self.onPlaceholderClick != nil
        }
    }

    override var intrinsicContentSize: CGSize {
        let insets = self.appearance.insets.top + self.appearance.insets.bottom
        return CGSize(
            width: UIViewNoIntrinsicMetric,
            height: self.appearance.height + insets
        )
    }

    init(
        frame: CGRect,
        message: GradientCoursesPlaceholderViewFactory.InfoPlaceholderMessage,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        self.message = message
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }

    @objc
    private func overlayButtonClicked() {
        self.onPlaceholderClick?()
    }
}

extension ExploreBlockPlaceholderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.placeholderView)
        self.addSubview(self.overlayButton)
    }

    func makeConstraints() {
        self.placeholderView.translatesAutoresizingMaskIntoConstraints = false
        self.placeholderView.snp.makeConstraints { make in
            make.top.equalTo(self.appearance.insets.top)
            make.leading.equalTo(self.appearance.insets.left)
            make.trailing.equalTo(-self.appearance.insets.right)
            make.bottom.equalTo(-self.appearance.insets.bottom)
            make.height.equalTo(self.appearance.height)
        }

        self.overlayButton.translatesAutoresizingMaskIntoConstraints = false
        self.overlayButton.snp.makeConstraints { make in
            make.size.equalTo(self.placeholderView)
            make.center.equalTo(self.placeholderView)
        }
    }
}
