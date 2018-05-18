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

protocol CodeEditorPreviewViewDelegate: class {
    func languageButtonDidClick()
}

class CodeEditorPreviewView: NibInitializableView {
    override var nibName: String {
        return "CodeEditorPreviewView"
    }

    weak var delegate: CodeEditorPreviewViewDelegate?

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var previewContainer: UIView!
    var previewTextView: UITextView!

    var textStorage: CodeAttributedString?
    var highlightr: Highlightr? {
        return textStorage?.highlightr
    }

    private var theme: String?
    private var fontSize: Int?
    private var language: CodeLanguage?

    @IBAction func onLanguageButtonClick(_ sender: Any) {
        delegate?.languageButtonDidClick()
    }

    override func setupSubviews() {
        titleLabel.text = NSLocalizedString("PreviewTitle", comment: "")
        translatesAutoresizingMaskIntoConstraints = false
    }

    func setupPreview(with theme: String, fontSize: Int, language: CodeLanguage) {
        let textStorage = CodeAttributedString()
        self.textStorage = textStorage

        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: previewContainer.bounds.size)
        layoutManager.addTextContainer(textContainer)

        loadingIndicator.stopAnimating()

        previewTextView = UITextView(frame: previewContainer.frame, textContainer: textContainer)
        previewTextView.translatesAutoresizingMaskIntoConstraints = false
        previewTextView.setRoundedCorners(cornerRadius: 5, borderWidth: 1.0, borderColor: .lightGray)
        previewTextView.isEditable = false
        previewTextView.isSelectable = false
        previewContainer.addSubview(previewTextView)
        previewTextView.align(toView: previewContainer)

        updateTheme(with: theme)
        self.theme = theme

        updateFontSize(with: fontSize)
        self.fontSize = fontSize

        updateLanguage(with: language)
        self.language = language
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

        updateFontSize(with: Int(savedFontSize))
    }

    func updateFontSize(with fontSize: Int) {
        guard let hl = highlightr, let theme = hl.theme else {
            return
        }

        theme.setCodeFont(UIFont(name: "Courier", size: CGFloat(fontSize))!)
        hl.theme = theme
    }

    func updateLanguage(with language: CodeLanguage) {
        textStorage?.language = language.highlightr
        languageButton.setTitle(language.humanReadableName, for: .normal)
        previewTextView.text = language.highlightrSample

        guard let theme = self.theme else {
            return
        }
        updateTheme(with: theme)
    }
}
