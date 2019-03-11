//
//  CourseInfoBlurredBackgroundView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 01/11/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit
import Nuke

extension CourseInfoBlurredBackgroundView {
    struct Appearance {
        let imageFadeInDuration: TimeInterval = 0.15
        let placeholderImage = UIImage(named: "lesson_cover_50")!
        let overlayColor = UIColor(hex: 0x9191BC)
        let overlayAlpha: CGFloat = 0.75
    }
}

final class CourseInfoBlurredBackgroundView: UIView {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }()

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.overlayColor
        view.alpha = self.appearance.overlayAlpha
        return view
    }()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadImage(url: URL?) {
        if let url = url {
            Nuke.loadImage(
                with: url,
                options: ImageLoadingOptions(
                    transition: ImageLoadingOptions.Transition.fadeIn(
                        duration: self.appearance.imageFadeInDuration
                    )
                ),
                into: self.imageView
            )
        } else {
            self.imageView.image = nil
        }
    }
}

extension CourseInfoBlurredBackgroundView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.imageView.image = self.appearance.placeholderImage
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.overlayView)
        self.addSubview(self.blurView)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.blurView.translatesAutoresizingMaskIntoConstraints = false
        self.blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
