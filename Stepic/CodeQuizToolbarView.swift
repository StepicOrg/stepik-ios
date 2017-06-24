//
//  CodeQuizToolbarView.swift
//  Stepic
//
//  Created by Ostrenkiy on 22.06.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class CodeQuizToolbarView: UIView {
    
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var fullscreenButton: UIButton!
    
    var language: String = "Language" {
        didSet {
            languageButton.setTitle(language, for: .normal)
        }
    }
    
    weak var delegate : CodeQuizToolbarDelegate?
    
    fileprivate var view: UIView!
    
    fileprivate func initialize() {
        
    }
    
    fileprivate func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        initialize()
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CodeQuizToolbarView", bundle: bundle)
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
    
    @IBAction func languagePressed(_ sender: UIButton) {
        delegate?.changeLanguagePressed()
    }
    
    @IBAction func fullscreenPressed(_ sender: UIButton) {
        delegate?.fullscreenPressed()
    }
    
    
}
