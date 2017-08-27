//
//  RGPageViewController+UIPageViewControllerDataSource.swift
//  RGPageViewController
//
//  Created by Ronny Gerasch on 23.01.17.
//  Copyright © 2017 Ronny Gerasch. All rights reserved.
//

import Foundation

// MARK: - UIPageViewControllerDataSource
extension RGPageViewController: UIPageViewControllerDataSource {
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard var index = indexForViewController(viewController), index > 0 else {
      return nil
    }

    index -= 1

    return viewControllerAtIndex(index)
  }

  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard var index = indexForViewController(viewController), index < pageCount - 1 else {
      return nil
    }

    index += 1

    return viewControllerAtIndex(index)
  }

  internal func viewControllerAtIndex(_ index: Int) -> UIViewController? {
    if index >= pageCount {
      return nil
    }

    if pageViewControllers[index] == nil, let viewController = datasource?.pageViewController(self, viewControllerForPageAt: index) {
      if let scrollView = viewController.view.subviews.first as? UIScrollView {
        var edgeInsets: UIEdgeInsets = scrollView.contentInset

        if tabbarPosition == .top {
          edgeInsets.top = topLayoutGuide.length + tabbarHeight
        } else if tabbarPosition == .bottom {
          edgeInsets.top = topLayoutGuide.length
          edgeInsets.bottom = tabbarHeight
        } else {
          edgeInsets.top = topLayoutGuide.length
          edgeInsets.bottom = 0
        }

        scrollView.contentInset = edgeInsets
        scrollView.scrollIndicatorInsets = edgeInsets
      }

      pageViewControllers[index] = viewController
    }

    return pageViewControllers[index]
  }
}
