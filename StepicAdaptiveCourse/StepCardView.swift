//
//  StepCardView.swift
//  CardsDemo
//
//  Created by Vladislav Kiryukhin on 04.04.17.
//  Copyright © 2017 Vladislav Kiryukhin. All rights reserved.
//

import UIKit

class StepCardView: UIView {

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var quizPlaceholderView: UIView!
    @IBOutlet weak var quizPlaceholderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    
    private var quizVC: ChoiceQuizViewController?
    
    lazy var parentViewController: UIViewController? = {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }()
    
    fileprivate var contentDidLoadHandler: () -> () = {}
    
    override func draw(_ rect: CGRect) {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.stepicGreenColor().cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = contentView.bounds
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0.0).cgColor,
                                UIColor.white.withAlphaComponent(0.4).cgColor,
                                UIColor.white.withAlphaComponent(1.0).cgColor]
        gradientLayer.locations = [0.0, 0.8, 1.0]
        contentView.layer.addSublayer(gradientLayer)
        
        self.webView.delegate = self
    }
    
    func hideContent() {
        contentView.isHidden = true
        titleLabel.isHidden = true
    }
    
    func updateContent(title: String, text: String?, step: Step, completion: @escaping () -> () = { }) {
        contentDidLoadHandler = completion
        
        // Step title
        titleLabel.text = title
        
        // Step text
        if let text = text {
            let scriptsString = "\(Scripts.localTexScript)"
            var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: text, width: Int(UIScreen.main.bounds.width))
            html = html.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            webView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        }
        
        // Step quiz
        if let quizVC = self.quizVC {
            quizVC.view.removeFromSuperview()
            quizVC.removeFromParentViewController()
        }
        
        if let parentVC = self.parentViewController {
            self.quizVC = ChoiceQuizViewController(nibName: "QuizViewController", bundle: nil)
            
            guard let quizVC = self.quizVC else {
                print("quizVC init failed")
                return
            }
            
            quizVC.step = step
            quizVC.delegate = self
            
            parentVC.addChildViewController(quizVC)
            self.quizPlaceholderView.addSubview(quizVC.view)
            quizVC.view.align(to: self.quizPlaceholderView)
            self.setNeedsLayout()
            self.layoutIfNeeded()
            
            quizVC.sendButton.isHidden = true
        }
    }
    
    func showContent() {
        UIView.transition(with: contentView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.contentView.isHidden = false
            self.titleLabel.isHidden = false
        }, completion: nil)
    }
}

extension StepCardView: UIWebViewDelegate {
    func resetWebViewHeight(_ height: Float) {
        webViewHeight.constant = CGFloat(height)
    }
    
    func getContentHeight(_ webView : UIWebView) -> Int {
        let height = Int(webView.stringByEvaluatingJavaScript(from: "document.body.scrollHeight;") ?? "0") ?? 0
        return height
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        resetWebViewHeight(Float(getContentHeight(webView)))
        contentDidLoadHandler()
    }
}

extension StepCardView: QuizControllerDelegate {
    func needsHeightUpdate(_ newHeight: CGFloat, animated: Bool, breaksSynchronizationControl: Bool) {
        DispatchQueue.main.async {
            [weak self] in
            self?.quizPlaceholderViewHeight.constant = newHeight
            if animated {
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.layoutIfNeeded()
                    }, completion: nil)
            } else {
                self?.layoutIfNeeded()
            }
            
        }
    }

    func didWarningPlaceholderShow() {
        if let vc = parentViewController as? AdaptiveStepsViewController {
            vc.isWarningHidden = false
        }
    }

}


