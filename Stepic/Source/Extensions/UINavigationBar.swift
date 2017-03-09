//
//  UINavigationBar.swift
//  RGPageViewController
//
//  Created by Ronny Gerasch on 23.01.17.
//  Copyright © 2017 Ronny Gerasch. All rights reserved.
//

import Foundation

// MARK: - UINavigationBar
extension UINavigationBar {
  func hideHairline() {
    if let hairlineView: UIImageView = findHairlineImageView(containedIn: self) {
      hairlineView.isHidden = true
    }
  }
  
  func showHairline() {
    if let hairlineView: UIImageView = findHairlineImageView(containedIn: self) {
      hairlineView.isHidden = false
    }
  }
  
  private func findHairlineImageView(containedIn view: UIView) -> UIImageView? {
    if view is UIImageView && view.bounds.size.height <= 1.0 {
      return view as? UIImageView
    }
    
    for subview in view.subviews {
      if let imageView: UIImageView = findHairlineImageView(containedIn: subview ) {
        return imageView
      }
    }
    
    return nil
  }
}
