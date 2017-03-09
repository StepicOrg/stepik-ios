//
//  RGTabBarItem.swift
//  RGPageViewController
//
//  Created by Ronny Gerasch on 23.01.17.
//  Copyright © 2017 Ronny Gerasch. All rights reserved.
//

import UIKit

// MARK: - RGTabBarItem
open class RGTabBarItem: UIView {
  var selected: Bool = false {
    didSet {
      setSelectedState()
    }
  }
  var text: String?
  var image: UIImage?
  var textLabel: UILabel?
  var imageView: UIImageView?
  var normalColor: UIColor? = UIColor.gray
  
  public init(frame: CGRect, text: String?, image: UIImage?, color: UIColor?) {
    super.init(frame: frame)
    
    self.text = text
    self.image = image?.withRenderingMode(.alwaysTemplate)
    
    if color != nil {
      normalColor = color
    }
    
    initSelf()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    initSelf()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    initSelf()
  }
  
  func initSelf() {
    backgroundColor = UIColor.clear
    
    if let img = image {
      imageView = UIImageView(image: img)
      
      addSubview(imageView!)
      
      imageView!.tintColor = normalColor
      imageView!.center.x = center.x
      imageView!.center.y = center.y - 5.0
    }
    
    if let txt = text {
      textLabel = UILabel()
      
      textLabel!.numberOfLines = 1
      textLabel!.text = txt
      textLabel!.textAlignment = NSTextAlignment.center
      textLabel!.textColor = normalColor
      textLabel!.font = UIFont(name: "HelveticaNeue", size: 10)
      
      textLabel!.sizeToFit()
      
      textLabel!.frame = CGRect(x: 0.0, y: frame.size.height - textLabel!.frame.size.height - 3.0, width: frame.size.width, height: textLabel!.frame.size.height)
      
      addSubview(textLabel!)
    }
  }
  
  func setSelectedState() {
    if selected {
      textLabel?.textColor = tintColor
      imageView?.tintColor = tintColor
    } else {
      textLabel?.textColor = normalColor
      imageView?.tintColor = normalColor
    }
  }
}
