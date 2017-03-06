//
//  RGPageViewController+UICollectionViewDelegateFlowLayout.swift
//  RGPageViewController
//
//  Created by Ronny Gerasch on 23.01.17.
//  Copyright © 2017 Ronny Gerasch. All rights reserved.
//

import Foundation

// MARK: - UICollectionViewDelegateFlowLayout
extension RGPageViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    switch tabbarPosition {
    case .top, .bottom:
      if let theWidth = delegate?.pageViewController?(self, widthForTabAt: indexPath.row) {
        return CGSize(width: theWidth, height: tabbarHeight)
      } else {
        return CGSize(width: tabWidth, height: tabbarHeight)
      }
    case .left, .right:
      if let theHeight = delegate?.pageViewController?(self, heightForTabAt: indexPath.row) {
        return CGSize(width: tabbarWidth, height: theHeight)
      } else {
        return CGSize(width: tabbarWidth, height: tabbarWidth)
      }
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return tabMargin
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return tabMargin
  }
  
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    switch tabbarPosition {
    case .top, .bottom:
      return UIEdgeInsets(top: 0, left: tabMargin / 2, bottom: 0, right: tabMargin / 2)
    case .left, .right:
      return UIEdgeInsets(top: tabMargin / 2, left: 0, bottom: tabMargin / 2, right: 0)
    }
  }
}
