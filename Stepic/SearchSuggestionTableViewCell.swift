//
//  SearchSuggestionTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class SearchSuggestionTableViewCell: UITableViewCell {

    @IBOutlet weak var suggestionLabel: StepikLabel!

    func set(suggestion: String, query: String) {
        let fontSize: CGFloat = 17
        var bold = UIFont.boldSystemFont(ofSize: fontSize)
        bold = UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightMedium)
        let regular = UIFont.systemFont(ofSize: fontSize)
        let attributedSuggestion = NSMutableAttributedString(string: suggestion, attributes: [NSFontAttributeName: regular, NSForegroundColorAttributeName: UIColor.gray])
        if let queryLocation = suggestion.indexOf(query.lowercased()) {
            attributedSuggestion.addAttributes([NSFontAttributeName: bold, NSForegroundColorAttributeName: UIColor.mainTextColor], range: NSRange(location: queryLocation, length: query.characters.count))
        }
        suggestionLabel.attributedText = attributedSuggestion
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
