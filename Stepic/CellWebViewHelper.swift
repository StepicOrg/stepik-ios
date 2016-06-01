//
//  CellWebViewHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class CellWebViewHelper {
    
    private var webView : UIWebView
    private var heightWithoutWebView : Int
    
    init(webView: UIWebView, heightWithoutWebView: Int) {
        self.webView = webView
        self.heightWithoutWebView = heightWithoutWebView
        webView.opaque = false
        webView.backgroundColor = UIColor.clearColor()
        webView.userInteractionEnabled = false
        webView.scrollView.backgroundColor = UIColor.clearColor()
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.canCancelContentTouches = false
    }
    
    private func getContentHeight(webView : UIWebView) -> Int {
        return Int(webView.stringByEvaluatingJavaScriptFromString("document.body.scrollHeight;") ?? "0") ?? 0
    }
        
    //Method sets text and returns the method which returns current cell height according to the webview content height
    func setTextWithTeX(text: String, textColorHex : String = "#000000") -> (Void->Int) {
        let scriptsString = "\(Scripts.localTexScript)"
        let html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: text, addStyle: true, textColorHex: textColorHex)
        webView.loadHTMLString(html, baseURL: NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath))
        
        return {
            [weak self] in
            if let cw = self?.webView {
                if let h = self?.getContentHeight(cw),
                    noWebViewHeight = self?.heightWithoutWebView {
                    return h + noWebViewHeight
                }
            }
            return 0
        }        
    }

    
}