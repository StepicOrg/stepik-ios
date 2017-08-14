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
//class HTMLContentView: UIView {
//
//    /*
//    // Only override drawRect: if you perform custom drawing.
//    // An empty implementation adversely affects performance during animation.
//    override func drawRect(rect: CGRect) {
//        // Drawing code
//    }
//    */
//    
//    var textView: UITextView? 
//    var webView: WKWebView? 
//    var webViewHeight : NSLayoutConstraint?
//    var label: UILabel?
//        
//    weak var interactionDelegate: HTMLContentViewInteractionDelegate?
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        didLoad()
//    }
//    
//    convenience init() {
//        self.init(frame: CGRect.zero)
//    }
//        
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        didLoad()
//    }
//
//    fileprivate func didLoad() {
//        setUpWebView()
//        setUpLabel()
//    }
//    
//    fileprivate func setUpTextView() {
//        textView = UITextView()
//        textView?.isScrollEnabled = false
//        textView?.delegate = self
//        textView?.isUserInteractionEnabled = false
//        
//        addSubview(textView!)
//        textView?.align(to: self)
//        textView?.isHidden = true
//    }
//    
//    fileprivate func setUpLabel() {
//        label = UILabel()
//        addSubview(label!)
//        label?.alignTop("0", leading: "8", bottom: "0", trailing: "0", to: self)
//        label?.numberOfLines = 0
////        label?.setContentCompressionResistancePriority(UILayoutPriority(250), forAxis: UILayoutConstraintAxis.Horizontal)
////        label?.setContentHuggingPriority(UILayoutPriority(250), forAxis: UILayoutConstraintAxis.Vertical)
//        label?.isHidden = true
//    }
//    
//    fileprivate func setUpWebView() {
//    
//        let theConfiguration = WKWebViewConfiguration()
//        let contentController = theConfiguration.userContentController
//        contentController.addUserScript( WKUserScript(
//            source: "window.onload=function () { window.webkit.messageHandlers.sizeNotification.postMessage({width: document.width, height: document.height});};",
//            injectionTime: WKUserScriptInjectionTime.atDocumentStart,
//            forMainFrameOnly: false
//        ))
//
//        contentController.add(self, name: "sizeNotification")
//
//        webView = WKWebView(frame: CGRect.zero, configuration: theConfiguration)
//
//        webView?.scrollView.isScrollEnabled = false
//        webView?.backgroundColor = UIColor.clear
//        webView?.scrollView.backgroundColor = UIColor.clear
//        webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        webView?.navigationDelegate = self
//        if webViewHeight == nil {
//            let heightConstraints = webView?.constrainHeight("0") 
//            print(heightConstraints)
//            webViewHeight = heightConstraints?[0] as? NSLayoutConstraint
//        }
//        webViewHeight?.priority = 750
//        webViewHeight?.isActive = false
////        webView?.setContentCompressionResistancePriority(UILayoutPriority(500), forAxis: UILayoutConstraintAxis.Horizontal)
////        webView?.setContentHuggingPriority(UILayoutPriority(250), forAxis: UILayoutConstraintAxis.Vertical)
//        addSubview(webView!)
//        webView?.align(to: self)
//        webView?.isHidden = true
//    }
//    
//    func activateLabel(_ htmlString: String) {
//        print("activating label")
//        webView?.isHidden = true
//        webViewHeight?.constant = 0
//        webViewHeight?.isActive = false
////        webView?.setContentCompressionResistancePriority(UILayoutPriority(250), forAxis: UILayoutConstraintAxis.Vertical)
////        webView?.setContentHuggingPriority(UILayoutPriority(250), forAxis: UILayoutConstraintAxis.Vertical)
////        label?.setContentCompressionResistancePriority(UILayoutPriority(500), forAxis: UILayoutConstraintAxis.Vertical)
////        label?.setContentHuggingPriority(UILayoutPriority(500), forAxis: UILayoutConstraintAxis.Vertical)
//        loadLabel(htmlString)
//        label?.isHidden = false
//        setNeedsUpdateConstraints()
//        updateConstraintsIfNeeded()
//        setNeedsLayout()
//        layoutIfNeeded()
//        print("aсtivated label")
//    }
//    
//    func activateWebView(_ htmlString: String) {
//        print("activating web view")
//        label?.isHidden = true
////        label?.setContentCompressionResistancePriority(UILayoutPriority(250), forAxis: UILayoutConstraintAxis.Vertical)
////        label?.setContentHuggingPriority(UILayoutPriority(250), forAxis: UILayoutConstraintAxis.Vertical)
////        webView?.setContentCompressionResistancePriority(UILayoutPriority(500), forAxis: UILayoutConstraintAxis.Vertical)
////        webView?.setContentHuggingPriority(UILayoutPriority(500), forAxis: UILayoutConstraintAxis.Vertical)
//        webViewHeight?.constant = 0
//        webViewHeight?.isActive = true
//        loadWebView(htmlString)
//        webView?.isHidden = false
//        setNeedsUpdateConstraints()
//        updateConstraintsIfNeeded()
//        setNeedsLayout()
//        layoutIfNeeded()
//        print("activated web view")
//    }
//    
//    func loadHTMLText(_ htmlString: String, styles: TextStyle? = nil) {
//        if TagDetectionUtil.isWebViewSupportNeeded(htmlString) {
//            activateWebView(htmlString)
//        } else {
//            activateLabel(htmlString)
//        }
//    }
//    
//    fileprivate func loadTextView(_ htmlString: String) {
//        let wrapped = HTMLStringWrapperUtil.wrap(htmlString)
//        if let data = wrapped.data(using: String.Encoding.unicode, allowLossyConversion: false) {
//            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
//                [weak self] in
//                do {
//                    let attributedString = try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil)
//                    
//                    DispatchQueue.main.async(execute: {
//                        self?.textView?.attributedText = attributedString
//                        self?.interactionDelegate?.shouldUpdateSize()
//                    })
//                }
//                catch {
//                    //TODO: throw an exception here, or pass an error
//                }
//            })
//        }
//    }
//    
//    fileprivate func loadLabel(_ htmlString: String) {
//        let wrapped = HTMLStringWrapperUtil.wrap(htmlString)
//        if let data = wrapped.data(using: String.Encoding.unicode, allowLossyConversion: false) {
//            do {
//                let attributedString = try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType], documentAttributes: nil).attributedStringByTrimmingNewlines()
//                self.label?.attributedText = attributedString
//            }
//            catch {
//                //TODO: throw an exception here, or pass an error
//            }
//        }
//    }
//    
//    fileprivate func loadWebView(_ htmlString: String) {
//        let wrapped = HTMLStringWrapperUtil.wrap(htmlString)
//        webView?.loadHTMLString(wrapped, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
//    }
//    
//    func prepareForReuse() {
//    }
//}
//
//extension HTMLContentView : WKNavigationDelegate {
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        
//    }
//}
//
//extension HTMLContentView : UITextViewDelegate {
//}
//
//extension HTMLContentView : WKScriptMessageHandler {
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
////        print(message.name)
//        if let height = message.body["height"] as? CGFloat {
//            DispatchQueue.main.async(execute: {
//                [weak self] in
//                self?.webViewHeight?.constant = height
//                self?.interactionDelegate?.shouldUpdateSize()
//            })
//        }
//        
//    }
//}
//
struct TextStyle {

}
