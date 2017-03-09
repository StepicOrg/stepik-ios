//
//  RGPageViewController+UIToolbarDelegate.swift
//  RGPageViewController
//
//  Created by Ronny Gerasch on 23.01.17.
//  Copyright © 2017 Ronny Gerasch. All rights reserved.
//

import Foundation

// MARK: - UIToolbarDelegate
extension RGPageViewController: UIToolbarDelegate {
  public func position(for bar: UIBarPositioning) -> UIBarPosition {
    switch tabbarPosition {
    case .top:
      return .top
    case .bottom:
      return .bottom
    default:
      return .any
    }
  }
}
