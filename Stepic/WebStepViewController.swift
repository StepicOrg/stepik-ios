//
//  WebStepViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 15.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import Alamofire

class WebStepViewController: UIViewController {

    @IBOutlet weak var stepWebView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stepWebView.delegate = self
        
        // Do any additional setup after loading the view.
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
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("loading page")
        return true
    }
}
