//
//  HTMLParsingUtil.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Kanna

/*
 Parses an HTML, allowing to get all the needed information from HTML string
 */
class HTMLParsingUtil {
    private init() {}
    
    static func getLink(htmlString: String, index: Int) -> String? {
        if let doc = Kanna.HTML(html: htmlString, encoding: NSUTF8StringEncoding) {
            if index < doc.css("a").count {
                return doc.css("a")[index]["href"]
            } else {
                return nil
            }
        }
        return nil
    }
    
    static func getAllLinksWithText(htmlString: String, onlyTags: Bool = true) -> [(link: String, text: String)] {
        var res = [(link: String, text: String)]()
        if let doc = Kanna.HTML(html: htmlString, encoding: NSUTF8StringEncoding) {
            res += doc.css("a").flatMap{
                if let link = $0["href"],
                    let text = $0.text {
                    return (link: link, text: text)
                } else {
                    return nil
                }
            }
        }
        
        if !onlyTags {
            let types: NSTextCheckingType = .Link
            let detector = try? NSDataDetector(types: types.rawValue)
            
            guard let detect = detector else {
                return res
            }
            
            let matches = detect.matchesInString(htmlString, options: .ReportCompletion, range: NSMakeRange(0, htmlString.characters.count))
            
            for match in matches {
                if let urlString = match.URL?.absoluteString {
                    if res.indexOf({$0.link == urlString}) == nil {
                        res += [(link: urlString, text: urlString)]
                    }
                }
            }
        }
        
        return res
    }
    
    static func getImageSrcLinks(htmlString: String) -> [String] {
        if let doc = Kanna.HTML(html: htmlString, encoding: NSUTF8StringEncoding) {
            let imgNodes = doc.css("img")
            return imgNodes.flatMap({return $0["src"]})
        } else {
            return []
        }
    }
    
    static func getCodeStrings(htmlString: String) -> [String] {
        if let doc = Kanna.HTML(html: htmlString, encoding: NSUTF8StringEncoding) {
            let codeNodes = doc.css("code")
            return codeNodes.flatMap({return $0.text})
        } else {
            return []
        }
    }
}