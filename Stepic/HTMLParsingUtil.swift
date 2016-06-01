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
            if index < doc.xpath("//a").count {
                return doc.xpath("//a")[index]["href"]
            } else {
                return nil
            }
        }
        return nil
    }
    
    static func getImageSrcLinks(htmlString: String) -> [String] {
        if let doc = Kanna.HTML(html: htmlString, encoding: NSUTF8StringEncoding) {
            let imgNodes = doc.xpath("//img")
            return imgNodes.flatMap({return $0["src"]})
        } else {
            return []
        }
    }
    
    static func getCodeStrings(htmlString: String) -> [String] {
        if let doc = Kanna.HTML(html: htmlString, encoding: NSUTF8StringEncoding) {
            let codeNodes = doc.xpath("//code")
            return codeNodes.flatMap({return $0.text})
        } else {
            return []
        }
    }
}