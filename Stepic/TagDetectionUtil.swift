//
//  TagDetectionUtil.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/*
 Utility class for detecting tags in html string
 */
class TagDetectionUtil {
    private init() {}
    
    static func isWebViewSupportNeeded(htmlString: String) -> Bool {
        return detectLaTeX(htmlString) || detectImage(htmlString) || detectCode(htmlString)
    }
    
    //POSSIBLY detects LaTeX in html string
    static func detectLaTeX(htmlString: String) -> Bool {
        return htmlString.characters.filter({$0 == "$"}).count >= 2
    }
    
    static func detectImage(htmlString: String) -> Bool {
        return  HTMLParsingUtil.getImageSrcLinks(htmlString).count > 0
    }
    
    static func detectCode(htmlString: String) -> Bool {
        return HTMLParsingUtil.getCodeStrings(htmlString).count > 0
    }
}