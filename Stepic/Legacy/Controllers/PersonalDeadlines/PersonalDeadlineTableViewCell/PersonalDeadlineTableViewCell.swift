//
//  PersonalDeadlineTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class PersonalDeadlineTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.colorize()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    func initWith(data: SectionDeadlineData) {
        self.titleLabel.text = data.title
        self.deadlineLabel.text = "\(NSLocalizedString("PersonalDeadline", comment: "")) \(data.deadline.getStepicFormatString(withTime: true))"
    }

    private func colorize() {
        self.titleLabel.textColor = .stepikPrimaryText
        self.deadlineLabel.textColor = .stepikLightBlue
    }
}
