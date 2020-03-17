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
        var bold = UIFont.boldSystemFont(ofSize: fontSize)
        bold = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.medium)
        let regular = UIFont.systemFont(ofSize: fontSize)
        let attributedSuggestion = NSMutableAttributedString(string: suggestion, attributes: [NSAttributedString.Key.font: regular, NSAttributedString.Key.foregroundColor: UIColor.gray])
        if let queryLocation = suggestion.indexOf(query.lowercased()) {
            attributedSuggestion.addAttributes([NSAttributedString.Key.font: bold, NSAttributedString.Key.foregroundColor: UIColor.stepikPrimaryText], range: NSRange(location: queryLocation, length: query.count))
        }
        suggestionLabel.attributedText = attributedSuggestion
    }
}
