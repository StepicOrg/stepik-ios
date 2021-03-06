//
//  ChoiceQuizTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 06.06.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import BEMCheckBox
import SnapKit
import UIKit

final class ChoiceQuizTableViewCell: UITableViewCell {
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var checkBox: BEMCheckBox!

    var optionLabel: StepikLabel?
    var optionWebView: FullHeightWebView?

    var webViewHelper: CellWebViewHelper?

    private func initLabel() {
        guard optionLabel == nil else { return }
        optionLabel = StepikLabel()
        guard let optionLabel = optionLabel else { return }
        optionLabel.numberOfLines = 0
        optionLabel.font = UIFont(name: "ArialMT", size: 16)
        optionLabel.lineBreakMode = .byTruncatingTail
        optionLabel.baselineAdjustment = .alignBaselines
        optionLabel.textAlignment = .natural
        optionLabel.backgroundColor = .clear
        textContainerView.addSubview(optionLabel)
        optionLabel.snp.makeConstraints { make -> Void in
            make.top.bottom.equalTo(textContainerView)
            make.leading.equalTo(textContainerView).offset(8)
            make.trailing.equalTo(textContainerView).offset(-8)
        }
        optionLabel.isHidden = true
    }

    private func initWebView() {
        guard optionWebView == nil else { return }
        optionWebView = FullHeightWebView()
        guard let optionWebView = optionWebView else { return }
        textContainerView.addSubview(optionWebView)
        optionWebView.snp.makeConstraints { $0.edges.equalTo(textContainerView) }
        webViewHelper = CellWebViewHelper(webView: optionWebView, fontSize: StepFontSizeStorageManager().globalStepFontSize)
        optionWebView.isHidden = true
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        checkBox.onAnimationType = .fill
        checkBox.animationDuration = 0.3
        contentView.backgroundColor = .clear
        checkBox.onTintColor = .stepikAccentFixed
        checkBox.onFillColor = .stepikAccentFixed
        checkBox.tintColor = .stepikAccentFixed
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        optionWebView?.isHidden = true
        optionLabel?.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    static func getHeightForText(text: String, width: CGFloat) -> CGFloat {
        let labelHeight = StepikLabel.heightForLabelWithText(
            text, lines: 0, fontName: "ArialMT", fontSize: 16, width: width - 68, html: true
        )

        return max(27, labelHeight) + 17
    }
}

extension ChoiceQuizTableViewCell {
    //All optimization logic is now encapsulated here
    func setHTMLText(_ text: String, width: CGFloat, finishedBlock: @escaping (CGFloat) -> Void) {
        if TagDetectionUtil.isWebViewSupportNeeded(text) {
            initWebView()
            optionWebView?.isHidden = false
            webViewHelper?.mathJaxFinishedBlock = { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.layoutIfNeeded()

                if let webView = strongSelf.optionWebView {
                    webView.getContentHeight().done { contentHeight in
                        webView.invalidateIntrinsicContentSize()
                        finishedBlock(17 + contentHeight)
                    }
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
