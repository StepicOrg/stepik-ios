//
//  CodeEditorSettingsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 11.04.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//
import UIKit
import ActionSheetPicker_3_0

class CodeEditorSettingsViewController: MenuViewController, CodeEditorSettingsView {
    var presenter: CodeEditorSettingsPresenter?
    var previewView: CodeEditorPreviewView!
    var previewLanguage = CodeLanguage.python

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []

        previewView = CodeEditorPreviewView()
        previewView.delegate = self
        tableView.tableHeaderView = previewView
        layoutTableHeaderView()

        presenter = CodeEditorSettingsPresenter(view: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewView.setupPreview(with: PreferencesContainer.codeEditor.theme, fontSize: PreferencesContainer.codeEditor.fontSize, language: previewLanguage)
    }

    func chooseEditorTheme(current: String) {
        guard let hl = previewView.highlightr,
              let currentThemeIndex = hl.availableThemes().index(of: current) else {
            return
        }

        ActionSheetStringPicker.show(withTitle: NSLocalizedString("CodeEditorTheme", comment: ""),
            rows: hl.availableThemes(),
            initialSelection: currentThemeIndex,
            doneBlock: { _, _, value in
                if let value = value as? String {
                    self.presenter?.updateTheme(with: value)
                }
            },
            cancel: { _ in },
            origin: previewView)
    }

    func chooseFontSize(current: Int) {
        let availableSizes = (10...23).map { Int($0) }

        guard let currentSizeIndex = availableSizes.index(of: current) else {
            return
        }

        ActionSheetStringPicker.show(withTitle: NSLocalizedString("CodeEditorFontSize", comment: ""),
            rows: availableSizes.map { "\($0)" },
            initialSelection: currentSizeIndex,
            doneBlock: { _, _, value in
                if let value = value as? String, let intValue = Int(value) {
                    self.presenter?.updateFontSize(with: intValue)
                }
            },
            cancel: { _ in },
            origin: previewView)
    }

    func updatePreview(theme: String) {
        previewView?.updateTheme(with: theme)
    }

    func updatePreview(fontSize: Int) {
        previewView?.updateFontSize(with: fontSize)
    }

    func setMenu(menu: Menu) {
        self.menu = menu
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        layoutTableHeaderView()
    }

    func layoutTableHeaderView() {
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        headerView.translatesAutoresizingMaskIntoConstraints = false

        let headerWidth = headerView.bounds.size.width
        let widthConstraint = headerView.widthAnchor.constraint(equalToConstant: headerWidth)
        widthConstraint.isActive = true

        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        var frame = headerView.frame
        frame.size.height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        headerView.frame = frame

        headerView.removeConstraint(widthConstraint)
        headerView.translatesAutoresizingMaskIntoConstraints = true
        tableView.tableHeaderView = headerView
    }
}

extension CodeEditorSettingsViewController: CodeEditorPreviewViewDelegate {
    func languageButtonDidClick() {
        let availableLanguages = Array(Set(CodeLanguage.allCases.map { $0.humanReadableName }))

        ActionSheetStringPicker.show(withTitle: NSLocalizedString("CodeEditorLanguage", comment: ""),
            rows: availableLanguages,
            initialSelection: availableLanguages.index(of: previewLanguage.humanReadableName)!,
            doneBlock: { _, _, value in
                if let value = value as? String {
                    self.previewLanguage = CodeLanguage.allCases.first(where: { $0.humanReadableName == value }) ?? self.previewLanguage
                    self.previewView.updateLanguage(with: self.previewLanguage)
                }
            },
            cancel: { _ in },
            origin: previewView.languageButton)
    }
}
