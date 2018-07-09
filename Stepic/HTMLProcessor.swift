//
//  HTMLProcessor.swift
//  Stepic
//
//  Created by Ostrenkiy on 09.07.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class HTMLProcessor {

    init() {}

    static let shared = HTMLProcessor()

    func process(htmlString: String, head: String = "", textColor: UIColor = UIColor.mainText) -> String {
        var res = "<html>\n"
        var head = head
        var body = htmlString

        head = "\(Scripts.metaViewport)\(Scripts.localTexScript)\(Scripts.clickableImagesScript)\(Scripts.textColorScript(textColor: textColor))\(Scripts.styles)" + head
        if body.contains("kotlin-runnable") {
            head += "\(Scripts.kotlinRunnableSamples)"
        }

        // Include library to customize audio controls
        if body.contains("<audio") {
            // Inject to head
            head = head + Scripts.audioTagWrapper
            // Inject before closing body tag
            body = body + Scripts.audioTagWrapperInit
        }

        res = "<html><head>\(head)</head><body>\(addStepikURLWhereNeeded(body: body))</body></html>"
        return res.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    func addStepikURLWhereNeeded(body: String) -> String {
        var body = body
        body = fixProtocolRelativeURLs(html: body)

        var links = HTMLParsingUtil.getAllLinksWithText(body).map({return $0.link})
        links += HTMLParsingUtil.getImageSrcLinks(body)
        var linkMap = [String: String]()

        for link in links {
            if link.first == Character("/") {
                linkMap[link] = "\(StepicApplicationsInfo.stepicURL)/\(link)"
            }
        }

        var newBody = body
        for (key, val) in linkMap {
            newBody = newBody.replacingOccurrences(of: "\"\(key)", with: "\"\(val)")
        }

        return newBody
    }

    func fixProtocolRelativeURLs(html: String) -> String {
        return html.replacingOccurrences(of: "src=\"//", with: "src=\"http://")
    }
}
