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
    fileprivate init() {}

    static func getLink(_ htmlString: String, index: Int) -> String? {
//        if let doc = Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) {
//            if index < doc.css("a").count {
//                return doc.css("a")[index]["href"]
//            } else {
//                return nil
//            }
//        }
        let links = getAllLinksWithText(htmlString)
        if index < links.count {
            return links[index].link
        } else {
            return nil
        }
    }

    static func getAllLinksWithText(_ htmlString: String, onlyTags: Bool = true) -> [(link: String, text: String)] {
        var res = [(link: String, text: String)]()
        if let doc = Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) {
            res += doc.css("a").flatMap {
                if let link = $0["href"],
                    let text = $0.text {
                    return (link: link, text: text)
                } else {
                    return nil
                }
            }
        }

        if !onlyTags {
            let types: NSTextCheckingResult.CheckingType = .link
            let detector = try? NSDataDetector(types: types.rawValue)

            guard let detect = detector else {
                return res
            }

            let matches = detect.matches(in: htmlString, options: .reportCompletion, range: NSRange(location: 0, length: htmlString.characters.count))

            for match in matches {
                if let urlString = match.url?.absoluteString {
                    if res.index(where: {$0.link == urlString}) == nil {
                        res += [(link: urlString, text: urlString)]
                    }
                }
            }
        }

        return res
    }

    static func getAlliFrameLinks(_ htmlString: String) -> [String] {
        var res = [String]()
        if let doc = Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) {
            for element in doc.css("iframe") {
                if let link = element["src"] {
                    res += [link]
                }
            }
        }
        return res
    }

    static func getImageSrcLinks(_ htmlString: String) -> [String] {
        if let doc = Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) {
            let imgNodes = doc.css("img")
            return imgNodes.flatMap({return $0["src"]})
        } else {
            return []
        }
    }

    static func getCodeStrings(_ htmlString: String) -> [String] {
        if let doc = Kanna.HTML(html: htmlString, encoding: String.Encoding.utf8) {
            let codeNodes = doc.css("code")
            return codeNodes.flatMap({return $0.text})
        } else {
            return []
        }
    }
    
    static func getAllHTMLTags(_ htmlString: String) -> [String] {
        if let doc = Kanna.HTML(html: "<html><body>\(htmlString)</body></html>", encoding: String.Encoding.utf8) {
            let nodes = doc.css("*")
            // Drop 2 first tags: html, body
            let tags = Array(nodes.flatMap { $0.tagName }.dropFirst(2))
            return tags
        } else {
            return []
        }
    }
}
