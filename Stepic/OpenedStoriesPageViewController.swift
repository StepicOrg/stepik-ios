//
//  OpenedStoriesPageViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Hero

class OpenedStoriesPageViewController: UIPageViewController, OpenedStoriesViewProtocol {
    var presenter: OpenedStoriesPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        presenter?.refresh()

        let downPanGR = UIPanGestureRecognizer(target: self, action: #selector(OpenedStoriesPageViewController.didPanDown(recognizer:)))
        view.addGestureRecognizer(downPanGR)
        downPanGR.cancelsTouchesInView = false
        downPanGR.delegate = self

    }

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
            if (progress < 0) && abs(progress) > 0.3 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.statusBarStyle = .lightContent
    }

    func set(heroID: String) {
        self.view.hero.id = heroID
    }

    func set(module: UIViewController) {
        addChildViewController(module)
        setViewControllers([module], direction: .forward, animated: false, completion: nil)
    }
}

extension OpenedStoriesPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return presenter?.prevModule
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return presenter?.nextModule
    }

}

extension OpenedStoriesPageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = pan.translation(in: pan.view)
            let angle = atan2(translation.y, translation.x)
            return abs(angle - .pi / 2.0) < (.pi / 8.0)
        }
        return false
    }
}
