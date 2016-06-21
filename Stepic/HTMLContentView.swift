//
//  HTMLContentView.swift
//  SmartContentView
//
//  Created by Alexander Karpov on 18.06.16.
//  Copyright © 2016 Stepic. All rights reserved.
//

import UIKit
import FLKAutoLayout
import WebKit
//import TTTAttributedLabel

/*
 A UIView subclass, which is responsible for intelligent displaying of HTML content
 */
class HTMLContentView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var textView: UITextView = UITextView()
    var webView: WKWebView = WKWebView()
    var webViewHeight : NSLayoutConstraint?
    var label: UILabel = UILabel()
    
    weak var interactionDelegate: HTMLContentViewInteractionDelegate?
    
    var htmlText : String? = nil {
        didSet(oldValue) {
            if oldValue != htmlText {
                if let t = htmlText {
                    loadHTMLText(t)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didLoad()
    }

    private func didLoad() {
//        setUpWebView()
//        setUpLabel()
    }
    
    private func setUpTextView() {
        textView.scrollEnabled = false
        textView.delegate = self
        textView.userInteractionEnabled = false
        
        addSubview(textView)
        textView.alignToView(self)
        textView.hidden = true
    }
    
    private func setUpLabel() {
        addSubview(label)
        label.alignTop("0", leading: "8", bottom: "0", trailing: "0", toView: self)
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(UILayoutPriority(250), forAxis: UILayoutConstraintAxis.Horizontal)
        webView.setContentHuggingPriority(UILayoutPriority(250), forAxis: UILayoutConstraintAxis.Vertical)
        label.hidden = true
    }
    
    private func setUpWebView() {
    
        let theConfiguration = WKWebViewConfiguration()
        let contentController = theConfiguration.userContentController
        contentController.addUserScript( WKUserScript(
            source: "window.onload=function () { window.webkit.messageHandlers.sizeNotification.postMessage({width: document.width, height: document.height});};",
            injectionTime: WKUserScriptInjectionTime.AtDocumentStart,
            forMainFrameOnly: false
        ))
//        contentController.addUserScript(WKUserScript(
//            source: "MathJax.Hub.Queue(function () { window.webkit.messageHandlers.mathJaxFinishedNotification.postMessage({width: document.width, height: document.height});};", 
//            injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, 
//            forMainFrameOnly: true
//            ))
        contentController.addScriptMessageHandler(self, name: "sizeNotification")
//        contentController.addScriptMessageHandler(self, name: "mathJaxFinishedNotification")

        self.webView = WKWebView(frame: CGRectZero, configuration: theConfiguration)

        webView.scrollView.scrollEnabled = false
        webView.backgroundColor = UIColor.clearColor()
        webView.scrollView.backgroundColor = UIColor.clearColor()
        webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        webView.navigationDelegate = self
        if webViewHeight == nil {
            webViewHeight = webView.constrainHeight("0")[0] as? NSLayoutConstraint
        }
        webViewHeight?.active = false
        webView.setContentCompressionResistancePriority(UILayoutPriority(250), forAxis: UILayoutConstraintAxis.Horizontal)
        webView.setContentHuggingPriority(UILayoutPriority(250), forAxis: UILayoutConstraintAxis.Vertical)
        addSubview(webView)
        webView.alignToView(self)
        webView.hidden = true
    }
    
    private func loadHTMLText(htmlString: String, styles: TextStyle? = nil) {
        if TagDetectionUtil.isWebViewSupportNeeded(htmlString) {
            setUpWebView()
            webViewHeight?.active = true
            loadWebView(htmlString)
            webView.hidden = false
        } else {
            setUpLabel()
            loadLabel(htmlString)
            label.hidden = false
//            setUpTextView()
//            loadTextView(htmlString)
//            textView.hidden = false
        }
    }
    
    private func loadTextView(htmlString: String) {
        let wrapped = HTMLStringWrapperUtil.wrap(htmlString)
        if let data = wrapped.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                [weak self] in
                do {
                    let attributedString = try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.textView.attributedText = attributedString
                        self?.interactionDelegate?.shouldUpdateSize()
                    })
                }
                catch {
                    //TODO: throw an exception here, or pass an error
                }
            })
        }
    }
    
    private func loadLabel(htmlString: String) {
        let wrapped = HTMLStringWrapperUtil.wrap(htmlString)
        if let data = wrapped.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: false) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                [weak self] in
                do {
                    let attributedString = try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil).attributedStringByTrimmingNewlines()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self?.label.attributedText = attributedString
                        self?.interactionDelegate?.shouldUpdateSize()
                    })
                }
                catch {
                    //TODO: throw an exception here, or pass an error
                }
            })
        }
    }
    
    private func loadWebView(htmlString: String) {
        let wrapped = HTMLStringWrapperUtil.wrap(htmlString)
        webView.loadHTMLString(wrapped, baseURL: NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath))
    }
}

extension HTMLContentView : WKNavigationDelegate {
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        
    }
}

extension HTMLContentView : UITextViewDelegate {
}

extension HTMLContentView : WKScriptMessageHandler {
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
//        print(message.name)
        if let height = message.body["height"] as? CGFloat {
            dispatch_async(dispatch_get_main_queue(), {
                [weak self] in
                self?.webViewHeight?.constant = height
                self?.setNeedsUpdateConstraints()
                self?.updateConstraintsIfNeeded()
                self?.setNeedsLayout()
                self?.layoutIfNeeded()
                self?.interactionDelegate?.shouldUpdateSize()
            })
        }
        
    }
}

struct TextStyle {
    
}