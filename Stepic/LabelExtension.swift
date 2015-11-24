//
//  LabelExtension.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

extension UILabel {
    func setTextWithHTMLString(htmlText: String) {
//        Time.tick(htmlText)
        let descData = htmlText.dataUsingEncoding(NSUnicodeStringEncoding) ?? NSData()
        
        
        //        courseDescriptionLabel.text = "some text"
        //        var range : NSRange? = NSMakeRange(0, 1)
        //        var attributes = courseDescriptionLabel.attributedText.attributesAtIndex(0, effectiveRange: &range!)
        //        attributes.merge([NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType])
        
        let attributedDescription = try? NSAttributedString(data: descData, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType], documentAttributes: nil) 
        self.text = attributedDescription!.string
//        Time.tock(htmlText)
    }
    
    class func heightForLabelWithText(text: String, lines: Int, standardFontOfSize size: CGFloat, width : CGFloat, html : Bool = false) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.max))
        
        label.numberOfLines = lines
        
        if html {
            label.setTextWithHTMLString(text)
        } else {
            label.text = text
        }
        
        label.font = UIFont.systemFontOfSize(size)
        label.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        label.baselineAdjustment = UIBaselineAdjustment.AlignBaselines
        label.sizeToFit()
        
//        print(label.bounds.height)
        return label.bounds.height
    }
}
