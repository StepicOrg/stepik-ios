//
//  SortingQuizTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 27.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class SortingQuizTableViewCell: UITableViewCell {

    
    @IBOutlet weak var textContainerView: UIView!
        
    var webViewHelper : CellWebViewHelper!
    var optionLabel: UILabel! = UILabel()
    var optionWebView: UIWebView! = UIWebView()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        
        initLabel()
        initWebView()

        contentView.backgroundColor = UIColor.clearColor()
        webViewHelper = CellWebViewHelper(webView: optionWebView, heightWithoutWebView: 17)
    }

    func initLabel() {
        optionLabel.numberOfLines = 0
        optionLabel.font = UIFont(name: "ArialMT", size: 16)
        optionLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        optionLabel.baselineAdjustment = UIBaselineAdjustment.AlignBaselines
        optionLabel.textAlignment = NSTextAlignment.Natural
        optionLabel.backgroundColor = UIColor.clearColor()
        textContainerView.addSubview(optionLabel)
        optionLabel.alignTop("0", leading: "8", bottom: "0", trailing: "-8", toView: textContainerView)
        optionLabel.hidden = true
    }
    
    func initWebView() {
        textContainerView.addSubview(optionWebView)
        optionWebView.alignToView(textContainerView)
        webViewHelper = CellWebViewHelper(webView: optionWebView, heightWithoutWebView: 17)
        optionWebView.hidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        optionWebView.hidden = true
        optionLabel.hidden = true
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension SortingQuizTableViewCell : TextHeightDependentCellProtocol {
    
    //All optimization logics is now encapsulated here
    func setHTMLText(text: String) -> (Void -> Int) {
        if TagDetectionUtil.isWebViewSupportNeeded(text) {
            optionWebView.hidden = false
            return webViewHelper.setTextWithTeX(text)
        } else {
            optionLabel.hidden = false
            optionLabel.setTextWithHTMLString(text)
            return {
                [weak self] in
                if let w = self?.textContainerView.bounds.width {
                    return max(27, Int(UILabel.heightForLabelWithText(text, lines: 0, fontName: "ArialMT", fontSize: 16, width: w - 16))) + 17
                } else {
                    return 0
                }
            }
        }
    }
}
