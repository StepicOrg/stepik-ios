//
//  LabelExtension.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import Atributika

extension UILabel {
    func setTextWithHTMLString(_ htmlText: String, lineSpacing: CGFloat? = nil) {
        let currentFontSize = self.font.pointSize

        let attributedString = htmlText.style(tags: [
            Style("b").font(.boldSystemFont(ofSize: currentFontSize)),
            Style("strong").font(.boldSystemFont(ofSize: currentFontSize)),
            Style("i").font(.italicSystemFont(ofSize: currentFontSize)),
            Style("em").font(.italicSystemFont(ofSize: currentFontSize)),
            Style("strike").strikethroughStyle(.styleSingle)
        ]).attributedString

        if let lineSpacing = lineSpacing {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            let mutableString = NSMutableAttributedString(attributedString: attributedString)
            mutableString.addAttribute(
                .paragraphStyle,
                value: paragraphStyle,
                range: NSRange(location: 0, length: attributedString.length)
            )
            self.attributedText = mutableString.attributedString
        } else {
            self.attributedText = attributedString
        }
    }

    func getHeightWithText(_ text: String, html: Bool = false) -> CGFloat {
        return type(of: self).heightForLabelWithText(text, lines: numberOfLines, font: font, width: bounds.width, html: html, alignment: textAlignment)
    }

    class func heightForLabelWithText(_ text: String, lines: Int, font: UIFont, width: CGFloat, html: Bool = false, alignment: NSTextAlignment = NSTextAlignment.natural) -> CGFloat {

        return heightForLabelWithText(text, lines: lines, fontName: font.fontName, fontSize: font.pointSize, width: width, html: html, alignment: alignment)
    }

    class func heightForLabelWithText(_ text: String, lines: Int, fontName: String, fontSize: CGFloat, width: CGFloat, html: Bool = false, alignment: NSTextAlignment = NSTextAlignment.natural) -> CGFloat {

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))

        label.numberOfLines = lines

        label.font = UIFont(name: fontName, size: fontSize)
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.baselineAdjustment = UIBaselineAdjustment.alignBaselines
        label.textAlignment = alignment

        if html {
            label.setTextWithHTMLString(text)
        } else {
            label.text = text
        }
        label.sizeToFit()

        return label.bounds.height
    }

    class func heightForLabelWithText(_ text: String, lines: Int, standardFontOfSize size: CGFloat, width: CGFloat, html: Bool = false, alignment: NSTextAlignment = NSTextAlignment.natural) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))

        label.numberOfLines = lines

        if html {
            label.setTextWithHTMLString(text)
        } else {
            label.text = text
        }

        label.font = UIFont.systemFont(ofSize: size)
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.baselineAdjustment = UIBaselineAdjustment.alignBaselines
        label.textAlignment = alignment
        label.sizeToFit()

//        print(label.bounds.height)
        return label.bounds.height
    }
}

extension UILabel {
    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat.greatestFiniteMagnitude)
        let rHeight: Int = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(self.font.pointSize))
        return rHeight / charSize
    }
}

extension CGSize {
    func sizeByDelta(dw: CGFloat, dh: CGFloat) -> CGSize {
        return CGSize(width: self.width + dw, height: self.height + dh)
    }
}

class WiderLabel: UILabel {
    override var intrinsicContentSize: CGSize {
        return super.intrinsicContentSize.sizeByDelta(dw: 10, dh: 0)
    }
}
