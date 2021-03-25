//
//  LabelExtension.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Atributika
import UIKit

extension UILabel {
    func setTextWithHTMLString(_ htmlText: String, lineSpacing: CGFloat? = nil) {
        let converter = HTMLToAttributedStringConverter(font: self.font)
        let attributedString = converter.convertToAttributedString(htmlString: htmlText)

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
        Self.heightForLabelWithText(
            text,
            lines: self.numberOfLines,
            font: self.font,
            width: self.bounds.width,
            html: html,
            alignment: self.textAlignment
        )
    }

    static func heightForLabelWithText(
        _ text: String,
        lines: Int,
        font: UIFont,
        width: CGFloat,
        html: Bool = false,
        alignment: NSTextAlignment = NSTextAlignment.natural
    ) -> CGFloat {
        self.heightForLabelWithText(
            text,
            lines: lines,
            fontName: font.fontName,
            fontSize: font.pointSize,
            width: width,
            html: html,
            alignment: alignment
        )
    }

    static func heightForLabelWithText(
        _ text: String,
        lines: Int,
        fontName: String,
        fontSize: CGFloat,
        width: CGFloat,
        html: Bool = false,
        alignment: NSTextAlignment = NSTextAlignment.natural
    ) -> CGFloat {
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

    static func heightForLabelWithText(
        _ text: String,
        lines: Int,
        standardFontOfSize size: CGFloat,
        width: CGFloat,
        html: Bool = false,
        alignment: NSTextAlignment = NSTextAlignment.natural
    ) -> CGFloat {
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
        CGSize(width: self.width + dw, height: self.height + dh)
    }
}

final class WiderLabel: UILabel {
    var widthDelta: CGFloat = 10 {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        super.intrinsicContentSize.sizeByDelta(dw: self.widthDelta, dh: 0)
    }
}
