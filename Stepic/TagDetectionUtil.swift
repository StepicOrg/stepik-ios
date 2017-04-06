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
    fileprivate init() {}
    
    static func isWebViewSupportNeeded(_ htmlString: String) -> Bool {
        return detectLaTeX(htmlString) || detectImage(htmlString) || detectCode(htmlString)
    }
    
    //POSSIBLY detects LaTeX in html string
    static func detectLaTeX(_ htmlString: String) -> Bool {
        return htmlString.characters.filter({$0 == "$"}).count >= 2 || (htmlString.range(of: "\\[") != nil && htmlString.range(of: "\\]") != nil)
    }
    
    static func detectImage(_ htmlString: String) -> Bool {
        return  HTMLParsingUtil.getImageSrcLinks(htmlString).count > 0
    }
    
    static func detectCode(_ htmlString: String) -> Bool {
        return HTMLParsingUtil.getCodeStrings(htmlString).count > 0
    }
}
