//
//  RGPageViewControllerDelegate.swift
//  RGPageViewController
//
//  Created by Ronny Gerasch on 23.01.17.
//  Copyright © 2017 Ronny Gerasch. All rights reserved.
//

import Foundation

// MARK: - RGPageViewControllerDelegate
@objc public protocol RGPageViewControllerDelegate {
  /// Delegate objects can implement this method if want to be informed when a page is about to become visible.
  ///
  /// - parameter pageViewController: the `RGPageViewController` instance.
  /// - parameter index: the index of the next page.
  /// - parameter from: the index of the current page.
  @objc optional func pageViewController(_ pageViewController: RGPageViewController, willChangePageTo index: Int, fromIndex from: Int)

  /// Delegate objects can implement this method if want to be informed when a page became visible.
  ///
  /// - parameter pageViewController: the `RGPageViewController` instance.
  /// - parameter index: the index of the current page.
  @objc optional func pageViewController(_ pageViewController: RGPageViewController, didChangePageTo index: Int)

  /// Delegate objects can implement this method if tabs use dynamic width or to overwrite the default width for tabs.
  ///
  /// - parameter pageViewController: the `RGPageViewController` instance.
  /// - parameter index: the index of the tab.
  ///
  /// - returns: the width for the tab at the given index.
  @objc optional func pageViewController(_ pageViewController: RGPageViewController, widthForTabAt index: Int) -> CGFloat

  /// Delegate objects can implement this method if tabs use dynamic height or to overwrite the default height for tabs.
  ///
  /// - parameter pageViewController: the `RGPageViewController` instance.
  /// - parameter index: the index of the tab.
  ///
  /// - returns: the height for the tab at the given index.
  @objc optional func pageViewController(_ pageViewController: RGPageViewController, heightForTabAt index: Int) -> CGFloat
}
