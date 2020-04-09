//
//  OnboardingCardStepViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 25.01.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import WebKit

final class OnboardingCardStepViewController: CardStepViewController {
    var stepIndex: Int!
    weak var delegate: CardStepDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.stepWebView.navigationDelegate = self

        let step = self.loadOnboardingStep(from: "step\(self.stepIndex!)")

        let styles = """
<style>
    :root {
        color-scheme: light dark;
    }

    body {
        font: -apple-system-body;
        padding-top: 8px;
    }

    h4 {
        font: -apple-system-headline;
    }
</style>
"""
        // Add small top padding
        let processor = HTMLProcessor(html: step.text ?? "")
        let html = processor
            .injectDefault()
            .inject(script: .customHead(head: styles))
            .html

        self.stepWebView.loadHTMLString(html, baseURL: step.baseURL)
    }

    override func refreshWebView() {
        // Workaround for strange encoding bug
        // Skip refreshing for onboarding
        alignImages(in: self.stepWebView).then {
            self.getContentHeight(self.stepWebView)
        }.done { height in
            self.resetWebViewHeight(Float(height))
            self.scrollView.layoutIfNeeded()
        }.catch { _ in
            print("onboarding card step: error while refreshing")
        }
    }

    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        super.webView(webView, didFinish: navigation)
        self.delegate?.contentLoadingDidComplete()
    }

    // MARK: Private API

    private func loadOnboardingStep(from file: String) -> (text: String?, baseURL: URL?) {
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
