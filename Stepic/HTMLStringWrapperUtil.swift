//
//  HTMLStringWrapperUtil.swift
//  SmartContentView
//
//  Created by Alexander Karpov on 18.06.16.
//  Copyright © 2016 Stepic. All rights reserved.
//

import Foundation

class HTMLStringWrapperUtil {
    static func wrap(htmlString: String, style: TextStyle? = nil) -> String {
        let scriptsString = "\(Scripts.metaViewport)\(Scripts.localTexScript)"
        var html = HTMLBuilder.sharedBuilder.buildCommentHTMLStringWith(head: scriptsString, body: htmlString)
        html = html.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        return html
    }
}