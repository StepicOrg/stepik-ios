//
//  OpenedStoriesPageViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class OpenedStoriesPageViewController: UIPageViewController, OpenedStoriesViewProtocol {
    var presenter: OpenedStoriesPresenterProtocol?

    var swipeInteractionController: SwipeInteractionController?
    var startOffset: CGFloat = 0

    private var isDragging: Bool = false
    private var previousStatusBarStyle: UIStatusBarStyle?

    private weak var currentStoryController: UIViewController?

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.presenter?.refresh()

        let scrollView = self.view.subviews.filter { $0 is UIScrollView }.first as? UIScrollView
        scrollView?.delegate = self

        self.swipeInteractionController = SwipeInteractionController(viewController: self, onFinish: { [weak self] in
            self?.presenter?.onSwipeDismiss()
        })

        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.75)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        if let currentStatusBarStyle = SourcelessRouter().currentNavigation?.preferredStatusBarStyle {
            self.previousStatusBarStyle = currentStatusBarStyle
        }

        self.presenter?.setStatusBarStyle(.lightContent)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let previousStatusBarStyle = self.previousStatusBarStyle {
            self.presenter?.setStatusBarStyle(previousStatusBarStyle)
        }
    }

    func close() {
        self.dismiss(animated: true, completion: nil)
    }

    func set(module: UIViewController, direction: UIPageViewController.NavigationDirection, animated: Bool) {
        self.currentStoryController?.removeFromParent()
        self.currentStoryController = module

        self.addChild(module)
        self.setViewControllers([module], direction: direction, animated: animated, completion: nil)
    }
}

extension OpenedStoriesPageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        return self.presenter?.prevModule
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        return self.presenter?.nextModule
    }
}

extension OpenedStoriesPageViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.startOffset = scrollView.contentOffset.x
        self.isDragging = true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.isDragging else {
            return
        }

        var hasNextModule = true

        if self.startOffset < scrollView.contentOffset.x {
            hasNextModule = self.presenter?.nextModule != nil
        } else if self.startOffset > scrollView.contentOffset.x {
            hasNextModule = self.presenter?.prevModule != nil
        }

        let positionFromStartOfCurrentPage = abs(self.startOffset - scrollView.contentOffset.x)
        let percent = positionFromStartOfCurrentPage / self.view.frame.width

        let dismissThreshold: CGFloat = 0.2
        if percent > dismissThreshold && !hasNextModule {
            self.close()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isDragging = false
    }
}
