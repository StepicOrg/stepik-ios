//
//  CodeElementsSize.swift
//  Stepic
//
//  Created by Ostrenkiy on 18.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

enum CodeInputAccessorySize {
    case small
    case big
    
    typealias SizeParams = (textSize: CGFloat, viewHeight: CGFloat, minAccessoryWidth: CGFloat)
    
    var realSizes : SizeParams {
        switch self {
        case .small:
            return (textSize: 17, viewHeight: 50, minAccessoryWidth: 25)
        case .big:
            return (textSize: 21, viewHeight: 70, minAccessoryWidth: 35)
        }
    }
}

enum CodeSuggestionsSize {
    case small
    case big
    
    typealias SizeParams = (suggestionHeight: CGFloat, fontSize: CGFloat)
    
    var realSizes : SizeParams {
        switch self {
        case .small:
            return (suggestionHeight: 24, fontSize: 13)
        case .big:
            return (suggestionHeight: 32, fontSize: 17)
        }
    }
}

enum EditorSize {
    case small
    case big
    
    typealias SizeParams = (editorHeight: CGFloat, fontSize: CGFloat)
    
    var realSizes : SizeParams {
        switch self {
        case .small:
            return (editorHeight: 200, fontSize: 13)
        case .big:
            return (editorHeight: 400, fontSize: 17)
        }
    }
}

enum CodeQuizElementsSize {
    case small
    case big
    
    typealias SizeParams = (toolbar: CodeInputAccessorySize, suggestions: CodeSuggestionsSize, editor: EditorSize)
    var elements: SizeParams {
        switch self {
        case .small:
            return (toolbar: .small, suggestions: .small, editor: .small)
        case .big:
            return (toolbar: .big, suggestions: .big, editor: .big)
        }
    }
    
    
}
