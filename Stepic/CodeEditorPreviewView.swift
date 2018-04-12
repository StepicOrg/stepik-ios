//
//  CodeEditorPreviewView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 11.04.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import Highlightr
import FLKAutoLayout

class CodeEditorPreviewView: NibInitializableView {
    override var nibName: String {
        return "CodeEditorPreviewView"
    }

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var previewContainer: UIView!
    var previewTextView: UITextView!

    var highlightr: Highlightr?

    override func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    func setupPreview(with theme: String, fontSize: Int) {
        let textStorage = CodeAttributedString()
        textStorage.language = "Java"

        highlightr = textStorage.highlightr

        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: previewContainer.bounds.size)
        layoutManager.addTextContainer(textContainer)

        loadingIndicator.stopAnimating()

        previewTextView = UITextView(frame: previewContainer.frame, textContainer: textContainer)
        previewTextView.translatesAutoresizingMaskIntoConstraints = false
        previewTextView.setRoundedCorners(cornerRadius: 5, borderWidth: 1.0, borderColor: .lightGray)
        previewContainer.addSubview(previewTextView)
        previewTextView.align(toView: previewContainer)

        previewTextView.text = "/* Comment */"

        updateTheme(with: theme)
        updateFontSize(with: fontSize)
    }

    func updateTheme(with newTheme: String) {
        guard let highlightr = highlightr else {
            return
        }

        guard highlightr.availableThemes().contains(newTheme) else {
            return
        }

        let savedFontSize = highlightr.theme.codeFont.pointSize
        highlightr.setTheme(to: newTheme)
        previewTextView.backgroundColor = highlightr.theme.themeBackgroundColor

        if savedFontSize != nil {
            updateFontSize(with: Int(savedFontSize))
        }
    }

    func updateFontSize(with fontSize: Int) {
        guard let hl = highlightr, let theme = hl.theme else {
            return
        }

        theme.setCodeFont(UIFont(name: "Courier", size: CGFloat(fontSize))!)
        hl.theme = theme
    }
}
