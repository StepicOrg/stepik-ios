//
//  CodeEditorSettingsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 11.04.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//
import Foundation

protocol CodeEditorSettingsView: AnyObject {
    func setMenu(menu: Menu)

    func chooseEditorTheme(current: String)
    func chooseFontSize(current: Int)

    func updatePreview(theme: String)
    func updatePreview(fontSize: Int)
}

final class CodeEditorSettingsPresenter {
    weak var view: CodeEditorSettingsView?

    private let codeEditorThemeService: CodeEditorThemeServiceProtocol

    var themeBlock: TransitionMenuBlock?
    var fontSizeBlock: TransitionMenuBlock?
    var menu = Menu(blocks: [])

    init(
        view: CodeEditorSettingsView,
        codeEditorThemeService: CodeEditorThemeServiceProtocol
    ) {
        self.view = view
        self.codeEditorThemeService = codeEditorThemeService
        self.menu = buildSettingsMenu()
        view.setMenu(menu: self.menu)
    }

    func updateTheme(with newTheme: String) {
        self.codeEditorThemeService.update(name: newTheme)
        themeBlock?.subtitle = String(format: NSLocalizedString("CodeEditorCurrentTheme", comment: ""), newTheme)
        view?.updatePreview(theme: newTheme)

        NotificationCenter.default.post(name: .codeEditorThemeDidChange, object: nil)
    }

    func updateFontSize(with newSize: Int) {
        PreferencesContainer.codeEditor.fontSize = newSize
        fontSizeBlock?.subtitle = String(format: NSLocalizedString("CodeEditorCurrentFontSize", comment: ""), "\(newSize)")
        view?.updatePreview(fontSize: newSize)

        NotificationCenter.default.post(name: .codeEditorThemeDidChange, object: nil)
    }

    private func buildSettingsMenu() -> Menu {
        let blocks = [
            buildTitleMenuBlock(id: colorsHeaderBlockId, title: NSLocalizedString("CodeEditorColor", comment: "")),
            buildThemeBlock(),
            buildTitleMenuBlock(id: colorsHeaderBlockId, title: NSLocalizedString("CodeEditorFont", comment: "")),
            buildFontSizeBlock()
        ]
        return Menu(blocks: blocks)
    }

    // MARK: - Menu blocks

    private let colorsHeaderBlockId = "colors_header"
    private let themeBlockId = "theme_block"
    private let fontsHeaderBlockId = "fonts_header"
    private let fontSizeBlockId = "font_size_block"

    private func buildTitleMenuBlock(id: String, title: String) -> HeaderMenuBlock { .init(id: id, title: title) }

    private func buildThemeBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(
            id: themeBlockId,
            title: NSLocalizedString("CodeEditorTheme", comment: "")
        )
        block.subtitle = String(
            format: NSLocalizedString("CodeEditorCurrentTheme", comment: ""),
            self.codeEditorThemeService.theme.name
        )
        block.onTouch = { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.view?.chooseEditorTheme(current: strongSelf.codeEditorThemeService.theme.name)
        }

        self.themeBlock = block

        return block
    }

    private func buildFontSizeBlock() -> TransitionMenuBlock {
        fontSizeBlock = TransitionMenuBlock(id: themeBlockId, title: NSLocalizedString("CodeEditorFontSize", comment: ""))
        fontSizeBlock!.subtitle = String(format: NSLocalizedString("CodeEditorCurrentFontSize", comment: ""), "\(PreferencesContainer.codeEditor.fontSize)")

        fontSizeBlock!.onTouch = {
            [weak self] in
            self?.view?.chooseFontSize(current: PreferencesContainer.codeEditor.fontSize)
        }

        return fontSizeBlock!
    }
}

extension NSNotification.Name {
    static let codeEditorThemeDidChange = NSNotification.Name("codeEditorThemeDidChange")
}
