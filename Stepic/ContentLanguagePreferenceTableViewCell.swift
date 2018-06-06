//
//  ContentLanguagePreferenceTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class ContentLanguagePreferenceTableViewCell: UITableViewCell {

    @IBOutlet weak var languageLabel: StepikLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setup(contentLanguage: ContentLanguage) {
        self.languageLabel.text = contentLanguage.fullString
    }
}
