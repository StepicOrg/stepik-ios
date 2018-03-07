//
//  PinsMapView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 05.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class PinsMapView: NibInitializableView {
    @IBOutlet weak var monthsStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!

    var hasMonths: Bool = false
    var storedMonths: [(PinsMap.Month, PinsMapMonthView)] = []

    override var nibName: String {
        return "PinsMapView"
    }

    private var howManyMonthsShouldBeDisplayed: Int {
        switch DeviceInfo.current.diagonal {
        case let x where x > 5.8:
            return DeviceInfo.current.orientation.interface.isPortrait ? 8 : 8
        case let x where x > 4.7:
            return DeviceInfo.current.orientation.interface.isPortrait ? 6 : 8
        case let x where x > 4.0:
            return DeviceInfo.current.orientation.interface.isPortrait ? 4 : 8
        default:
            return DeviceInfo.current.orientation.interface.isPortrait ? 3 : 8
        }
    }

    private func buildDays(for month: PinsMap.Month, pins: [Int]) -> [PinsMapMonthView.Day] {
        var days = [PinsMapMonthView.Day]()
        for (isAllowed, pin) in month.filled(pins: pins).days {
            days.append(isAllowed ? PinsMapMonthView.Day.solved(pin: pin) : PinsMapMonthView.Day.empty)
        }
        return days
    }

    private func buildMonth(_ month: PinsMap.Month, title: String, pins: [Int]) -> PinsMapMonthView {
        let view = PinsMapMonthView()
        view.set(monthTitle: title, days: buildDays(for: month, pins: pins))
        return view
    }

    func buildMonths(_ pins: [Int]) {
        let today = Date()
        let calendar = Calendar.current

        let pinsMap = PinsMap(calendar: calendar)
        let monthsNames = calendar.standaloneMonthSymbols

        var splittedPins = (try? pinsMap.splitPinsIntoMonths(pins: pins, today: today)) ?? []
        if hasMonths {
            // Update existing
            for (month, view) in storedMonths {
                var pinsForCurrentMonth = splittedPins.first
                if pinsForCurrentMonth != nil {
                    splittedPins = Array(splittedPins.dropFirst())
                } else {
                    pinsForCurrentMonth = []
                }

                view.set(days: buildDays(for: month, pins: pinsForCurrentMonth!.reversed()))
            }
            return
        }

        // Build new
        var year = calendar.component(.year, from: today)
        var month = calendar.component(.month, from: today)
        var affectedMonths = [(Int, Int)]()
        while affectedMonths.count < 12 {
            affectedMonths.append((year, month))
            month -= 1
            if month == 0 {
                year -= 1
                month = 12
            }
        }

        for (year, month) in affectedMonths {
            guard let bmonth = try? pinsMap.buildMonth(year: year, month: month, lastDay: today) else {
                continue
            }

            var pinsForCurrentMonth = splittedPins.last
            if pinsForCurrentMonth != nil {
                _ = splittedPins.dropLast()
            } else {
                pinsForCurrentMonth = []
            }

            let monthView = buildMonth(bmonth, title: monthsNames[month - 1], pins: pinsForCurrentMonth!.reversed())
            storedMonths.append((bmonth, monthView))
        }

        storedMonths.reversed().map({ $0.1 }).forEach { view in
            monthsStackView.addArrangedSubview(view)
            self.hasMonths = true
        }
    }

    func clear() {
        hasMonths = false
        monthsStackView.subviews.forEach { view in
            monthsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }

    override func setupSubviews() {
        scrollView.delegate = self
    }

    override func layoutSubviews() {
        layoutIfNeeded()
        DispatchQueue.main.async {
            let width = (self.containerView.frame.width - CGFloat(self.howManyMonthsShouldBeDisplayed - 1) * self.monthsStackView.spacing) / CGFloat(self.howManyMonthsShouldBeDisplayed)
            for monthView in self.storedMonths.map({ $0.1 }).reversed() {
                monthView.constraints.forEach { constraint in
                    if constraint.firstAttribute == .width {
                        constraint.isActive = false
                    }
                }
                monthView.widthAnchor.constraint(equalToConstant: width).isActive = true
            }
            self.layoutIfNeeded()

            guard self.howManyMonthsShouldBeDisplayed - 1 >= 0 && self.howManyMonthsShouldBeDisplayed - 1 < self.storedMonths.count else {
                return
            }
            self.scrollView.contentOffset = CGPoint(x: self.storedMonths[self.howManyMonthsShouldBeDisplayed - 1].1.frame.origin.x, y: self.scrollView.contentOffset.y)
        }
    }
}

extension PinsMapView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)

        guard howManyMonthsShouldBeDisplayed * page < storedMonths.count else {
            return
        }

        let shouldBeVisibleX = storedMonths.reversed()[howManyMonthsShouldBeDisplayed * page].1.frame.origin.x

        UIView.animate(withDuration: 0.1) {
            self.scrollView.contentOffset = CGPoint(x: shouldBeVisibleX, y: self.scrollView.contentOffset.y)
        }
    }
}
