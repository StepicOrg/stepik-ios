//
//  DiscussionCountView.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class DiscussionCountView: UIView {

    @IBOutlet weak var showCommentsLabel: UILabel!
    
    var commentsCount : Int = 0 {
        didSet {
            showCommentsLabel.text = "\(NSLocalizedString("ShowComments", comment: "")) (\(commentsCount))"
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBAction func showCommentsPressed(_ sender: AnyObject) {
        showCommentsHandler?()
    }
    
    var view: UIView!
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "DiscussionCountView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
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
    
    var showCommentsHandler: ((Void)->Void)?

}
