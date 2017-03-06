//
//  RGPageViewController+UICollectionViewDelegate.swift
//  RGPageViewController
//
//  Created by Ronny Gerasch on 23.01.17.
//  Copyright © 2017 Ronny Gerasch. All rights reserved.
//

import Foundation

// MARK: - UICollectionViewDelegate
extension RGPageViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if currentTabIndex != indexPath.row {
      selectTabAtIndex(indexPath.row, updatePage: true)
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if let tabView = cell.contentView.subviews.first as? RGTabView {
      if indexPath.row == currentTabIndex {
        tabView.selected = true
      } else {
        tabView.selected = false
      }
    }
  }
}
