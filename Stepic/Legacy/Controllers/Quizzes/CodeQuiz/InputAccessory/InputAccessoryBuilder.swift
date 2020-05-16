//
//  InputAccessoryBuilder.swift
//  Stepic
//
//  Created by Ostrenkiy on 08.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

final class InputAccessoryBuilder {
    static func buildAccessoryView(
        size: CodeInputAccessorySize,
        language: CodeLanguage,
        tabAction: @escaping () -> Void,
        insertStringAction: @escaping (String) -> Void,
        hideKeyboardAction: @escaping () -> Void
    ) -> UIView {
        let symbols = CodeSnippetSymbols.snippets(language: language)

        var buttons: [CodeInputAccessoryButtonData] = []

        let tabButton = CodeInputAccessoryButtonData(title: "Tab", action: {
            tabAction()
            StepikAnalytics.shared.send(.codeInputAccessoryButtonClicked(language: language.rawValue, symbol: "Tab"))
        })

        buttons += [tabButton]

        for symbol in symbols {
            let symButton = CodeInputAccessoryButtonData(title: symbol, action: {
                insertStringAction(symbol)
                StepikAnalytics.shared.send(
                    .codeInputAccessoryButtonClicked(language: language.rawValue, symbol: symbol)
                )
            })
            buttons += [symButton]
        }

        let viewSize = CGSize(width: UIScreen.main.bounds.size.width, height: size.realSizes.viewHeight)
        let frame = CGRect(origin: CGPoint.zero, size: viewSize)
        let accessoryView = CodeInputAccessoryView(frame: frame, buttons: buttons, size: size, hideKeyboardAction: {
            hideKeyboardAction()
            StepikAnalytics.shared.send(.codeInputAccessoryHideKeyboardClicked)
        })

        return accessoryView
    }
}
