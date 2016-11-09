//
//  WebViewHorizontalScrollHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 25.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

/**
 Helper class for making horizontal scroll in a WebView with a hierarchy like this:
    PageView
        |   
        ScrollView
            |   
            WebView
 */
class WebViewHorizontalScrollHelper : NSObject {
    
    fileprivate var panG : UIPanGestureRecognizer!

    fileprivate var webView: UIWebView!
    fileprivate var pagerPanRecognizer: UIPanGestureRecognizer!
    fileprivate var underlyingView : UIView!
    
    init(webView: UIWebView, onView: UIView, pagerPanRecognizer: UIPanGestureRecognizer) {
        super.init()

        self.webView = webView
        self.pagerPanRecognizer = pagerPanRecognizer
        self.underlyingView = onView
        
        webView.scrollView.bounces = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.showsVerticalScrollIndicator = false
        
        panG = UIPanGestureRecognizer(target: self, action: #selector(WebViewHorizontalScrollHelper.didPan(_:)))
        panG.delegate = self
        panG.cancelsTouchesInView = false
        onView.addGestureRecognizer(panG)
    }
    
    fileprivate var shouldTranslateOffsetChange = false
    fileprivate var offsetChange : CGFloat = 0
    fileprivate var startOffset : CGFloat = 0
    
    //Magically counts all the offsets and decides whether the gesture should be translated to the pageview 
    func didPan(_ sender: UIPanGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.began {
            offsetChange = 0
            startOffset = webView.scrollView.contentOffset.x
        }
        
        if shouldTranslateOffsetChange {
            var cleanOffset = webView.scrollView.contentOffset.x + offsetChange
            cleanOffset -= sender.translation(in: webView).x
            cleanOffset = max(0, cleanOffset)
            cleanOffset = min(cleanOffset, rightLimitOffsetX)
            offsetChange = -cleanOffset + startOffset
            webView.scrollView.contentOffset = CGPoint(x: cleanOffset, y: webView.scrollView.contentOffset.y)
        }
    }

    fileprivate var rightLimitOffsetX : CGFloat {
        return max(0, getContentWidth(webView) - webView.bounds.width)
    }

    fileprivate func getContentWidth(_ webView: UIWebView) -> CGFloat {
        return webView.scrollView.contentSize.width
    }
    
    
}

extension WebViewHorizontalScrollHelper : UIGestureRecognizerDelegate {
    
    //Makes decisions about translating gestures to another recognizers using data, counted in didPan()
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if (otherGestureRecognizer == pagerPanRecognizer) {
//            print("did ask for simultaneous recognition with pagination")
            
            let sender = gestureRecognizer as! UIPanGestureRecognizer
            let locationInView = sender.location(in: webView)
            if webView.bounds.contains(locationInView)  {
//                print("pan located inside webview")
                let vel = sender.velocity(in: underlyingView)
                let draggedRight = vel.x > 0
//                print("webview content offset -> \(webView.scrollView.contentOffset.x), draggedRight: \(draggedRight)")
                if (webView.scrollView.contentOffset.x == 0 && draggedRight) ||
                    (webView.scrollView.contentOffset.x == rightLimitOffsetX && !draggedRight){
//                    print("offset is an edge one, dragged right state \(draggedRight)")
                    shouldTranslateOffsetChange = false
                    return true
                } else {
                    shouldTranslateOffsetChange = true
                    return false
                }
            } else {
                shouldTranslateOffsetChange = false
                return true
            }
        }
        
        return false
    }
}
