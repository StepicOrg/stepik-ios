//
//  InputAccessoryBuilder.swift
//  Stepic
//
//  Created by Ostrenkiy on 08.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import RFKeyboardToolbar

class InputAccessoryBuilder {
    static func buildAccessoryView(language: CodeLanguage, tabAction: @escaping () -> (), insertStringAction: @escaping (String) -> ()) -> UIView {
        let symbols = CodeSnippetSymbols.snippets(language: language)
        
        var buttons : [RFToolbarButton] = []
        
        let tabButton = RFToolbarButton(title: "Tab", andEventHandler: { 
            tabAction()
            AnalyticsReporter.reportEvent(AnalyticsEvents.Code.toolbarSelected, parameters: ["language": language.rawValue, "symbol": "Tab"])
        }, for: UIControlEvents.touchUpInside)!
        
        buttons += [tabButton]
        
        for symbol in symbols {
            let symButton = RFToolbarButton(title: symbol, andEventHandler: {
                insertStringAction(symbol)
                AnalyticsReporter.reportEvent(AnalyticsEvents.Code.toolbarSelected, parameters: ["language": language.rawValue, "symbol": symbol])
            }, for: UIControlEvents.touchUpInside)!
            buttons += [symButton]
        }
         
        return RFKeyboardToolbar(buttons: buttons)
    }
    
    static func buildAccessoryView(language: CodeLanguage, tabAction: @escaping () -> (), insertStringAction: @escaping (String) -> (), hideKeyboardAction: @escaping () -> ()) -> UIView {
        let symbols = CodeSnippetSymbols.snippets(language: language)
        
        var buttons : [CodeInputAccessoryButtonData] = []
        
        let tabButton = CodeInputAccessoryButtonData(title: "Tab", action: {
            tabAction()
            AnalyticsReporter.reportEvent(AnalyticsEvents.Code.toolbarSelected, parameters: ["language": language.rawValue, "symbol": "Tab"])
        })
    
        buttons += [tabButton]
        
        for symbol in symbols {
            let symButton = CodeInputAccessoryButtonData(title: symbol, action: {
                insertStringAction(symbol)
                AnalyticsReporter.reportEvent(AnalyticsEvents.Code.toolbarSelected, parameters: ["language": language.rawValue, "symbol": symbol])
            })
            buttons += [symButton]
        }
        
        let size : CodeInputAccessorySize = DeviceInfo.isIPad() ? .big : .small
        let viewSize = CGSize(width: UIScreen.main.bounds.size.width, height: size.realSizes.viewHeight)
        let frame = CGRect(origin: CGPoint.zero, size: viewSize)
        let accessoryView = CodeInputAccessoryView(frame: frame, buttons: buttons, size: DeviceInfo.isIPad() ? .big : .small, hideKeyboardAction: hideKeyboardAction)
        accessoryView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        accessoryView.invalidateIntrinsicContentSize()
        accessoryView.size = DeviceInfo.isIPad() ? .big : .small
        accessoryView.invalidateIntrinsicContentSize()
        accessoryView.collectionView.reloadData()
        accessoryView.setNeedsLayout()
        accessoryView.layoutIfNeeded()
        return accessoryView
    }

}
