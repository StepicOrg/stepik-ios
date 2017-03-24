//
//  AdaptiveStepViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AdaptiveStepViewController: UIViewController {

    var step: Step?
    
    @IBOutlet weak var stepWebView: UIWebView!
    @IBOutlet weak var quizPlaceholderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let vc = ChoiceQuizViewController(nibName: "QuizViewController", bundle: nil)
        vc.step = step
        
        self.addChildViewController(vc)
        self.quizPlaceholderView.addSubview(vc.view)
        vc.view.align(to: quizPlaceholderView)
        //        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        loadStepHTML()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func loadStepHTML() {
        if let htmlText = step?.block.text {
            let scriptsString = "\(Scripts.localTexScript)"
            var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: htmlText, width: Int(UIScreen.main.bounds.width))
            html = html.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            print("\(Bundle.main.bundlePath)")
            stepWebView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
