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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initWith(data: SectionDeadlineData) {
        titleLabel.text = data.title
        deadlineLabel.text = "Personal deadline \(data.deadline.getStepicFormatString(withTime: true))"
    }
}
