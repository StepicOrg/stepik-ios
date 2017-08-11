//
//  RGTabView.swift
//  RGPageViewController
//
//  Created by Ronny Gerasch on 23.01.17.
//  Copyright © 2017 Ronny Gerasch. All rights reserved.
//

import UIKit

enum RGTabOrientation {
  case horizontalTop
  case horizontalBottom
  case verticalLeft
  case verticalRight
}

// MARK: - RGTabView
class RGTabView: UIView {
  // variables
  var selected: Bool = false {
    didSet {
      if subviews[0] is RGTabBarItem {
        (subviews[0] as! RGTabBarItem).selected = selected
      } else {
        if style == .inactiveFaded {
          if selected {
            alpha = 1.0
          } else {
            alpha = 0.566
          }
        }

        setNeedsDisplay()
      }
    }
  }
  var indicatorHW: CGFloat = 2
  var indicatorColor: UIColor = UIColor.lightGray
  var orientation: RGTabOrientation = .horizontalTop
  var style: RGTabStyle = .none

  init(frame: CGRect, indicatorColor: UIColor, indicatorHW: CGFloat, style: RGTabStyle, orientation: RGTabOrientation) {
    super.init(frame: frame)

    self.indicatorColor = indicatorColor
    self.orientation = orientation
    self.indicatorHW = indicatorHW
    self.style = style

    initSelf()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    initSelf()
  }

  func initSelf() {
    backgroundColor = UIColor.clear

    if style == .inactiveFaded {
      alpha = 0.566
    }
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)

    if !(subviews[0] is RGTabBarItem) {
      let bezierPath: UIBezierPath = UIBezierPath()

      switch orientation {
      case .horizontalTop:
        bezierPath.move(to: CGPoint(x: 0, y: rect.height - indicatorHW / 2))
        bezierPath.addLine(to: CGPoint(x: rect.width, y: rect.height - indicatorHW / 2))
        bezierPath.lineWidth = indicatorHW
      case .horizontalBottom:
        bezierPath.move(to: CGPoint(x: 0, y: indicatorHW / 2))
        bezierPath.addLine(to: CGPoint(x: rect.width, y: indicatorHW / 2))
        bezierPath.lineWidth = indicatorHW
      case .verticalLeft:
        bezierPath.move(to: CGPoint(x: indicatorHW / 2, y: 0))
        bezierPath.addLine(to: CGPoint(x: indicatorHW / 2, y: rect.height))
        bezierPath.lineWidth = indicatorHW
      case .verticalRight:
        bezierPath.move(to: CGPoint(x: rect.width - (indicatorHW / 2), y: 0))
        bezierPath.addLine(to: CGPoint(x: rect.width - (indicatorHW / 2), y: rect.height))
        bezierPath.lineWidth = indicatorHW
      }

      if selected {
        indicatorColor.setStroke()
      } else {
        UIColor(white: 0, alpha: 0).setStroke()
      }

      bezierPath.stroke()
    }
  }
}
