//
//  PersonalDeadlineTableViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class PersonalDeadlineTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var deadlineLabel: StepikLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        deadlineLabel.colorMode = .blue
        titleLabel.colorMode = .dark
    }

    func initWith(data: SectionDeadlineData) {
        titleLabel.text = data.title
        deadlineLabel.text = "\(NSLocalizedString("PersonalDeadline", comment: "")) \(data.deadline.getStepicFormatString(withTime: true))"
    }
}
