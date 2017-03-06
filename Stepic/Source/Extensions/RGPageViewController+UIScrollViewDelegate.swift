//
//  RGPageViewController+UIScrollViewDelegate.swift
//  RGPageViewController
//
//  Created by Ronny Gerasch on 23.01.17.
//  Copyright © 2017 Ronny Gerasch. All rights reserved.
//

import Foundation

// MARK: - UIScrollViewDelegate
extension RGPageViewController: UIScrollViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView == tabScrollView {
      return
    }
    
    pageViewScrollDelegate?.scrollViewDidScroll?(scrollView)
  }
  
  public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
    if scrollView == tabScrollView {
      return false
    }
    
    if let shouldScroll = pageViewScrollDelegate?.scrollViewShouldScrollToTop?(scrollView) {
      return shouldScroll
    }
    
    return false
  }
  
  public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
    if scrollView == tabScrollView {
      return
    }
    
    pageViewScrollDelegate?.scrollViewDidScrollToTop?(scrollView)
  }
  
  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    if scrollView == tabScrollView {
      return
    }
    
    pageViewScrollDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
  }
  
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    if scrollView == tabScrollView {
      return
    }
    
    pageViewScrollDelegate?.scrollViewWillBeginDragging?(scrollView)
  }
  
  public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if scrollView == tabScrollView {
      return
    }
    
    pageViewScrollDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
  }
  
  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if scrollView == tabScrollView {
      return
    }
    
    pageViewScrollDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
  }
  
  public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
    if scrollView == tabScrollView {
      return
    }
    
    pageViewScrollDelegate?.scrollViewWillBeginDecelerating?(scrollView)
  }
  
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    if scrollView == tabScrollView {
      return
    }
    
    pageViewScrollDelegate?.scrollViewDidEndDecelerating?(scrollView)
  }
  
  public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
    if scrollView == tabScrollView {
      return
    }
    
    pageViewScrollDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
  }
  
  public func scrollViewDidZoom(_ scrollView: UIScrollView) {
    if scrollView == tabScrollView {
      return
    }
    
    pageViewScrollDelegate?.scrollViewDidZoom?(scrollView)
  }
  
  public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    if scrollView == tabScrollView {
      return
    }
    
    pageViewScrollDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
  }
  
  public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    if scrollView == tabScrollView {
      return nil
    }
    
    if let view: UIView = pageViewScrollDelegate?.viewForZooming?(in: scrollView) {
      return view
    }
    
    return nil
  }
}
