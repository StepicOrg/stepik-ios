//
//  PinsMapView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 05.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class PinsMapView: UIView {
    let spacingDays = CGFloat(1.0)
    let spacingWeeks = CGFloat(1.0)
    let spacingMonths = CGFloat(10.0)

    enum Day {
        var color: UIColor {
            switch self {
            case .empty:
                return UIColor.clear
            default:
                return UIColor(hex: 0xeeeeee)
            }
        }

        case empty
        case solved(pin: Int)
    }

    convenience init(months: [PinsMap.Month]) {
        self.init()

        let monthsView = buildMonths(months)
        self.addSubview(monthsView)

        monthsView.align(toView: self)
    }

    private func buildStackView(with views: [UIView], axis: UILayoutConstraintAxis, spacing: CGFloat) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.distribution = .fillEqually
        stackView.alignment = .fill

        return stackView
    }

    private func buildDay(isAllowed: Bool, pin: Int) -> UIView {
        let day = !isAllowed ? Day.empty : Day.solved(pin: pin)
        let dayView = UIView()
        dayView.backgroundColor = day.color
        return dayView
    }

    private func buildWeek(_ week: PinsMap.Week) -> UIStackView {
        let days = zip(week.allowedPins, week.pins).map { buildDay(isAllowed: $0, pin: $1) }
        return buildStackView(with: days, axis: .vertical, spacing: spacingDays)
    }

    private func buildMonth(_ month: PinsMap.Month) -> UIStackView {
        let weeks = month.weeks.map { buildWeek($0) }
        return buildStackView(with: weeks, axis: .horizontal, spacing: spacingWeeks)
    }

    private func buildMonths(_ months: [PinsMap.Month]) -> UIStackView {
        return buildStackView(with: months.map({ buildMonth($0) }), axis: .horizontal, spacing: spacingMonths)
    }
}
