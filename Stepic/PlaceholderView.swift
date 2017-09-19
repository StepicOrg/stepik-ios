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

    fileprivate var bottomElement: UIView?

    fileprivate var middleView: UIView!
    fileprivate var middleViewHeight: NSLayoutConstraint!

    fileprivate var imageView: UIImageView?
    fileprivate var imageViewHeight: NSLayoutConstraint?
    fileprivate var imageViewWidth: NSLayoutConstraint?

    fileprivate var titleLabel: UILabel?
    fileprivate var titleLabelHeight: NSLayoutConstraint?

    fileprivate var descriptionLabel: UILabel?
    fileprivate var descriptionLabelHeight: NSLayoutConstraint?

    fileprivate var button: UIButton?
    fileprivate var buttonHeight: NSLayoutConstraint?

    fileprivate func addMiddleView() {
        middleView = UIView()
        self.addSubview(middleView)
        self.bringSubview(toFront: middleView)
        middleView.alignLeading("0", trailing: "0", toView: self)
        middleView.alignCenterY(withView: self, predicate: "0")
        middleViewHeight = middleView.constrainHeight("0")
        middleView.setContentCompressionResistancePriority(999, for: .vertical)
        setNeedsLayout()
        layoutIfNeeded()
    }

    fileprivate func setUpVerticalConstraints(_ view: UIView) {
        if let b = bottomElement {
            view.constrainTopSpace(toView: b, predicate: "16")
            middleViewHeight.constant += 16
        } else {
            view.alignTopEdge(withView: middleView, predicate: "0")
        }

        bottomElement = view
    }

    fileprivate func addImage(_ image: UIImage) {
        imageView = UIImageView(frame: CGRect.zero)
        middleView.addSubview(imageView!)
        middleView.bringSubview(toFront: imageView!)
        setUpVerticalConstraints(imageView!)
        imageView?.image = image
        imageViewHeight = imageView!.constrainHeight("\(image.size.height)")
        imageViewWidth = imageView!.constrainWidth("\(image.size.width)")
        _ = imageView?.alignCenterX(withView: middleView, predicate: "0")
    }

    fileprivate func addTitle(_ title: String) {
        titleLabel = UILabel(frame: CGRect.zero)
        titleLabel?.text = title
        titleLabel?.numberOfLines = 0

        middleView.addSubview(titleLabel!)
        middleView.bringSubview(toFront: titleLabel!)
        setUpVerticalConstraints(titleLabel!)
        _ = titleLabel?.alignLeading("8", trailing: "-8", toView: middleView)

        if let style = datasource?.placeholderStyle() {
            titleLabel?.implementStyle(style.title)
            titleLabelHeight = titleLabel?.constrainHeight("\(UILabel.heightForLabelWithText(title, style: style.title, width: middleView.bounds.width - 16))")
        } else {
            titleLabelHeight = titleLabel?.constrainHeight("30")
        }

        //TODO: Add title style implementation here
    }

    fileprivate func addDescription(_ desc: String) {
        descriptionLabel = UILabel(frame: CGRect.zero)
        descriptionLabel?.text = desc
        descriptionLabel?.numberOfLines = 0

        middleView.addSubview(descriptionLabel!)
        middleView.bringSubview(toFront: descriptionLabel!)
        setUpVerticalConstraints(descriptionLabel!)
        _ = descriptionLabel?.alignLeading("8", trailing: "-8", toView: middleView)

        if let style = datasource?.placeholderStyle() {
            descriptionLabel?.implementStyle(style.description)
            descriptionLabelHeight = descriptionLabel?.constrainHeight("\(UILabel.heightForLabelWithText(desc, style: style.description, width: middleView.bounds.width - 16))")
        } else {
            descriptionLabelHeight = descriptionLabel?.constrainHeight("30")
        }

        //TODO: Add description style implementation here
    }

    fileprivate func addButton(_ buttonTitle: String) {

        button = UIButton(type: .system)
        button?.frame = CGRect.zero
        button?.setTitle(buttonTitle, for: UIControlState())
        button?.addTarget(self, action: #selector(PlaceholderView.didPressButton), for: UIControlEvents.touchUpInside)

        if let style = datasource?.placeholderStyle() {
            if style.button.borderType != .none {
                button?.setTitle("  \(buttonTitle)  ", for: UIControlState())
            }
            button?.implementStyle(style.button)
        }

        middleView.addSubview(button!)
        middleView.bringSubview(toFront: button!)
        setUpVerticalConstraints(button!)
        _ = button?.alignCenterX(withView: middleView, predicate: "0")
        buttonHeight = button?.constrainHeight("30")
    }

    func didPressButton() {
        delegate?.placeholderButtonDidPress?()
    }

    fileprivate func update() {
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
        invalidateIntrinsicContentSize()
        print("middle view height -> \(middleView.bounds.height)")
        print("image view height -> \(String(describing: imageView?.bounds.height))")
    }

    fileprivate func setup() {
        let middleView = UIView()
        middleView.backgroundColor = UIColor.blue
        self.addSubview(middleView)
    }

    var delegate: PlaceholderViewDelegate? {
        didSet {
            update()
        }
    }
    var datasource: PlaceholderViewDataSource? {
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

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 250)
    }

}
