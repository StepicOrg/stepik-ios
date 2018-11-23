//
// CourseInfoTabInfoIntroVideoBlockView.swift
// stepik-ios
//
// Created by Ivan Magda on 11/9/18.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit
import Nuke

extension CourseInfoTabInfoIntroVideoBlockView {
    struct Appearance {
        let introVideoHeight: CGFloat = 203
        let insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)

        let thumbnailImageFadeInDuration: TimeInterval = 0.15

        let playImageViewSize = CGSize(width: 50, height: 50)
    }
}

final class CourseInfoTabInfoIntroVideoBlockView: UIView {
    private let appearance: Appearance

    var videoURL: URL? {
        didSet {
            print(self.videoURL)
        }
    }

    var thumbnailImageURL: URL? {
        didSet {
            self.loadThumbnail()
        }
    }

    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var playImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "play_dark"))
        imageView.contentMode = .scaleAspectFit

        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.playViewClicked(sender:))
        )
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)

        return imageView
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func loadThumbnail() {
        if let thumbnailImageURL = self.thumbnailImageURL {
            Nuke.loadImage(
                with: thumbnailImageURL,
                options: .init(
                    transition: .fadeIn(duration: self.appearance.thumbnailImageFadeInDuration)
                ),
                into: self.thumbnailImageView
            )
        } else {
            self.thumbnailImageView.image = nil
        }
    }

    @objc
    private func playViewClicked(sender: Any) {
        print(#function)
    }
}

extension CourseInfoTabInfoIntroVideoBlockView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.thumbnailImageView)
        self.addSubview(self.playImageView)
    }

    func makeConstraints() {
        self.thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        self.thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.insets)
            make.height.equalTo(self.appearance.introVideoHeight)
        }

        self.playImageView.translatesAutoresizingMaskIntoConstraints = false
        self.playImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.playImageViewSize)
            make.centerY.centerX.equalToSuperview()
        }
    }
}
