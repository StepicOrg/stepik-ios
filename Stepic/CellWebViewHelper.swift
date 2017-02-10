//
//  CellWebViewHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class CellWebViewHelper {
    
    fileprivate weak var webView : UIWebView?
    fileprivate var heightWithoutWebView : Int
    
    init(webView: UIWebView, heightWithoutWebView: Int) {
        self.webView = webView
        self.heightWithoutWebView = heightWithoutWebView
        self.webView?.isOpaque = false
        self.webView?.backgroundColor = UIColor.clear
        self.webView?.isUserInteractionEnabled = false
        self.webView?.scrollView.backgroundColor = UIColor.clear
        self.webView?.scrollView.showsVerticalScrollIndicator = false
        self.webView?.scrollView.canCancelContentTouches = false
    }
    
    fileprivate func getContentHeight(_ webView : UIWebView) -> Int {
        return Int(webView.stringByEvaluatingJavaScript(from: "document.body.scrollHeight;") ?? "0") ?? 0
    }
        
    //Method sets text and returns the method which returns current cell height according to the webview content height
    func setTextWithTeX(_ text: String, textColorHex : String = "#000000") -> ((Void)->Int) {
        let scriptsString = "\(Scripts.localTexScript)"
        let html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: text, addStyle: true, textColorHex: textColorHex)
        webView?.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        return {
            [weak self] in
            if let cw = self?.webView {
                if let h = self?.getContentHeight(cw),
                    let noWebViewHeight = self?.heightWithoutWebView {
                    return h + noWebViewHeight
                }
            }
            return 0
        }        
    }

    deinit {
        print("deinit cell helper")
    }
    
}
