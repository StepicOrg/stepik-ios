//
//  AdaptiveStepViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AdaptiveStepViewController: UIViewController {

    var course: Course!
    var recommendedLesson: Lesson!
    var step: Step!
    
    var quizVC: ChoiceQuizViewController?
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var stepWebView: UIWebView!
    @IBOutlet weak var quizPlaceholderView: UIView!
    @IBOutlet weak var quizPlaceholderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stepWebViewHeight: NSLayoutConstraint!
    
    var dismissHandler: () -> () = { }
    var successHandler: () -> () = { }
    
    @IBAction func onDismissButtonClick(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: { _ in
            self.dismissHandler()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadQuiz(for: step)
        self.loadStepHTML(for: step)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func loadStepHTML(for step: Step) {
        if let htmlText = step.block.text {
            let scriptsString = "\(Scripts.localTexScript)"
            var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: htmlText, width: Int(UIScreen.main.bounds.width))
            html = html.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            print("\(Bundle.main.bundlePath)")
            stepWebView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        }
    }
    
    fileprivate func loadQuiz(for step: Step) {
        if let quizVC = self.quizVC {
            quizVC.view.removeFromSuperview()
            quizVC.removeFromParentViewController()
        }
        
        self.quizVC = ChoiceQuizViewController(nibName: "QuizViewController", bundle: nil)
        
        guard let quizVC = self.quizVC else {
            print("quizVC init failed")
            return
        }
        quizVC.step = step
        quizVC.delegate = self
        
        self.addChildViewController(quizVC)
        self.quizPlaceholderView.addSubview(quizVC.view)
        quizVC.view.align(to: self.quizPlaceholderView)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
}

extension AdaptiveStepViewController: UIWebViewDelegate {
    func resetWebViewHeight(_ height: Float) {
        stepWebViewHeight.constant = CGFloat(height)
    }
    
    func getContentHeight(_ webView : UIWebView) -> Int {
        let height = Int(webView.stringByEvaluatingJavaScript(from: "document.body.scrollHeight;") ?? "0") ?? 0
        return height
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        resetWebViewHeight(Float(getContentHeight(webView)))
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        resetWebViewHeight(Float(getContentHeight(stepWebView)))
    }
}

extension AdaptiveStepViewController: QuizControllerDelegate {
    func needsHeightUpdate(_ newHeight: CGFloat, animated: Bool, breaksSynchronizationControl: Bool) {
        DispatchQueue.main.async {
            [weak self] in
            self?.quizPlaceholderViewHeight.constant = newHeight
            if animated {
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.view.layoutIfNeeded()
                }, completion: nil)
            } else {
                self?.view.layoutIfNeeded()
            }
            
        }
        
    }
}
