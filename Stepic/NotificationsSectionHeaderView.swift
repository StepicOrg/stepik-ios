//
//  NotificationsSectionHeaderView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class NotificationsSectionHeaderView: UITableViewHeaderFooterView {
    static let reuseId = "notificationsSectionHeaderView"

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!

    func update(with date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM"
        leftLabel.text = formatter.string(from: date)

        formatter.dateFormat = "EEEE"
        rightLabel.text = formatter.string(from: date)
    }

}
