//
//  WebStepViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 15.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import Alamofire
import FLKAutoLayout
import SVProgressHUD

class WebStepViewController: UIViewController {

    @IBOutlet weak var stepWebView: UIWebView!
//    @IBOutlet weak var solveButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var quizPlaceholderView: UIView!
//    @IBOutlet weak var solveButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var stepWebViewHeight: NSLayoutConstraint!

    @IBOutlet weak var quizPlaceholderViewHeight: NSLayoutConstraint!
    
    var pager : RGPageViewController!
    
    var nItem : UINavigationItem!
    var didStartLoadingFirstRequest = false
//    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    
    var step : Step!
    var stepId : Int!
    var lesson : Lesson!
    var assignment : Assignment?
    
    var stepUrl : String {
        return "https://stepic.org/lesson/\(lesson.slug)/step/\(stepId)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stepWebView.delegate = self
        
        stepWebView.scrollView.delegate = self
//        stepWebView.scrollView.directionalLockEnabled = true
        stepWebView.scrollView.bounces = true
        stepWebView.scrollView.backgroundColor = UIColor.whiteColor()
//        stepWebView.scrollView.panGestureRecognizer.delegate = self
        handleQuizType()
//        stepWebView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
//        solveButton.setRoundedCorners(cornerRadius: 8, borderWidth: 0, borderColor: UIColor.stepicGreenColor())
        stepWebView.scrollView.showsVerticalScrollIndicator = false
    }

    func testAPI() {
        ApiDataDownloader.sharedDownloader.getAttemptsFor(stepName: step.block.name, stepId: step.id, success: {
            attempts, meta in
            if attempts.count == 0 || attempts[0].status != "active" {
                //Create attempt
                ApiDataDownloader.sharedDownloader.createNewAttemptWith(stepName: self.step.block.name, stepId: self.step.id, success: {
                    attempt in
                    //Display attempt using dataset
                    }, error: {
                        errorText in   
                })
            } else {
                //Get submission for attempt
                let currentAttempt = attempts[0]
                ApiDataDownloader.sharedDownloader.getSubmissionsWith(stepName: self.step.block.name, attemptId: currentAttempt.id!, success: {
                    submissions, meta in
                    if submissions.count == 0 {
                        //There are no current submissions for attempt.
                        //For testing - create the submission
                        if let dataset = currentAttempt.dataset as? ChoiceDataset {
                            
                            var arr = [Bool](count: dataset.options.count, repeatedValue: false)
                            arr[0] = true
                            let r = ChoiceReply(choices: arr)
                            
                            ApiDataDownloader.sharedDownloader.createSubmissionFor(stepName: self.step.block.name, attemptId: attempts[0].id!, reply: r, success: {
                                submission in
                                
                                }, error: {
                                    errorText in
                                    
                            })
                        }
                    } else {
                        //Displaying the last submission
                        
                    }
                    }, error: {
                        errorText in
                        
                })
            }
            }, error: {
                errorText in
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        nItem.rightBarButtonItem = nil
        
        if let htmlText = step.block.text {
//            let scriptsString = "\(Scripts.texScript)\n\(Scripts.sizeReportScript)"
            let scriptsString = "\(Scripts.texScript)"
            var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: htmlText, width: Int(UIScreen.mainScreen().bounds.width))
            html = html.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            stepWebView.loadHTMLString(html, baseURL: nil)
            //stepWebView.scalesPageToFit = true
        }

        SVProgressHUD.dismiss()
    }
    
    func handleQuizType() {
        switch step.block.name {
        case "text":
            stepWebView.alignBottomEdgeWithView(contentView, predicate: "8")
            break
        case "choice":
            let quizController = ControllerHelper.instantiateViewController(identifier: "ChoiceQuizViewController", storyboardName: "QuizControllers") as! ChoiceQuizViewController
            quizController.delegate = self
            quizController.step = self.step
            self.addChildViewController(quizController)
            quizPlaceholderView.addSubview(quizController.view)
            quizController.view.alignToView(quizPlaceholderView)
            self.view.layoutIfNeeded()
            break
        default:
            let quizController = ControllerHelper.instantiateViewController(identifier: "UnknownTypeQuizViewController", storyboardName: "QuizControllers") as! UnknownTypeQuizViewController
            quizController.stepUrl = self.stepUrl
            quizController.delegate = self
            self.addChildViewController(quizController)
            quizPlaceholderView.addSubview(quizController.view)
            quizController.view.alignToView(quizPlaceholderView)
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let a = assignment {
            ApiDataDownloader.sharedDownloader.didVisitStepWith(id: step.id, assignment: a.id, success: {}) 
        }
    }
    
    @IBAction func solveOnTheWebsitePressed(sender: UIButton) {
//        print(stepUrl)
//        print(NSURL(string: stepUrl))
        
        let url = NSURL(string: stepUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
        
        WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: self, withKey: "external link", allowsSafari: true, backButtonStyle: BackButtonStyle.Close)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        print("did layout subviews")
    }
    
    
    func resetWebViewHeight(height: Float) {
        stepWebViewHeight.constant = CGFloat(height)
        self.view.layoutIfNeeded()
    }
    
    var additionalOffsetXValue : CGFloat = 0.0

}

extension WebStepViewController : UIWebViewDelegate {
    
    func openInBrowserAlert(url: NSURL) {
        let alert = UIAlertController(title: NSLocalizedString("Link", comment: ""), message: NSLocalizedString("OpenInBrowser", comment: ""), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Open", comment: ""), style: .Default, handler: { 
            (action) -> Void in
            UIThread.performUI{
                WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: self, withKey: "external link", allowsSafari: true, backButtonStyle: BackButtonStyle.Close)
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        print(request.URLString)
        if didStartLoadingFirstRequest {
            if let url = request.URL { 
                if url.absoluteString != "about:blank" {
//                if url.scheme == "ready" {
//                    resetWebViewHeight(Float(url.host!)!)
//                } else {
                    print("trying to open in browser url -> \(url)")
                    openInBrowserAlert(url) 
                }
//                }
            }
            return false
        } else {
            didStartLoadingFirstRequest = true
            return true
        }
    }
    
    func getContentHeight(webView : UIWebView) -> Int {
        return Int(webView.stringByEvaluatingJavaScriptFromString("document.body.scrollHeight;") ?? "0") ?? 0
//        return Int(webView.scrollView.contentSize.height)
    }
    
    func getContentWidth(webView: UIWebView) -> CGFloat {
        return webView.scrollView.contentSize.width
//        return Int(webView.stringByEvaluatingJavaScriptFromString("document.body.width;") ?? "0") ?? 0
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        print("did finish load called, step id -> \(stepId) height -> \(getContentHeight(webView))")
        resetWebViewHeight(Float(getContentHeight(webView)))
//        let height = getContentHeight(webView)
//        print("step id -> \(stepId) height -> \(height)")
//////        webViewHeight.constant = CGFloat(height + 32)
////        webView.constrainHeight("\(height + 32)")
//        stepWebViewHeight.constant = CGFloat(height)
//        self.view.layoutIfNeeded()
////        webView.frame.size = CGSize(width: Int(webView.frame.width), height: Int(stringHeight) ?? 0)
    }
}

extension WebStepViewController : UIScrollViewDelegate {
    
    var rightLimitOffsetX : CGFloat {
        return max(0, getContentWidth(stepWebView) - UIScreen.mainScreen().bounds.width)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        print("\n\nwill begin dragging\n\n")
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0 {
            var offset = scrollView.contentOffset;
            offset.y = 0
            scrollView.contentOffset = offset;
        }
        
        print("did scroll offset \(scrollView.contentOffset)")
//        pager.pagerScrollView.contentOffset = CGPoint(x: 500, y: pager.pagerScrollView.contentOffset.y)

        if scrollView.contentOffset.x >= rightLimitOffsetX  {
            scrollView.scrollEnabled = false
        }
        if scrollView.contentOffset.x <= 0 {
            scrollView.scrollEnabled = false
        }

        
//        print("did scroll offset\(scrollView.contentOffset), content size width -> \(CGFloat(getContentWidth(stepWebView))), general width displayed -> \(scrollView.contentOffset.x + UIScreen.mainScreen().bounds.width)")
//        if scrollView.contentOffset.x > rightLimitOffsetX && !scrollView.decelerating {
//            let newPagerOffsetX = pager.pagerScrollView.contentOffset.x - additionalOffsetXValue + (scrollView.contentOffset.x - rightLimitOffsetX)
//            additionalOffsetXValue = scrollView.contentOffset.x - rightLimitOffsetX
//            pager.pagerScrollView.contentOffset = CGPoint(x: newPagerOffsetX, y: pager.pagerScrollView.contentOffset.y)
////            scrollView.contentOffset = CGPoint(x: rightLimitOffsetX, y: scrollView.contentOffset.y)
//            return
//        }
//        
//        if scrollView.contentOffset.x < 0 && !scrollView.decelerating {
//            let newPagerOffsetX = pager.pagerScrollView.contentOffset.x - additionalOffsetXValue + scrollView.contentOffset.x
//            additionalOffsetXValue = scrollView.contentOffset.x
//            pager.pagerScrollView.contentOffset = CGPoint(x: newPagerOffsetX, y: pager.pagerScrollView.contentOffset.y)
////            scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
//            return
//        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("did end dragging")
        scrollView.scrollEnabled = true
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
//        scrollView.setContentOffset(scrollView.contentOffset, animated: true)
        print("will begin decelerating offset\(scrollView.contentOffset)")
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        print("did end decelerating offset\(scrollView.contentOffset)")
    }
}

extension WebStepViewController : QuizControllerDelegate {
    func needsHeightUpdate(newHeight: CGFloat) {
        quizPlaceholderViewHeight.constant = newHeight
        view.layoutIfNeeded()
        quizPlaceholderView.layoutIfNeeded()
    }
}

extension WebStepViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == stepWebView.scrollView.panGestureRecognizer && otherGestureRecognizer == pager.pagerScrollView.panGestureRecognizer) || (otherGestureRecognizer == stepWebView.scrollView.panGestureRecognizer && gestureRecognizer == pager.pagerScrollView.panGestureRecognizer) {
            return true
        }
        return false
    }
}