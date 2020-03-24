//
//  SearchSuggestionTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class SearchSuggestionTableViewCell: UITableViewCell {
    @IBOutlet weak var suggestionLabel: StepikLabel!

    func set(suggestion: String, query: String) {
        let fontSize: CGFloat = 17

        var boldFont = UIFont.boldSystemFont(ofSize: fontSize)
        boldFont = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.medium)

        let regularFont = UIFont.systemFont(ofSize: fontSize)

        let attributedSuggestionString = NSMutableAttributedString(
            string: suggestion,
            attributes: [
                NSAttributedString.Key.font: regularFont,
                NSAttributedString.Key.foregroundColor: UIColor.stepikSystemSecondaryLabel
            ]
        )

        if let queryLocation = suggestion.indexOf(query.lowercased()) {
            attributedSuggestionString.addAttributes(
                [
                    NSAttributedString.Key.font: boldFont,
                    NSAttributedString.Key.foregroundColor: UIColor.stepikPrimaryText
                ],
                range: NSRange(location: queryLocation, length: query.count)
            )
        }

        self.suggestionLabel.attributedText = attributedSuggestionString
    }
}
