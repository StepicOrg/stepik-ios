//
//  StoryViewController.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 03.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import UIKit
import SnapKit
import Hero

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

        view.hero.id = "story_\(presenter?.storyID ?? -1)"
        progressView.completion = {
            [weak self] in
            self?.presenter?.finishedAnimating()
        }
        progressView.segmentsCount = presenter?.storyPartsCount ?? 0

        let tapG = UITapGestureRecognizer(target: self, action: #selector(StoryViewController.didTap(recognizer:)))
        view.addGestureRecognizer(tapG)
        tapG.cancelsTouchesInView = false

        let panGR = UIPanGestureRecognizer(target: self, action: #selector(StoryViewController.didPan(recognizer:)))
        view.addGestureRecognizer(panGR)
        panGR.cancelsTouchesInView = false

        let downPanGR = UIPanGestureRecognizer(target: self, action: #selector(StoryViewController.didPanDown(recognizer:)))
        view.addGestureRecognizer(downPanGR)
        downPanGR.cancelsTouchesInView = false
        downPanGR.delegate = self
        presenter?.animate()
    }

    enum TransitionState {
        case normal, slidingLeft, slidingRight
    }
    var state: TransitionState = .normal

    @objc func didPanDown(recognizer: UIPanGestureRecognizer) {
        let translateY = recognizer.translation(in: nil).y
        let velocityY = recognizer.velocity(in: nil).y

        switch recognizer.state {
        case .began:
            print("down began, dismissing")
            hero.dismissViewController()
            let progress = abs(translateY / view.bounds.height)
            Hero.shared.update(progress)
            Hero.shared.apply(modifiers: [.translate(y: translateY)], to: view)

        case .changed:
            print("down changed")
            let progress = abs(translateY / view.bounds.height)
            Hero.shared.update(progress)
            Hero.shared.apply(modifiers: [.translate(y: translateY)], to: view)
        default:
            print("default state -> \(recognizer.state.rawValue)")
            let progress = (translateY + velocityY) / view.bounds.height
            if (progress < 0) == (state == .slidingLeft) && abs(progress) > 0.3 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
            state = .normal
        }
    }

    @objc func didPan(recognizer: UIPanGestureRecognizer) {
        let translateX = recognizer.translation(in: nil).x
        let velocityX = recognizer.velocity(in: nil).x

        switch recognizer.state {
        case .began, .changed:
            let nextState: TransitionState
            if state == .normal {
                nextState = velocityX < 0 ? .slidingLeft : .slidingRight
            } else {
                nextState = translateX < 0 ? .slidingLeft : .slidingRight
            }

            guard let nextVC = nextState == .slidingLeft ? presenter?.getNextStory() : presenter?.getPrevStory() else {
                Hero.shared.cancel(animate: false)
                return
            }

            nextVC.hero.isEnabled = true

            if nextState != state {
                Hero.shared.cancel(animate: false)

                if nextState == .slidingLeft {
                    nextVC.hero.modalAnimationType = .selectBy(presenting: .slide(direction: .left), dismissing: .none)
                } else {
                    nextVC.hero.modalAnimationType = .selectBy(presenting: .slide(direction: .right), dismissing: .none)
                }
                state = nextState
                hero.replaceViewController(with: nextVC)
            } else {
                let progress = abs(translateX / view.bounds.width)
                Hero.shared.update(progress)
            }
        default:
            let progress = (translateX + velocityX) / view.bounds.width
            if (progress < 0) == (state == .slidingLeft) && abs(progress) > 0.3 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
            state = .normal
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent

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
        hero.dismissViewController()
    }

    func transitionNext(destinationVC: StoryViewController) {
        destinationVC.hero.isEnabled = true
        destinationVC.hero.modalAnimationType = .selectBy(presenting: .slide(direction: .left), dismissing: .none)

        hero.replaceViewController(with: destinationVC)
    }

    func transitionPrev(destinationVC: StoryViewController) {
        destinationVC.hero.isEnabled = true
        destinationVC.hero.modalAnimationType = .selectBy(presenting: .slide(direction: .right), dismissing: .none)
        hero.replaceViewController(with: destinationVC)
    }
}

extension StoryViewController: StoryViewProtocol {
    func animate(view: UIView & UIStoryViewProtocol) {
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

extension StoryViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = pan.translation(in: pan.view)
            let angle = atan2(translation.y, translation.x)
            return abs(angle - .pi / 2.0) < (.pi / 8.0)
        }
        return false
    }
}
