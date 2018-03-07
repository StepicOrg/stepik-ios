//
//  PinsMapMonthView.swift
//  Stepic
//
//  Created by jetbrains on 06/03/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class PinsMapMonthView: NibInitializableView {
    @IBOutlet weak var monthLabel: StepikLabel!
    @IBOutlet weak var monthStackView: UIStackView!

    override var nibName: String {
        return "PinsMapMonthView"
    }

    var weeksStackView: [UIStackView] {
        return monthStackView.subviews.flatMap({ $0 as? UIStackView })
    }

    enum Day {
        var color: UIColor {
            switch self {
            case .empty:
                return UIColor.clear
            case .solved(let pin):
                switch pin {
                case let x where x > 24:
                    return UIColor(hex: 0x70A170)
                case let x where x > 9:
                    return UIColor(hex: 0x89CC89)
                case let x where x > 4:
                    return UIColor(hex: 0xA4D0A4)
                case let x where x > 0:
                    return UIColor(hex: 0xCAEACA)
                default:
                    return UIColor(hex: 0xeeeeee)
                }
            }
        }

        case empty
        case solved(pin: Int)
    }

    override func setupSubviews() {
        monthLabel.colorMode = .dark
        monthLabel.font = UIFont.systemFont(ofSize: 12, weight: .light)

        for week in weeksStackView {
            for day in week.subviews {
                day.layer.cornerRadius = 2
                day.clipsToBounds = true
                day.backgroundColor = Day.empty.color
            }
        }
    }

    func set(days: [Day]) {
        var i = 0
        for week in weeksStackView {
            for day in week.subviews {
                if i == days.count {
                    break
                }
                day.backgroundColor = days[i].color
                i += 1
            }
        }
    }

    func set(monthTitle: String, days: [Day]) {
        monthLabel.text = monthTitle
        set(days: days)
    }
}
