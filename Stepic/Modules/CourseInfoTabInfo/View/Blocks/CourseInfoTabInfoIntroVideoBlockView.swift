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

protocol CourseInfoTabInfoIntroVideoBlockViewDelegate: class {
    func courseInfoTabInfoIntroVideoBlockViewRequestsVideoView(
        _ courseInfoTabInfoIntroVideoBlockView: CourseInfoTabInfoIntroVideoBlockView
    ) -> UIView

    func courseInfoTabInfoIntroVideoBlockViewDidAddVideoView(
        _ courseInfoTabInfoIntroVideoBlockView: CourseInfoTabInfoIntroVideoBlockView
    )

    func courseInfoTabInfoIntroVideoBlockViewDidReceiveVideoURL(
        _ courseInfoTabInfoIntroVideoBlockView: CourseInfoTabInfoIntroVideoBlockView,
        url: URL
    )

    func courseInfoTabInfoIntroVideoBlockViewPlayClicked(
        _ courseInfoTabInfoIntroVideoBlockView: CourseInfoTabInfoIntroVideoBlockView
    )
}

extension CourseInfoTabInfoIntroVideoBlockView {
    struct Appearance {
        let introVideoHeightRatio: CGFloat = 9 / 16
        let insets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        let thumbnailImageFadeInDuration: TimeInterval = 0.15

        let playImageTintColor = UIColor.white
        let playImageViewSize = CGSize(width: 25, height: 31)

        let overlayColor = UIColor.mainDark
        let overlayOpacity: CGFloat = 0.4

        let videoBackgroundColor = UIColor.white
    }
}

final class CourseInfoTabInfoIntroVideoBlockView: UIView {
    let appearance: Appearance

    weak var delegate: CourseInfoTabInfoIntroVideoBlockViewDelegate?

    var videoURL: URL? {
        didSet {
            if let videoURL = self.videoURL {
                self.delegate?.courseInfoTabInfoIntroVideoBlockViewDidReceiveVideoURL(self, url: videoURL)
            }
        }
    }

    var thumbnailImageURL: URL? {
        didSet {
            self.loadThumbnail()
        }
    }

    private weak var introVideoView: UIView?

    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.overlayColor
        view.alpha = self.appearance.overlayOpacity
        self.addPlayVideoGestureRecognizer(view: view)
        return view
    }()

    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var playImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(named: "video-preview-play-overlay")?.withRenderingMode(.alwaysTemplate)
        )
        imageView.tintColor = self.appearance.playImageTintColor
        imageView.contentMode = .scaleAspectFit
        self.addPlayVideoGestureRecognizer(view: imageView)
        return imageView
    }()

    // MARK: Init

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        delegate: CourseInfoTabInfoIntroVideoBlockViewDelegate? = nil
    ) {
        self.appearance = appearance
        self.delegate = delegate
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Actions

    @objc
    private func playClicked() {
        self.introVideoView?.isHidden = false
        self.delegate?.courseInfoTabInfoIntroVideoBlockViewPlayClicked(self)
    }

    // MARK: Private API

    private func loadThumbnail() {
        if let thumbnailImageURL = self.thumbnailImageURL {
            Nuke.loadImage(
                with: thumbnailImageURL,
                options: .init(
                    placeholder: Images.videoPlaceholder,
                    transition: .fadeIn(duration: self.appearance.thumbnailImageFadeInDuration)
                ),
                into: self.thumbnailImageView
            )
        } else {
            self.thumbnailImageView.image = Images.videoPlaceholder
        }
    }

    private func addPlayVideoGestureRecognizer(view: UIView) {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.playClicked)
        )
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGestureRecognizer)
    }
}

extension CourseInfoTabInfoIntroVideoBlockView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.thumbnailImageView)
        self.addSubview(self.overlayView)
        self.addSubview(self.playImageView)

        if let videoView = self.delegate?.courseInfoTabInfoIntroVideoBlockViewRequestsVideoView(self) {
            self.introVideoView = videoView
            self.introVideoView?.backgroundColor = self.appearance.videoBackgroundColor
            self.introVideoView?.isHidden = true
            self.addSubview(videoView)
            self.delegate?.courseInfoTabInfoIntroVideoBlockViewDidAddVideoView(self)
        }
    }

    func makeConstraints() {
        self.thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        self.thumbnailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.insets)
            make.height.equalTo(self.snp.width).multipliedBy(self.appearance.introVideoHeightRatio)
        }

        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.snp.makeConstraints { make in
            make.center.equalTo(self.thumbnailImageView)
            make.size.equalTo(self.thumbnailImageView)
        }

        self.playImageView.translatesAutoresizingMaskIntoConstraints = false
        self.playImageView.snp.makeConstraints { make in
            make.size.equalTo(self.appearance.playImageViewSize)
            make.centerY.centerX.equalTo(self.thumbnailImageView.snp.center)
        }

        self.introVideoView?.snp.makeConstraints { make in
            make.edges.equalTo(self.thumbnailImageView)
        }
    }
}
