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
    
    private var panG : UIPanGestureRecognizer!

    private var webView: UIWebView!
    private var pagerPanRecognizer: UIPanGestureRecognizer!
    private var underlyingView : UIView!
    
    init(webView: UIWebView, onView: UIView, pagerPanRecognizer: UIPanGestureRecognizer) {
        super.init()

        self.webView = webView
        self.pagerPanRecognizer = pagerPanRecognizer
        self.underlyingView = onView
        
        webView.scrollView.bounces = false
        webView.scrollView.scrollEnabled = false
        webView.scrollView.showsVerticalScrollIndicator = false
        
        panG = UIPanGestureRecognizer(target: self, action: #selector(WebViewHorizontalScrollHelper.didPan(_:)))
        panG.delegate = self
        panG.cancelsTouchesInView = false
        onView.addGestureRecognizer(panG)
    }
    
    private var shouldTranslateOffsetChange = false
    private var offsetChange : CGFloat = 0
    private var startOffset : CGFloat = 0
    
    //Magically counts all the offsets and decides whether the gesture should be translated to the pageview 
    func didPan(sender: UIPanGestureRecognizer) {
        print("did Pan on webview")
        
        if sender.state == UIGestureRecognizerState.Began {
            offsetChange = 0
            startOffset = webView.scrollView.contentOffset.x
        }
        
        if shouldTranslateOffsetChange {
            var cleanOffset = webView.scrollView.contentOffset.x + offsetChange
            cleanOffset -= sender.translationInView(webView).x
            cleanOffset = max(0, cleanOffset)
            cleanOffset = min(cleanOffset, rightLimitOffsetX)
            offsetChange = -cleanOffset + startOffset
            webView.scrollView.contentOffset = CGPoint(x: cleanOffset, y: webView.scrollView.contentOffset.y)
        }
    }

    private var rightLimitOffsetX : CGFloat {
        return max(0, getContentWidth(webView) - webView.bounds.width)
    }

    private func getContentWidth(webView: UIWebView) -> CGFloat {
        return webView.scrollView.contentSize.width
    }
    
    
}

extension WebViewHorizontalScrollHelper : UIGestureRecognizerDelegate {
    
    //Makes decisions about translating gestures to another recognizers using data, counted in didPan()
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if (otherGestureRecognizer == pagerPanRecognizer) {
//            print("did ask for simultaneous recognition with pagination")
            
            let sender = gestureRecognizer as! UIPanGestureRecognizer
            let locationInView = sender.locationInView(webView)
            if CGRectContainsPoint(webView.bounds, locationInView)  {
//                print("pan located inside webview")
                let vel = sender.velocityInView(underlyingView)
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
