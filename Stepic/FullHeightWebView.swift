//
//  FullHeightWebView.swift
//  Stepic
//
//  Created by Ostrenkiy on 28.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import PromiseKit
import UIKit
import WebKit

final class FullHeightWebView: WKWebView {
    private static var webViewConfiguration: WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.dataDetectorTypes = [.link]
        return configuration
    }

    private(set) var currentContentHeight: CGFloat = 0

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: self.currentContentHeight)
    }

    init() {
        super.init(frame: .zero, configuration: Self.webViewConfiguration)
    }

    required init?(coder: NSCoder) {
        super.init(frame: UIScreen.main.bounds, configuration: Self.webViewConfiguration)
        // Apply constraints from interface builder
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    func getContentHeight() -> Guarantee<CGFloat> {
        Guarantee { seal in
            self.evaluateJavaScript("document.body.scrollHeight;") { [weak self] res, _ in
                if let height = res as? CGFloat {
                    self?.currentContentHeight = height
                    seal(height)
                } else {
                    seal(0)
                }
            }
        }
    }
}
