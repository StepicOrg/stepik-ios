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

    func setup(contentLanguage: ContentLanguage) {
        self.languageLabel.text = contentLanguage.fullString
    }
}
