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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageButton: UIButton!
    @IBOutlet weak var previewContainer: UIView!
    var previewTextView: UITextView!

    override func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false

        let textStorage = CodeAttributedString()
        textStorage.language = "Java"

        textStorage.highlightr.setTheme(to: "Androidstudio")

        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(size: previewContainer.bounds.size)
        layoutManager.addTextContainer(textContainer)

        previewTextView = UITextView(frame: previewContainer.frame, textContainer: textContainer)
        previewTextView.translatesAutoresizingMaskIntoConstraints = false
        previewTextView.setRoundedCorners(cornerRadius: 5, borderWidth: 1.0, borderColor: .lightGray)
        previewContainer.addSubview(previewTextView)
        previewTextView.align(toView: previewContainer)

        previewTextView.backgroundColor = textStorage.highlightr.theme.themeBackgroundColor
        previewTextView.text = "/* Comment */"
    }
}
