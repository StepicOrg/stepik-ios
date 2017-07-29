//
//  ChoiceQuizTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 06.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import BEMCheckBox
import FLKAutoLayout

class ChoiceQuizTableViewCell: UITableViewCell {

    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    var choiceLabel: UILabel?
    var choiceWebView: FullHeightWebView?
    
    var webViewHelper : CellWebViewHelper?

    func initLabel() {
        guard choiceLabel == nil else { return }
        choiceLabel = UILabel()
        guard let choiceLabel = choiceLabel else { return }
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
        guard choiceWebView == nil else { return }
        choiceWebView = FullHeightWebView()
        guard let choiceWebView = choiceWebView else { return }
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
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        choiceWebView?.isHidden = true
        choiceLabel?.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension ChoiceQuizTableViewCell { //: TextHeightDependentCellProtocol {
    
    //All optimization logics is now encapsulated here
    func setHTMLText(_ text: String, finishedBlock: ((CGFloat) -> Void)? = nil){
        if TagDetectionUtil.isWebViewSupportNeeded(text) {
            initWebView()
            choiceWebView?.isHidden = false
            webViewHelper?.mathJaxFinishedBlock = {
                [weak self] in
                self?.layoutIfNeeded()
                if let webView = self?.choiceWebView {
                    webView.invalidateIntrinsicContentSize()
                    finishedBlock?(17 + webView.contentHeight)
                }
            }
            _ = webViewHelper?.setTextWithTeX(text)
        } else {
            initLabel()
            choiceLabel?.isHidden = false
            choiceLabel?.setTextWithHTMLString(text)
            let w = UIScreen.main.bounds.width - 52
            let height = max(27, UILabel.heightForLabelWithText(text, lines: 0, fontName: "ArialMT", fontSize: 16, width: w)) + 17
            finishedBlock?(height)
        }
    }
}
