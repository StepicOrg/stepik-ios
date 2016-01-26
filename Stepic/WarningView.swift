//
//  WarningView.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class WarningView: UIView {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var centerView: UIView!
    @IBOutlet weak var tryAgainButton: UIButton!
    
    var view: UIView!
    var textLabel : UILabel!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "WarningView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
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
    
    var delegate : WarningViewDelegate?
    
    convenience init(frame: CGRect, delegate: WarningViewDelegate, text: String, image: UIImage, width: CGFloat, fontSize: CGFloat = 14) {
        self.init(frame: frame)
        //TODO: Localize try again button
        self.delegate = delegate
        self.imageView.image = image
        textLabel = UILabel()
        self.view.insertSubview(textLabel, belowSubview: tryAgainButton)
        textLabel.text = text
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.numberOfLines = 0
        textLabel.font = UIFont.systemFontOfSize(14)
        textLabel.alignLeading("8", trailing: "8", toView: view)
        textLabel.constrainTopSpaceToView(centerView, predicate: "4")
        let height = UILabel.heightForLabelWithText(text, lines: 0, standardFontOfSize: fontSize, width: width - 16) + 14
        textLabel.constrainHeight("\(height)")
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    @IBAction func didPressButton(sender: AnyObject) {
        delegate?.didPressButton()
    }

}

protocol WarningViewDelegate {
    func didPressButton()
}
