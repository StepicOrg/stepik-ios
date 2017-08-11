//
//  SearchSuggestionTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class SearchSuggestionTableViewCell: UITableViewCell {

    @IBOutlet weak var suggestionLabel: UILabel!

    var suggestion: String = "" {
        didSet {
            suggestionLabel.text = suggestion
        }
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
