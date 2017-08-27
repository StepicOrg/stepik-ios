//
//  CodeQuizToolbarView.swift
//  Stepic
//
//  Created by Ostrenkiy on 22.06.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class CodeQuizToolbarView: UIView {

    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var languageButton: UIBarButtonItem!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var fullscreenButton: UIBarButtonItem!

    weak var delegate: CodeQuizToolbarDelegate?

    fileprivate var view: UIView!

    var language: String = NSLocalizedString("Language", comment: "") {
        didSet {
            languageButton.title = language
        }
    }

    fileprivate func initialize() {
        languageButton.title = NSLocalizedString("Language", comment: "")
        resetButton.title = NSLocalizedString("Reset", comment: "")
        fullscreenButton.title = NSLocalizedString("Fullscreen", comment: "")
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

    @IBAction func languagePressed(_ sender: Any) {
        delegate?.changeLanguagePressed()
    }

    @IBAction func fullscreenPressed(_ sender: Any) {
        delegate?.fullscreenPressed()
    }

    @IBAction func resetPressed(_ sender: Any) {
        delegate?.resetPressed()
    }

}
