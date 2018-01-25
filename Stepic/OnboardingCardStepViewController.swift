//
//  OnboardingCardStepViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 25.01.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import WebKit
import FLKAutoLayout

class OnboardingCardStepViewController: CardStepViewController {

    var stepIndex: Int!
    weak var delegate: CardStepDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        stepWebView.navigationDelegate = self

        let step = loadOnboardingStep(from: "step\(stepIndex!)")

        // Add small top padding
        var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: "<style>\nbody{padding-top: 8px;}</style>\n", body: step.text ?? "", width: Int(UIScreen.main.bounds.width))
        html = html.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        stepWebView.loadHTMLString(html, baseURL: step.baseURL)
    }

    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        super.webView(webView, didFinish: navigation)
        delegate?.contentLoadingDidComplete()
    }

    fileprivate func loadOnboardingStep(from file: String) -> (text: String?, baseURL: URL?) {
        guard let filePath = Bundle.main.path(forResource: file, ofType: "html") else {
            return (text: nil, baseURL: nil)
        }

        do {
            let contents = try String(contentsOfFile: filePath, encoding: .utf8)
            let baseUrl = URL(fileURLWithPath: filePath)
            return (text: contents, baseURL: baseUrl)
        } catch {
            return (text: nil, baseURL: nil)
        }
    }
}
