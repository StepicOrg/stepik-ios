//
//  ChoiceQuizWebViewTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import BEMCheckBox
import FLKAutoLayout

class ChoiceQuizWebViewTableViewCell: ChoiceQuizTableViewCell {

    var choiceWebView: UIWebView! = UIWebView()
    
    var webViewHelper : CellWebViewHelper!
    
    override var reuseIdentifier: String? {
        return "ChoiceQuizWebViewTableViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textContainerView.addSubview(choiceWebView)
        choiceWebView.alignToView(textContainerView)
        webViewHelper = CellWebViewHelper(webView: choiceWebView, heightWithoutWebView: 17)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setHTMLText(text: String) -> (Void -> Int) {
        return self.webViewHelper.setTextWithTeX(text)
    }
}
