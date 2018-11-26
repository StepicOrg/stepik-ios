//
// CourseInfoTabInfoIntroVideoBlockView.swift
// stepik-ios
//
// Created by Ivan Magda on 11/9/18.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SnapKit
import Nuke

protocol CourseInfoTabInfoIntroVideoBlockViewDelegate: class {
    var playerParentViewController: UIViewController? { get }

    func courseInfoTabInfoIntroVideoBlockViewDidDismissFullscreen(
        _ CourseInfoTabInfoIntroVideoBlockView: CourseInfoTabInfoIntroVideoBlockView
    )
}

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

    weak var delegate: CourseInfoTabInfoIntroVideoBlockViewDelegate?

    var videoURL: URL? {
        didSet {
            self.initPlayerIfNeeded()
        }
    }

    var thumbnailImageURL: URL? {
        didSet {
            self.loadThumbnail()
        }
    }

    private var playerVideoBoundsObservation: NSKeyValueObservation?

    private lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        self.addPlayVideoGestureRecognizer(imageView: imageView)
        return imageView
    }()

    private lazy var playImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "play_dark"))
        imageView.contentMode = .scaleAspectFit
        self.addPlayVideoGestureRecognizer(imageView: imageView)
        return imageView
    }()

    @objc
    private dynamic lazy var playerViewController: AVPlayerViewController = {
        let playerViewController = AVPlayerViewController()
        playerViewController.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        playerViewController.view.isHidden = true

        self.playerVideoBoundsObservation = playerViewController.observe(
            \.videoBounds,
            options: [.old, .new]
        ) { (_, change) in
            guard let oldValue = change.oldValue,
                  let newValue = change.newValue else {
                return
            }
            if oldValue.size.height > self.appearance.introVideoHeight
                   && newValue.size.height == self.appearance.introVideoHeight {
                self.delegate?.courseInfoTabInfoIntroVideoBlockViewDidDismissFullscreen(self)
            }
        }

        return playerViewController
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

    // MARK: Lifecycle

    override func removeFromSuperview() {
        super.removeFromSuperview()
        self.playerViewController.player?.pause()
    }

    // MARK: Actions

    @objc
    private func playClicked() {
        self.playerViewController.view.isHidden = false
        self.playerViewController.player?.play()
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

    private func addPlayVideoGestureRecognizer(imageView: UIImageView) {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.playClicked)
        )
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
    }

    private func initPlayerIfNeeded() {
        if let videoURL = self.videoURL, self.playerViewController.player == nil {
            self.playerViewController.player = AVPlayer(url: videoURL)
        }
    }
}

extension CourseInfoTabInfoIntroVideoBlockView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .white
    }

    func addSubviews() {
        self.addSubview(self.thumbnailImageView)
        self.addSubview(self.playImageView)

        self.delegate?.playerParentViewController?.addChildViewController(self.playerViewController)
        self.addSubview(self.playerViewController.view)
        self.playerViewController.didMove(toParentViewController: self.delegate?.playerParentViewController)
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
            make.centerY.centerX.equalTo(self.thumbnailImageView.snp.center)
        }

        self.playerViewController.view.snp.makeConstraints { make in
            make.edges.equalTo(self.thumbnailImageView)
        }
    }
}
