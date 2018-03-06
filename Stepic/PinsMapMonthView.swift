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
                case let x where x > 5:
                    return UIColor(hex: 0x89CC89)
                case let x where x > 0:
                    return UIColor(hex: 0xB8E0B8)
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

    func set(monthTitle: String, days: [Day]) {
        monthLabel.text = monthTitle

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
}
