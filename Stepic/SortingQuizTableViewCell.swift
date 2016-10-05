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
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        initLabel()
        initWebView()

        contentView.backgroundColor = UIColor.clear
        webViewHelper = CellWebViewHelper(webView: optionWebView, heightWithoutWebView: 17)
    }

    func initLabel() {
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
        textContainerView.addSubview(optionWebView)
        optionWebView.align(to: textContainerView)
        webViewHelper = CellWebViewHelper(webView: optionWebView, heightWithoutWebView: 17)
        optionWebView.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        optionWebView.isHidden = true
        optionLabel.isHidden = true
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

extension SortingQuizTableViewCell : TextHeightDependentCellProtocol {
    
    //All optimization logics is now encapsulated here
    func setHTMLText(_ text: String) -> ((Void) -> Int) {
        if TagDetectionUtil.isWebViewSupportNeeded(text) {
            optionWebView.isHidden = false
            return webViewHelper.setTextWithTeX(text)
        } else {
            optionLabel.isHidden = false
            optionLabel.setTextWithHTMLString(text)
            return {
                [weak self] in
                if let w = self?.textContainerView.bounds.width {
                    return max(27, Int(UILabel.heightForLabelWithText(text, lines: 0, fontName: "ArialMT", fontSize: 16, width: w - 60))) + 17
                } else {
                    return 0
                }
            }
        }
    }
}
