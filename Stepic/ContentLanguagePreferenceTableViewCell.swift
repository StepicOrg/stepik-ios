//
//  ContentLanguagePreferenceTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class ContentLanguagePreferenceTableViewCell: UITableViewCell {
    @IBOutlet weak var languageLabel: StepikLabel!

    var title: String? {
        didSet {
            self.languageLabel.text = self.title
        }
    }
}
