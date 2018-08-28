//
//  InitializeWebViewCommand.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 14/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import WebKit

/// Initializes a webview at the start so webview startup later on isn't so slow.
struct InitializeWebViewCommand: Command {
    func execute() {
        _ = WKWebView()
    }
}
