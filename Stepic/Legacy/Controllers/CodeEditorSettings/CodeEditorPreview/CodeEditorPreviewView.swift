//
//  CodeEditorPreviewView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 11.04.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Highlightr
import UIKit

protocol CodeEditorPreviewViewDelegate: AnyObject {
    func languageButtonDidClick()
}

final class CodeEditorPreviewView: NibInitializableView {
    override var nibName: String { "CodeEditorPreviewView" }

    weak var delegate: CodeEditorPreviewViewDelegate?

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var previewContainer: UIView!
    var previewTextView: UITextView!

    var textStorage: CodeAttributedString?
    var highlightr: Highlightr? { self.textStorage?.highlightr }

    private var theme: String?
    private var fontSize: Int?
    private var language: CodeLanguage?

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    override func setupSubviews() {
        self.titleLabel.text = NSLocalizedString("PreviewTitle", comment: "")
        self.translatesAutoresizingMaskIntoConstraints = false
        self.colorize()
    }

    @IBAction
    func onLanguageButtonClick(_ sender: Any) {
        self.delegate?.languageButtonDidClick()
    }

    func setupPreview(with theme: String, fontSize: Int, language: CodeLanguage) {
        let textStorage = CodeAttributedString()
        self.textStorage = textStorage

        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: previewContainer.bounds.size)
        layoutManager.addTextContainer(textContainer)

        self.loadingIndicator.stopAnimating()

        self.previewTextView = UITextView(frame: previewContainer.frame, textContainer: textContainer)
        self.previewTextView.translatesAutoresizingMaskIntoConstraints = false
        self.previewTextView.roundAllCorners(radius: 5, borderWidth: 1.0, borderColor: .lightGray)
        self.previewTextView.isEditable = false
        self.previewTextView.isSelectable = false
        self.previewContainer.addSubview(previewTextView)
        self.previewTextView.snp.makeConstraints { $0.edges.equalTo(previewContainer) }

        self.updateTheme(with: theme)
        self.theme = theme

        self.updateFontSize(with: fontSize)
        self.fontSize = fontSize

        self.updateLanguage(with: language)
        self.language = language
    }

    func updateTheme(with newTheme: String) {
        guard let highlightr = self.highlightr else {
            return
        }

        guard highlightr.availableThemes().contains(newTheme) else {
            return
        }

        let savedFontSize = highlightr.theme.codeFont.pointSize
        highlightr.setTheme(to: newTheme)
        self.previewTextView.backgroundColor = highlightr.theme.themeBackgroundColor

        self.updateFontSize(with: Int(savedFontSize))
    }

    func updateFontSize(with fontSize: Int) {
        guard let hl = self.highlightr, let theme = hl.theme else {
            return
        }

        theme.setCodeFont(UIFont(name: "Courier", size: CGFloat(fontSize))!)
        hl.theme = theme
    }

    func updateLanguage(with language: CodeLanguage) {
        self.textStorage?.language = language.highlightr
        self.languageButton.setTitle(language.humanReadableName, for: .normal)
        self.previewTextView.text = language.highlightrSample

        guard let theme = self.theme else {
            return
        }

        self.updateTheme(with: theme)
    }

    private func colorize() {
        self.backgroundColor = .clear
        self.titleLabel.textColor = .stepikPrimaryText
        self.previewContainer.backgroundColor = .clear
        self.languageButton.setTitleColor(.stepikGreen, for: .normal)
        self.loadingIndicator.color = .stepikLoadingIndicator
    }
}
