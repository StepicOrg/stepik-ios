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
        choiceLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        choiceLabel.baselineAdjustment = UIBaselineAdjustment.alignBaselines
        choiceLabel.textAlignment = NSTextAlignment.natural
        choiceLabel.backgroundColor = UIColor.clear
        textContainerView.addSubview(choiceLabel)
        choiceLabel.alignTop("0", leading: "8", bottom: "0", trailing: "-8", to: textContainerView)
        choiceLabel.isHidden = true
    }

    func initWebView() {
        textContainerView.addSubview(choiceWebView)
        choiceWebView.align(to: textContainerView)
        webViewHelper = CellWebViewHelper(webView: choiceWebView, heightWithoutWebView: 17)
        choiceWebView.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        checkBox.onAnimationType = .fill
        checkBox.animationDuration = 0.3
        contentView.backgroundColor = UIColor.clear
        
        initLabel()
        initWebView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        choiceWebView.isHidden = true
        choiceLabel.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension ChoiceQuizTableViewCell : TextHeightDependentCellProtocol {
    
    //All optimization logics is now encapsulated here
    func setHTMLText(_ text: String) -> ((Void) -> Int) {
        if TagDetectionUtil.isWebViewSupportNeeded(text) {
            choiceWebView.isHidden = false
            return webViewHelper.setTextWithTeX(text)
        } else {
            choiceLabel.isHidden = false
            choiceLabel.text = text
            let w = textContainerView.bounds.width 
            return {
                return max(27, Int(UILabel.heightForLabelWithText(text, lines: 0, fontName: "ArialMT", fontSize: 16, width: w - 16))) + 17
          
            }
        }
    }
}
