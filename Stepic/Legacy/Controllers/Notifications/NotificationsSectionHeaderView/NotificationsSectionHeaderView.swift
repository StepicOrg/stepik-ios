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
    @IBOutlet var topSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomSeparatorHeightConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        self.topSeparatorHeightConstraint.constant = 0.5
        self.bottomSeparatorHeightConstraint.constant = 0.5

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
        self.backgroundColorView.backgroundColor = self.isDarkInterfaceStyle
            ? .stepikSecondaryBackground
            : .stepikBackground

        self.leftLabel.textColor = .stepikPrimaryText
        self.rightLabel.textColor = .stepikPrimaryText
        self.topSeparatorView.backgroundColor = .stepikOpaqueSeparator
        self.bottomSeparatorView.backgroundColor = .stepikOpaqueSeparator
    }
}
