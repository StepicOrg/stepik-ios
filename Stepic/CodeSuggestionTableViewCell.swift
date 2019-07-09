//
//  CodeSuggestionTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 08.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CodeSuggestionTableViewCell: UITableViewCell {

    @IBOutlet weak var suggestionLabel: StepikLabel!

    func setSuggestion(_ suggestion: String, prefixLength: Int, size: CodeSuggestionsSize?) {
        var fontSize: CGFloat = 11
        if let sz = size?.realSizes.fontSize {
            fontSize = sz
        }
        let boldCourier = UIFont(name: "Courier-Bold", size: fontSize)!
        let regularCourier = UIFont(name: "Courier", size: fontSize)!
        let attributedSuggestion = NSMutableAttributedString(string: suggestion, attributes: [NSAttributedString.Key.font: regularCourier])
        attributedSuggestion.addAttributes([NSAttributedString.Key.font: boldCourier], range: NSRange(location: 0, length: prefixLength))
        suggestionLabel.attributedText = attributedSuggestion
    }
}
