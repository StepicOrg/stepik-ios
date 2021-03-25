//
//  StoryViewController.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 03.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import SnapKit
import UIKit

final class StoryViewController: UIViewController {
    @IBOutlet weak var closeButtonTapProxyView: TapProxyView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var progressView: SegmentedProgressView!
    @IBOutlet weak var partsContainerView: UIView!

    var presenter: StoryPresenterProtocol?

    private var didAppear = false
    private var didLayout = false
    private var onAppearBlock: (() -> Void)?

    @IBAction func onCloseButtonClick(_ sender: Any) {
        presenter?.onClosePressed()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.progressView.completion = { [weak self] in
            self?.presenter?.finishedAnimating()
        }
        self.progressView.segmentsCount = self.presenter?.storyPartsCount ?? 0

        let gestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(StoryViewController.didTap(recognizer:))
        )
        gestureRecognizer.delegate = self
        self.view.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.cancelsTouchesInView = false

        if DeviceInfo.current.isPad {
            self.view.layer.cornerRadius = 8
            self.view.clipsToBounds = true
            self.view.layer.masksToBounds = true
        }

        self.closeButtonTapProxyView.targetView = self.closeButton

        self.presenter?.animate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.didAppear = true

        if self.didAppear && self.didLayout {
            self.onAppearBlock?()
        }

        self.presenter?.didAppear()
        self.presenter?.resume()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.didLayout = true

        if self.didAppear && self.didLayout {
            self.onAppearBlock?()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.presenter?.pause()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.didAppear = false
        self.didLayout = false
        self.presenter?.pause()
    }

    private func add(partView: UIView) {
        self.partsContainerView.addSubview(partView)
        partView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc
    private func didTap(recognizer: UITapGestureRecognizer) {
        let closeLocation = recognizer.location(in: self.closeButtonTapProxyView)
        if self.closeButtonTapProxyView.bounds.contains(closeLocation) {
            return
        }

        let location = recognizer.location(in: self.view)
        if location.x < self.view.frame.width / 3 {
            self.rewind()
            return
        }

        if location.x > self.view.frame.width / 3 * 2 {
            self.skip()
            return
        }
    }

    private func rewind() {
        self.presenter?.rewind()
    }

    private func skip() {
        self.presenter?.skip()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.presenter?.pause()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.presenter?.resume()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.presenter?.resume()
    }
}

extension StoryViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let isControllTapped = touch.view is UIControl
        return !isControllTapped
    }
}

extension StoryViewController: StoryViewProtocol {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    override var shouldAutorotate: Bool { false }

    func animate(view: UIView & UIStoryPartViewProtocol) {
        if view.isDescendant(of: self.partsContainerView) {
            self.partsContainerView.bringSubviewToFront(view)
        } else {
            self.add(partView: view)
            view.startLoad()
        }
    }

    func set(segment: Int, completed: Bool) {
        self.progressView.set(segment: segment, completed: completed)
    }

    func animateProgress(segment: Int, duration: TimeInterval) {
        if !self.didAppear {
            self.onAppearBlock = { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.progressView.animate(duration: duration, segment: segment)
                strongSelf.presenter?.resume()
                strongSelf.onAppearBlock = nil
            }
        } else {
            self.progressView.animate(duration: duration, segment: segment)
            self.presenter?.resume()
        }
    }

    func pause(segment: Int) {
        self.progressView.pause(segment: segment)
    }

    func resume(segment: Int) {
        self.progressView.resume(segment: segment)
    }

    func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
