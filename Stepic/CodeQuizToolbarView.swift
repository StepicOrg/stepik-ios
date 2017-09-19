//
//  CodeQuizToolbarView.swift
//  Stepic
//
//  Created by Ostrenkiy on 22.06.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class CodeQuizToolbarView: NibInitializableView {

    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var languageButton: UIBarButtonItem!
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var fullscreenButton: UIBarButtonItem!

    weak var delegate: CodeQuizToolbarDelegate?

    var language: String = NSLocalizedString("Language", comment: "") {
        didSet {
            languageButton.title = language
        }
    }

    override var nibName: String {
        return "CodeQuizToolbarView"
    }

    override func setupSubviews() {
        languageButton.title = NSLocalizedString("Language", comment: "")
        resetButton.title = NSLocalizedString("Reset", comment: "")
        fullscreenButton.title = NSLocalizedString("Fullscreen", comment: "")
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
