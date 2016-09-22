//
//  ChoiceQuizTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 06.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import BEMCheckBox

class ChoiceQuizTableViewCell: UITableViewCell {

    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    var choiceLabel: UILabel! = UILabel()
    var choiceWebView: UIWebView! = UIWebView()
    
    var webViewHelper : CellWebViewHelper!

    func initLabel() {
        choiceLabel.numberOfLines = 0
        choiceLabel.font = UIFont(name: "ArialMT", size: 16)
        choiceLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        choiceLabel.baselineAdjustment = UIBaselineAdjustment.AlignBaselines
        choiceLabel.textAlignment = NSTextAlignment.Natural
        choiceLabel.backgroundColor = UIColor.clearColor()
        textContainerView.addSubview(choiceLabel)
        choiceLabel.alignTop("0", leading: "8", bottom: "0", trailing: "-8", toView: textContainerView)
        choiceLabel.hidden = true
    }

    func initWebView() {
        textContainerView.addSubview(choiceWebView)
        choiceWebView.alignToView(textContainerView)
        webViewHelper = CellWebViewHelper(webView: choiceWebView, heightWithoutWebView: 17)
        choiceWebView.hidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkBox.onAnimationType = .Fill
        checkBox.animationDuration = 0.3
        contentView.backgroundColor = UIColor.clearColor()
        
        initLabel()
        initWebView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        choiceWebView.hidden = true
        choiceLabel.hidden = true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension ChoiceQuizTableViewCell : TextHeightDependentCellProtocol {
    
    //All optimization logics is now encapsulated here
    func setHTMLText(text: String) -> (Void -> Int) {
        if TagDetectionUtil.isWebViewSupportNeeded(text) {
            choiceWebView.hidden = false
            return webViewHelper.setTextWithTeX(text)
        } else {
            choiceLabel.hidden = false
            choiceLabel.text = text
            let w = textContainerView.bounds.width 
            return {
                return max(27, Int(UILabel.heightForLabelWithText(text, lines: 0, fontName: "ArialMT", fontSize: 16, width: w - 16))) + 17
          
            }
        }
    }
}