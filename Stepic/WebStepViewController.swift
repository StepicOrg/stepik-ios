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
    @IBOutlet weak var solveButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var solveButtonHeight: NSLayoutConstraint!
    
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
        
//        stepWebView.scrollView.scrollEnabled = false
//        stepWebView.scrollView.bounces = false
        
        if let htmlText = step.block.text {
            var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: Scripts.texScript, body: htmlText, width: Int(UIScreen.mainScreen().bounds.width))
            html = html.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            stepWebView.loadHTMLString(html, baseURL: nil)
            //stepWebView.scalesPageToFit = true
        }
        
        if step.block.name == "text" {
            solveButtonHeight.constant = 0
            solveButton.hidden = true
        }
        
//        if step.block.name == "text" {
//            solveButton.hidden = true
//            stepWebView.constrainBottomSpaceToView(contentView, predicate: "8")
//        } else {
//            stepWebView.constrainBottomSpaceToView(solveButton, predicate: "0")
//        }
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        nItem.rightBarButtonItem = nil
        SVProgressHUD.dismiss()
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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
        print(request.URLString)
        if didStartLoadingFirstRequest {
            if let url = request.URL { 
                openInBrowserAlert(url) 
            }
            return false
        } else {
            didStartLoadingFirstRequest = true
            return true
        }
    }
    
    func getContentHeight(webView : UIWebView) -> Int {
        return Int(webView.stringByEvaluatingJavaScriptFromString("document.body.offsetHeight;") ?? "0") ?? 0
//        return Int(webView.scrollView.contentSize.height)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
//        let height = getContentHeight(webView)
//        print("step id -> \(stepId) height -> \(height)")
////        webViewHeight.constant = CGFloat(height + 32)
//        webView.constrainHeight("\(height + 32)")
        
//        webView.frame.size = CGSize(width: Int(webView.frame.width), height: Int(stringHeight) ?? 0)
    }
}
