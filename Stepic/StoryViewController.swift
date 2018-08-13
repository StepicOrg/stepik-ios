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

    @IBOutlet weak var progressView: SegmentedProgressView!
    @IBOutlet weak var partsContainerView: UIView!
    @IBOutlet weak var closeView: UIView!

    private var gradientLayer: CAGradientLayer?

    var presenter: StoryPresenterProtocol?

    private var didAppear: Bool = false
    private var onAppearBlock: (() -> Void)?

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

        presenter?.animate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        UIApplication.shared.statusBarStyle = .lightContent

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
        presenter?.didAppear()
        onAppearBlock?()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didAppear = false
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
        let closeLocation = recognizer.location(in: closeView)
        if 0 <= closeLocation.x && closeLocation.x < closeView.frame.width
            && 0 <= closeLocation.y && closeLocation.y < closeView.frame.height {
            close()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        presenter?.pause()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        presenter?.unpause()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        presenter?.unpause()
    }

    func close() {
        //TODO: Translate this to presenter
        dismiss(animated: true, completion: nil)
    }
}

extension StoryViewController: StoryViewProtocol {
    func animate(view: UIView & UIStoryPartViewProtocol) {
        if view.isDescendant(of: partsContainerView) {
            partsContainerView.bringSubview(toFront: view)
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
                self?.onAppearBlock = nil
            }
        } else {
            progressView.animate(duration: duration, segment: segment)
        }
    }

    func pause(segment: Int) {
        progressView.pause(segment: segment)
    }

    func unpause(segment: Int) {
        progressView.unpause(segment: segment)
    }
}
