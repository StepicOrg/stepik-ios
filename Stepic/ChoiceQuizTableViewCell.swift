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

    var optionLabel: StepikLabel?
    var optionWebView: FullHeightWebView?

    var webViewHelper: CellWebViewHelper?

    func initLabel() {
        guard optionLabel == nil else { return }
        optionLabel = StepikLabel()
        guard let optionLabel = optionLabel else { return }
        optionLabel.numberOfLines = 0
        optionLabel.font = UIFont(name: "ArialMT", size: 16)
        optionLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        optionLabel.baselineAdjustment = UIBaselineAdjustment.alignBaselines
        optionLabel.textAlignment = NSTextAlignment.natural
        optionLabel.backgroundColor = UIColor.clear
        textContainerView.addSubview(optionLabel)
        optionLabel.alignTop("0", leading: "8", bottom: "0", trailing: "-8", to: textContainerView)
        optionLabel.isHidden = true
    }

    func initWebView() {
        guard optionWebView == nil else { return }
        optionWebView = FullHeightWebView()
        guard let optionWebView = optionWebView else { return }
        textContainerView.addSubview(optionWebView)
        optionWebView.align(to: textContainerView)
        webViewHelper = CellWebViewHelper(webView: optionWebView)
        optionWebView.isHidden = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        checkBox.onAnimationType = .fill
        checkBox.animationDuration = 0.3
        contentView.backgroundColor = UIColor.clear
        checkBox.onTintColor = UIColor.mainDark
        checkBox.onFillColor = UIColor.mainDark
        checkBox.tintColor = UIColor.mainDark
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        optionWebView?.isHidden = true
        optionLabel?.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    class func getHeightForText(text: String, width: CGFloat) -> CGFloat {
        return max(27, StepikLabel.heightForLabelWithText(text, lines: 0, fontName: "ArialMT", fontSize: 16, width: width - 68)) + 17
    }
}

extension ChoiceQuizTableViewCell {

    //All optimization logics is now encapsulated here
    func setHTMLText(_ text: String, width: CGFloat, finishedBlock: @escaping (CGFloat) -> Void) {
        if TagDetectionUtil.isWebViewSupportNeeded(text) {
            initWebView()
            optionWebView?.isHidden = false
            webViewHelper?.mathJaxFinishedBlock = {
                [weak self] in
                self?.layoutIfNeeded()
                if let webView = self?.optionWebView {
                    webView.invalidateIntrinsicContentSize()
                    finishedBlock(17 + webView.contentHeight)
                }
            }
            webViewHelper?.setTextWithTeX(text)
        } else {
            initLabel()
            optionLabel?.setTextWithHTMLString(text)
            optionLabel?.isHidden = false
            let height = ChoiceQuizTableViewCell.getHeightForText(text: text, width: width)
            finishedBlock(height)
        }
    }
}
