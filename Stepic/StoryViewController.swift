//
//  StoryViewController.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 03.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import UIKit
import SnapKit

class StoryViewController: UIViewController {

    @IBOutlet weak var closeButtonTapProxyView: TapProxyView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var progressView: SegmentedProgressView!
    @IBOutlet weak var partsContainerView: UIView!

    private lazy var topGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer(
            colors: [UIColor.black.withAlphaComponent(0.5), UIColor.clear],
            rotationAngle: 0
        )
        return layer
    }()

    var presenter: StoryPresenterProtocol?

    private var didAppear: Bool = false
    private var didLayout: Bool = false
    private var onAppearBlock: (() -> Void)?

    @IBAction func onCloseButtonClick(_ sender: Any) {
        presenter?.onClosePressed()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        progressView.completion = {
            [weak self] in
            self?.presenter?.finishedAnimating()
        }
        progressView.segmentsCount = presenter?.storyPartsCount ?? 0

        let tapG = UITapGestureRecognizer(target: self, action: #selector(StoryViewController.didTap(recognizer:)))
        view.addGestureRecognizer(tapG)
        tapG.cancelsTouchesInView = false

        if DeviceInfo.current.isPad {
            view.layer.cornerRadius = 8
            view.clipsToBounds = true
            view.layer.masksToBounds = true
        }

        closeButtonTapProxyView.targetView = closeButton

        self.view.layer.insertSublayer(self.topGradientLayer, below: self.progressView.layer)
        presenter?.animate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true

        if didAppear && didLayout {
            onAppearBlock?()
        }
        presenter?.didAppear()
        presenter?.resume()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.topGradientLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: self.view.frame.width,
            height: 2 * self.closeButton.frame.maxY
        )

        didLayout = true

        if didAppear && didLayout {
            onAppearBlock?()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.pause()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didAppear = false
        didLayout = false
        presenter?.pause()
    }

    private func add(partView: UIView) {
        partsContainerView.addSubview(partView)
        partView.snp.makeConstraints {
            make in
            make.edges.equalToSuperview()
        }
    }

    @objc
    func didTap(recognizer: UITapGestureRecognizer) {
        let closeLocation = recognizer.location(in: closeButtonTapProxyView)
        if closeButtonTapProxyView.bounds.contains(closeLocation) {
            return
        }

        let location = recognizer.location(in: view)
        if location.x < view.frame.width / 3 {
            rewind()
            return
        }

        if location.x > view.frame.width / 3 * 2 {
            skip()
            return
        }
    }

    func rewind() {
        presenter?.rewind()
    }

    func skip() {
        presenter?.skip()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        presenter?.pause()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        presenter?.resume()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        presenter?.resume()
    }

    func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension StoryViewController: StoryViewProtocol {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }

    func animate(view: UIView & UIStoryPartViewProtocol) {
        if view.isDescendant(of: partsContainerView) {
            partsContainerView.bringSubviewToFront(view)
        } else {
            add(partView: view)
            view.startLoad()
        }
    }

    func set(segment: Int, completed: Bool) {
        self.progressView.set(segment: segment, completed: completed)
    }

    func animateProgress(segment: Int, duration: TimeInterval) {
        if !didAppear {
            onAppearBlock = { [weak self] in
                self?.progressView.animate(duration: duration, segment: segment)
                self?.presenter?.resume()
                self?.onAppearBlock = nil
            }
        } else {
            progressView.animate(duration: duration, segment: segment)
            self.presenter?.resume()
        }
    }

    func pause(segment: Int) {
        progressView.pause(segment: segment)
    }

    func resume(segment: Int) {
        progressView.resume(segment: segment)
    }
}
