//
//  NotificationsSectionHeaderView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class NotificationsSectionHeaderView: UITableViewHeaderFooterView {
    static let reuseId = "notificationsSectionHeaderView"

    private static let dateAndMonthDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM"
        return dateFormatter
    }()

    private static let humanReadbleWeekDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter
    }()

    @IBOutlet var backgroundColorView: UIView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet var topSeparatorView: UIView!
    @IBOutlet var bottomSeparatorView: UIView!

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

    func update(with date: Date) {
        self.leftLabel.text = Self.dateAndMonthDateFormatter.string(from: date)
        self.rightLabel.text = Self.humanReadbleWeekDateFormatter.string(from: date)
    }

    private func colorize() {
        if #available(iOS 13.0, *), self.traitCollection.userInterfaceStyle == .dark {
            self.backgroundColorView.backgroundColor = .stepikSecondaryBackground
        } else {
            self.backgroundColorView.backgroundColor = .stepikBackground
        }

        self.leftLabel.textColor = .stepikPrimaryText
        self.rightLabel.textColor = .stepikPrimaryText
        self.topSeparatorView.backgroundColor = .stepikSeparator
        self.bottomSeparatorView.backgroundColor = .stepikSeparator
    }
}
