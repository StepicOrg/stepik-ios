//
//  RGPageViewController+UIPageViewControllerDelegate.swift
//  RGPageViewController
//
//  Created by Ronny Gerasch on 23.01.17.
//  Copyright © 2017 Ronny Gerasch. All rights reserved.
//

import Foundation

// MARK: - UIPageViewControllerDelegate
extension RGPageViewController: UIPageViewControllerDelegate {
  public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if
      finished && completed,
      let viewController = pager.viewControllers?.first,
      let index = indexForViewController(viewController) {
      selectTabAtIndex(index, updatePage: false)
    }
  }
}
