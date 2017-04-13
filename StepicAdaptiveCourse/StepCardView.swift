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
    
    func updateContent(title: String, text: String?, completion: @escaping () -> () = { }) {
        contentDidLoadHandler = completion
        
        titleLabel.text = title
        
        if let text = text {
            let scriptsString = "\(Scripts.localTexScript)"
            var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: text, width: Int(UIScreen.main.bounds.width))
            html = html.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            webView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
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
    func webViewDidFinishLoad(_ webView: UIWebView) {
        contentDidLoadHandler()
    }
}
