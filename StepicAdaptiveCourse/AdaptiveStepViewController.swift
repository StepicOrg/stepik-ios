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
    var isCorrectSolved = false {
        didSet {
            if isCorrectSolved {
                doneButton.setIcon(for: .done)
            } else {
                doneButton.setIcon(for: .dismiss)
            }
        }
    }
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var doneButton: StepControlButton!
    @IBOutlet weak var stepWebView: UIWebView!
    @IBOutlet weak var quizPlaceholderView: UIView!
    @IBOutlet weak var quizPlaceholderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stepWebViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    
    var dismissHandler: () -> () = { }
    var successHandler: () -> () = { }
    
    @IBAction func onNextButtonClick(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: { _ in
            if !self.isCorrectSolved {
                self.dismissHandler()
            } else {
                self.successHandler()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bottomView.bounds
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0.0).cgColor,
                                UIColor.white.withAlphaComponent(0.4).cgColor,
                                UIColor.white.withAlphaComponent(0.6).cgColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        bottomView.layer.insertSublayer(gradientLayer, at: 0)
        
        self.titleLabel.text = recommendedLesson.title
        self.loadStepHTML(for: step)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let quizVC = self.quizVC else {
            print("quizVC not init")
            return
        }
        
        // Detach controller from card, attach to current vc and update height
        quizVC.view.removeFromSuperview()
        quizVC.removeFromParentViewController()
        quizVC.delegate = self
        
        self.addChildViewController(quizVC)
        self.quizPlaceholderView.addSubview(quizVC.view)
        quizVC.view.align(to: self.quizPlaceholderView)
        
        self.needsHeightUpdate(quizVC.heightWithoutQuiz + quizVC.expectedQuizHeight, animated: false, breaksSynchronizationControl: false)
        
        quizVC.sendButton.isHidden = false
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Detach quiz view controller
        quizVC?.view.removeFromSuperview()
        quizVC?.removeFromParentViewController()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func loadStepHTML(for step: Step) {
        if let htmlText = step.block.text {
            let scriptsString = "\(Scripts.localTexScript)"
            var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: htmlText, width: Int(UIScreen.main.bounds.width))
            html = html.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            stepWebView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        }
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
    
    func submissionDidCorrect() {
        isCorrectSolved = true
    }
    
    func submissionDidWrong() {
        isCorrectSolved = false
    }
    
    func didTryAgainButtonClick() {
        isCorrectSolved = false
    }
}
