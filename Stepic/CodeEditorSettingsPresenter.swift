//
// Created by jetbrains on 11/04/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//
import Foundation

protocol CodeEditorSettingsView: class {
    func setMenu(menu: Menu)

    func chooseEditorTheme(current: String)
    func chooseFontSize(current: Int)
}

class CodeEditorSettingsPresenter {
    weak var view: CodeEditorSettingsView?

    var themeBlock: TransitionMenuBlock?
    var fontSizeBlock: TransitionMenuBlock?
    var menu: Menu = Menu(blocks: [])

    init(view: CodeEditorSettingsView) {
        self.view = view
        self.menu = buildSettingsMenu()
        view.setMenu(menu: self.menu)
    }

    func updateTheme(with newTheme: String) {
        PreferencesContainer.codeEditor.theme = newTheme
        themeBlock?.subtitle = "Используется: \(newTheme)"
    }

    func updateFontSize(with newSize: Int) {
        PreferencesContainer.codeEditor.fontSize = newSize
        fontSizeBlock?.subtitle = "Используется: \(newSize)pt"
    }

    private func buildSettingsMenu() -> Menu {
        let blocks = [
            buildTitleMenuBlock(id: colorsHeaderBlockId, title: "Цвет"),
            buildThemeBlock(),
            buildTitleMenuBlock(id: colorsHeaderBlockId, title: "Шрифт"),
            buildFontSizeBlock()
        ]
        return Menu(blocks: blocks)
    }

    // MARK: - Menu blocks

    private let colorsHeaderBlockId = "colors_header"
    private let themeBlockId = "theme_block"
    private let fontsHeaderBlockId = "fonts_header"
    private let fontSizeBlockId = "font_size_block"

    private func buildTitleMenuBlock(id: String, title: String) -> HeaderMenuBlock {
        return HeaderMenuBlock(id: id, title: title)
    }

    private func buildThemeBlock() -> TransitionMenuBlock {
        themeBlock = TransitionMenuBlock(id: themeBlockId, title: "Тема редактора")
        themeBlock!.subtitle = "Используется: \(PreferencesContainer.codeEditor.theme)"

        themeBlock!.onTouch = {
            [weak self] in
            self?.view?.chooseEditorTheme(current: PreferencesContainer.codeEditor.theme)
        }

        return themeBlock!
    }

    private func buildFontSizeBlock() -> TransitionMenuBlock {
        fontSizeBlock = TransitionMenuBlock(id: themeBlockId, title: "Размер шрифта")
        fontSizeBlock!.subtitle = "Используется: \(PreferencesContainer.codeEditor.fontSize)pt"

        fontSizeBlock!.onTouch = {
            [weak self] in
            self?.view?.chooseFontSize(current: PreferencesContainer.codeEditor.fontSize)
        }

        return fontSizeBlock!
    }
}
