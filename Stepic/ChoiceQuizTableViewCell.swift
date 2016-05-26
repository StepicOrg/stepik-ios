//
//  ChoiceQuizTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import BEMCheckBox

class ChoiceQuizTableViewCell: UITableViewCell {

    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var choiceWebView: UIWebView!
    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    
    weak var horizontalScrollHelper : WebViewHorizontalScrollHelper!
    
    var tapRecognizer : UITapGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkBox.onAnimationType = .Fill
        checkBox.animationDuration = 0.3
        contentView.backgroundColor = UIColor.clearColor()
        choiceWebView.opaque = false
        choiceWebView.backgroundColor = UIColor.clearColor()
        choiceWebView.scrollView.backgroundColor = UIColor.clearColor()
        choiceWebView.scrollView.delegate = self
        choiceWebView.scrollView.showsVerticalScrollIndicator = false
        choiceWebView.scrollView.canCancelContentTouches = false
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChoiceQuizTableViewCell.didTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        
        choiceWebView.addGestureRecognizer(tapRecognizer)
    }

    private func getContentHeight(webView : UIWebView) -> Int {
        return Int(webView.stringByEvaluatingJavaScriptFromString("document.body.scrollHeight;") ?? "0") ?? 0
    }
    
    //Method sets text and returns the method which returns current cell height according to the 
    func setTextWithTeX(text: String) -> (Void->Int) {
        let scriptsString = "\(Scripts.localTexScript)"
        let html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: text, width: Int(UIScreen.mainScreen().bounds.width) - 52)
        choiceWebView.loadHTMLString(html, baseURL: NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath))
        
        return {
            [weak self] in
            if let cw = self?.choiceWebView {
                if let h = self?.getContentHeight(cw) {
                    return h + 17
                }
            }
            return 0
        }
    }
    
    var tapHandler : (Void->Void)?
    
    func didTap(sender: UITapGestureRecognizer) {
        tapHandler?()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    deinit{
        print("did deinit cell")
    }
    
}

extension ChoiceQuizTableViewCell : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (scrollView.contentOffset.y != 0) {
            var offset = scrollView.contentOffset;
            offset.y = 0
            scrollView.contentOffset = offset;
        }
    }
}

extension ChoiceQuizTableViewCell {
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == tapRecognizer { 
            return true 
        } else {
            return false
        }
    }
}
