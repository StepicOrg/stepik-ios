//
//  RGPageViewControllerDataSource.swift
//  RGPageViewController
//
//  Created by Ronny Gerasch on 23.01.17.
//  Copyright © 2017 Ronny Gerasch. All rights reserved.
//

import Foundation

// MARK: - RGPageViewControllerData Source
@objc public protocol RGPageViewControllerDataSource {
  /// Asks the dataSource about the number of page.
  ///
  /// - parameter pageViewController: the `RGPageViewController` instance.
  ///
  /// - returns: the total number of pages
  func numberOfPages(for pageViewController: RGPageViewController) -> Int
  
  /// Asks the dataSource for a view to display as a tab item.
  ///
  /// - parameter pageViewController: the `RGPageViewController` instance.
  /// - parameter index: the index of the tab whose view is asked.
  ///
  /// - returns: a `UIView` instance that will be shown as tab at the given index.
  func pageViewController(_ pageViewController: RGPageViewController, tabViewForPageAt index: Int) -> UIView
  
  /// Asks the datasource to give a ViewController to display as a page.
  ///
  /// - parameter pageViewController: the `RGPageViewController` instance.
  /// - parameter index: the index of the content whose ViewController is asked.
  ///
  /// - returns: a `UIViewController` instance whose view will be shown as content.
  func pageViewController(_ pageViewController: RGPageViewController, viewControllerForPageAt index: Int) -> UIViewController?
}
