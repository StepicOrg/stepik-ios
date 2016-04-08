//
//  PlaceholderView.swift
//  OstrenkiyPlaceholderView
//
//  Created by Alexander Karpov on 02.02.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class PlaceholderView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    
    private var bottomElement : UIView?
    
    private var middleView : UIView!
    private var middleViewHeight : NSLayoutConstraint!
    
    private var imageView : UIImageView?
    private var imageViewHeight : NSLayoutConstraint?
    private var imageViewWidth : NSLayoutConstraint?
    
    private var titleLabel : UILabel?
    private var titleLabelHeight : NSLayoutConstraint?
    
    private var descriptionLabel: UILabel?
    private var descriptionLabelHeight : NSLayoutConstraint?
    
    private var button: UIButton?
    private var buttonHeight : NSLayoutConstraint?
    
    private func addMiddleView() {
        middleView = UIView()
        self.addSubview(middleView)
        self.bringSubviewToFront(middleView)
        middleView.alignLeading("0", trailing: "0", toView: self)
        middleView.alignCenterYWithView(self, predicate: "0")
        middleViewHeight = middleView.constrainHeight("0")[0] as! NSLayoutConstraint
        middleView.setContentCompressionResistancePriority(999, forAxis: .Vertical)
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private func setUpVerticalConstraints(view: UIView) {
        if let b = bottomElement {
            view.constrainTopSpaceToView(b, predicate: "16")
            middleViewHeight.constant += 16
        } else {
            view.alignTopEdgeWithView(middleView, predicate: "0")
        }
        
        bottomElement = view
    }
    
    private func addImage(image: UIImage) {
        imageView = UIImageView(frame: CGRectZero)
        middleView.addSubview(imageView!)
        middleView.bringSubviewToFront(imageView!)
        setUpVerticalConstraints(imageView!)
        imageView?.image = image
        imageViewHeight = imageView!.constrainHeight("\(image.size.height)")[0] as? NSLayoutConstraint
        imageViewWidth = imageView!.constrainWidth("\(image.size.width)")[0] as? NSLayoutConstraint
        imageView?.alignCenterXWithView(middleView, predicate: "0")
    }
    
    private func addTitle(title: String) {
        titleLabel = UILabel(frame: CGRectZero)
        titleLabel?.text = title
        titleLabel?.numberOfLines = 0
        
        middleView.addSubview(titleLabel!)
        middleView.bringSubviewToFront(titleLabel!)
        setUpVerticalConstraints(titleLabel!)
        titleLabel?.alignLeading("8", trailing: "-8", toView: middleView)

        if let style = datasource?.placeholderStyle() {
            titleLabel?.implementStyle(style.title)
            titleLabelHeight = titleLabel?.constrainHeight("\(UILabel.heightForLabelWithText(title, style: style.title, width: middleView.bounds.width - 16))")[0] as? NSLayoutConstraint
        } else {
            titleLabelHeight = titleLabel?.constrainHeight("30")[0] as? NSLayoutConstraint
        }

        //TODO: Add title style implementation here
    }
    
    private func addDescription(desc: String) {
        descriptionLabel = UILabel(frame: CGRectZero)
        descriptionLabel?.text = desc
        descriptionLabel?.numberOfLines = 0
        
        middleView.addSubview(descriptionLabel!)
        middleView.bringSubviewToFront(descriptionLabel!)
        setUpVerticalConstraints(descriptionLabel!)
        descriptionLabel?.alignLeading("8", trailing: "-8", toView: middleView)
        

        if let style = datasource?.placeholderStyle() {
            descriptionLabel?.implementStyle(style.description)
            descriptionLabelHeight = descriptionLabel?.constrainHeight("\(UILabel.heightForLabelWithText(desc, style: style.description, width: middleView.bounds.width - 16))")[0] as? NSLayoutConstraint
        } else {
            descriptionLabelHeight = descriptionLabel?.constrainHeight("30")[0] as? NSLayoutConstraint
        }
        
        
        //TODO: Add description style implementation here
    }
        
    private func addButton(buttonTitle: String) {
        
        button = UIButton(type: .System)
        button?.frame = CGRectZero
        button?.setTitle(buttonTitle, forState: .Normal)
        button?.addTarget(self, action: #selector(PlaceholderView.didPressButton), forControlEvents: UIControlEvents.TouchUpInside)
        
        if let style = datasource?.placeholderStyle() {
            if style.button.borderType != .None {
                button?.setTitle("  \(buttonTitle)  ", forState: .Normal)
            }
            button?.implementStyle(style.button)
        }        
        
        middleView.addSubview(button!)
        middleView.bringSubviewToFront(button!)
        setUpVerticalConstraints(button!)
        button?.alignCenterXWithView(middleView, predicate: "0")
        buttonHeight = button?.constrainHeight("30")[0] as? NSLayoutConstraint
    }
    
    func didPressButton() {
        delegate?.placeholderButtonDidPress?()
    }
    
    private func update() {
        subviews.forEach({$0.removeFromSuperview()})
        if subviews.count != 0 {
            print("subviews count != 0")
        }
        removeConstraints(constraints)
        
        bottomElement = nil
                
        addMiddleView()
        
        if let image = datasource?.placeholderImage() {
            addImage(image)
            middleViewHeight.constant += imageViewHeight?.constant ?? 0
        } else {
            imageView = nil
        }
        
        if let title = datasource?.placeholderTitle() {
            addTitle(title)
            middleViewHeight.constant += titleLabelHeight?.constant ?? 0
        } else {
            titleLabel = nil
        }
        
        if let desc = datasource?.placeholderDescription() {
            addDescription(desc)
            middleViewHeight.constant += descriptionLabelHeight?.constant ?? 0
        } else {
            descriptionLabel = nil
        }
        
        if let btitle = datasource?.placeholderButtonTitle() {
            addButton(btitle)
            middleViewHeight.constant += buttonHeight?.constant ?? 0
        } else {
            button = nil
        }
        
//        if let b = bottomElement {
//            b.constrainBottomSpaceToView(middleView, predicate: "0")
//        } else {
//            print("No items in placeholder view")
//        }
        
        middleView.layoutSubviews()
        
        print("middle view height -> \(middleView.bounds.height)")
        print("middle view height -> \(middleView.bounds.height)")
        setNeedsLayout()
        layoutIfNeeded()
        middleView.layoutSubviews()
        print("middle view height -> \(middleView.bounds.height)")
        print("image view height -> \(imageView?.bounds.height)")
    }
    
    private func setup() {
        let middleView = UIView()
        middleView.backgroundColor = UIColor.blueColor()
        self.addSubview(middleView)
    }
    
    var delegate : PlaceholderViewDelegate? {
        didSet {
            update()
        }
    }
    var datasource : PlaceholderViewDataSource? {
        didSet {
            update()
        }
    }
    
    override func layoutIfNeeded() {
        print("middleView frame before -> \(middleView.frame)")
        super.layoutIfNeeded()
        print("middleView frame after -> \(middleView.frame)")
    }
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        setup()
    } 
    
    
}
