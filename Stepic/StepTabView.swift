//
//  StepTabView.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.04.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

let StepDoneNotificationKey: String = "StepDoneNotificationKey"

class StepTabView: UIView {
    var view: UIView!
    
    @IBOutlet weak var stepIconImageView: UIImageView!
    
    @IBOutlet weak var solvedImageWidth: NSLayoutConstraint!
    @IBOutlet weak var solvedImageHeight: NSLayoutConstraint!
    
    let solvedViewHeight : CGFloat = 15
    
    func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        addSubview(view)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StepTabView.stepDone(_:)), name: StepDoneNotificationKey, object: nil)
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "StepTabView", bundle: bundle)
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
    
    var stepId: Int?
    
    convenience init(frame: CGRect, image: UIImage, stepId: Int, passed: Bool) {
        self.init(frame: frame)
        stepIconImageView.image = image
        self.stepId = stepId
        if passed {
            setTab(selected: passed, animated: false)
        }
    }
    
    func setTab(selected isSelected: Bool, animated: Bool) {
        let targetSize : CGFloat = isSelected ? solvedViewHeight : 0
        solvedImageHeight.constant = targetSize
        solvedImageWidth.constant = targetSize
        view.setNeedsLayout()
        if animated {
            UIView.animateWithDuration(0.25, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func stepDone(notification: NSNotification) {
        if let notificationStepId = notification.userInfo?["id"] as? Int,
            let stepId = self.stepId {
            if notificationStepId == stepId {
                setTab(selected: true, animated: true)
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: StepDoneNotificationKey, object: nil)
    }
}
