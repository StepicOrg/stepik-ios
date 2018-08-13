//
//  OpenedStoriesPageViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class OpenedStoriesPageViewController: UIPageViewController, OpenedStoriesViewProtocol {
    var presenter: OpenedStoriesPresenterProtocol?

    var swipeInteractionController: SwipeInteractionController?

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        presenter?.refresh()

        swipeInteractionController = SwipeInteractionController(viewController: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        UIApplication.shared.statusBarStyle = .lightContent
    }

    func set(heroID: String) {
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
