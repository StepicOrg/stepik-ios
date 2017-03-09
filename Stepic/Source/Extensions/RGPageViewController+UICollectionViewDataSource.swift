//
//  RGPageViewController+UICollectionViewDataSource.swift
//  RGPageViewController
//
//  Created by Ronny Gerasch on 23.01.17.
//  Copyright © 2017 Ronny Gerasch. All rights reserved.
//

import Foundation

// MARK: - UICollectionViewDataSource
extension RGPageViewController: UICollectionViewDataSource {
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return pageCount
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rgTabCell", for: indexPath)
    
    cell.tag = indexPath.row
    
    if let tabView = tabViewAtIndex(indexPath.row) {
      for view in cell.contentView.subviews {
        view.removeFromSuperview()
      }
      
      if indexPath.row == currentTabIndex {
        tabView.selected = true
      } else {
        tabView.selected = false
      }
      
      cell.contentView.addSubview(tabView)
    }
    
    return cell
  }
}
