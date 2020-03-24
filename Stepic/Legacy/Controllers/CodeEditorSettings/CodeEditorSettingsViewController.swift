//
//  CodeEditorSettingsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 11.04.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import ActionSheetPicker_3_0
import UIKit

// MARK: CodeEditorSettingsLegacyAssembly: Assembly -

@available(*, deprecated, message: "Class to initialize code editor settings w/o storyboards logic")
final class CodeEditorSettingsLegacyAssembly: Assembly {
    private let previewLanguage: CodeLanguage

    init(previewLanguage: CodeLanguage = .python) {
        self.previewLanguage = previewLanguage
    }

    func makeModule() -> UIViewController {
        guard let viewController = ControllerHelper.instantiateViewController(
            identifier: "CodeEditorSettings",
            storyboardName: "Profile"
        ) as? CodeEditorSettingsViewController else {
            fatalError("Failed to initialize CodeEditorSettingsViewController")
        }

        let presenter = CodeEditorSettingsPresenter(view: viewController)
        viewController.presenter = presenter
        viewController.previewLanguage = self.previewLanguage

        return viewController
    }
}

// MARK: - CodeEditorSettingsViewController: MenuViewController -

final class CodeEditorSettingsViewController: MenuViewController {
    fileprivate var presenter: CodeEditorSettingsPresenter?
    fileprivate var previewLanguage = CodeLanguage.python

    private lazy var previewView: CodeEditorPreviewView = {
        let previewView = CodeEditorPreviewView()
        previewView.delegate = self
        return previewView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set default title if not provided.
        if self.navigationItem.title == nil && self.title == nil {
            self.title = NSLocalizedString("CodeEditorSettingsTitle", comment: "")
        }

        self.edgesForExtendedLayout = []
        self.tableView.tableHeaderView = self.previewView

        self.layoutTableHeaderView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // TODO: Add injection for theme.
        self.previewView.setupPreview(
            with: PreferencesContainer.codeEditor.theme,
            fontSize: PreferencesContainer.codeEditor.fontSize,
            language: self.previewLanguage
        )
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.layoutTableHeaderView()
    }

    private func layoutTableHeaderView() {
        guard let tableHeaderView = self.tableView.tableHeaderView else {
            return
        }

        tableHeaderView.translatesAutoresizingMaskIntoConstraints = false

        let headerWidth = tableHeaderView.bounds.size.width
        let widthConstraint = tableHeaderView.widthAnchor.constraint(equalToConstant: headerWidth)
        widthConstraint.isActive = true

        tableHeaderView.setNeedsLayout()
        tableHeaderView.layoutIfNeeded()

        var frame = tableHeaderView.frame
        frame.size.height = tableHeaderView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        tableHeaderView.frame = frame

        tableHeaderView.removeConstraint(widthConstraint)
        tableHeaderView.translatesAutoresizingMaskIntoConstraints = true
        self.tableView.tableHeaderView = tableHeaderView
    }
}

// MARK: - CodeEditorSettingsViewController: CodeEditorSettingsView -

extension CodeEditorSettingsViewController: CodeEditorSettingsView {
    func setMenu(menu: Menu) {
        self.menu = menu
    }

    func chooseEditorTheme(current: String) {
        guard let highlightr = self.previewView.highlightr,
              let currentThemeIndex = highlightr.availableThemes().firstIndex(of: current) else {
            return
        }

        ActionSheetStringPicker.show(
            withTitle: NSLocalizedString("CodeEditorTheme", comment: ""),
            rows: highlightr.availableThemes(),
            initialSelection: currentThemeIndex,
            doneBlock: { [weak self]  _, _, value in
                if let value = value as? String {
                    self?.presenter?.updateTheme(with: value)
                }
            },
            cancel: { _ in },
            origin: self.previewView
        )
    }

    func chooseFontSize(current: Int) {
        let availableSizes = (10...23).map { Int($0) }

        guard let currentSizeIndex = availableSizes.firstIndex(of: current) else {
            return
        }

        ActionSheetStringPicker.show(
            withTitle: NSLocalizedString("CodeEditorFontSize", comment: ""),
            rows: availableSizes.map { "\($0)" },
            initialSelection: currentSizeIndex,
            doneBlock: { [weak self] _, _, value in
                if let value = value as? String, let intValue = Int(value) {
                    self?.presenter?.updateFontSize(with: intValue)
                }
            },
            cancel: { _ in },
            origin: self.previewView
        )
    }

    func updatePreview(theme: String) {
        self.previewView.updateTheme(with: theme)
    }

    func updatePreview(fontSize: Int) {
        self.previewView.updateFontSize(with: fontSize)
    }
}

// MARK: - CodeEditorSettingsViewController: CodeEditorPreviewViewDelegate -

extension CodeEditorSettingsViewController: CodeEditorPreviewViewDelegate {
    func languageButtonDidClick() {
        let availableLanguages = Array(Set(CodeLanguage.allCases.map { $0.humanReadableName })).sorted()

        guard let currentLanguageIndex = availableLanguages.firstIndex(
            of: self.previewLanguage.humanReadableName
        ) else {
            return
        }

        ActionSheetStringPicker.show(
            withTitle: NSLocalizedString("CodeEditorLanguage", comment: ""),
            rows: availableLanguages,
            initialSelection: currentLanguageIndex,
            doneBlock: { [weak self] _, _, value in
                guard let strongSelf = self else {
                    return
                }

                if let value = value as? String {
                    let newPreviewLanguage = CodeLanguage.allCases.first(where: { $0.humanReadableName == value })
                    strongSelf.previewLanguage = newPreviewLanguage ?? strongSelf.previewLanguage
                    strongSelf.previewView.updateLanguage(with: strongSelf.previewLanguage)
                }
            },
            cancel: { _ in },
            origin: self.previewView.languageButton
        )
    }
}
