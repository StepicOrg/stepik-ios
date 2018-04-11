//
// Created by jetbrains on 11/04/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//
import Foundation

protocol CodeEditorSettingsView: class {
    func setMenu(menu: Menu)
}

class CodeEditorSettingsPresenter {
    weak var view: CodeEditorSettingsView?
    var menu: Menu = Menu(blocks: [])

    init(view: CodeEditorSettingsView) {
        self.view = view
        self.menu = buildSettingsMenu()
        view.setMenu(menu: self.menu)
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
        let block = TransitionMenuBlock(id: themeBlockId, title: "Тема редактора")
        block.subtitle = "Используется: Androidstudio"

        block.onTouch = {
            [weak self] in
        }

        return block
    }

    private func buildFontSizeBlock() -> TransitionMenuBlock {
        let block = TransitionMenuBlock(id: themeBlockId, title: "Размер шрифта")
        block.subtitle = "Используется: 14pt"

        block.onTouch = {
            [weak self] in
        }

        return block
    }
}
