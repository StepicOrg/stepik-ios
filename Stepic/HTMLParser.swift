//
//  HTMLParser.swift
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
class HTMLParser {
    var htmlText : String
    
    init(htmlText: String) {
        self.htmlText = htmlText
    }
    
    func getLink(index index: Int) -> String? {
        if let doc = Kanna.HTML(html: htmlText, encoding: NSUTF8StringEncoding) {
            if index < doc.xpath("//a").count {
                return doc.xpath("//a")[index]["href"]
            } else {
                return nil
            }
        }
        return nil
    }
}