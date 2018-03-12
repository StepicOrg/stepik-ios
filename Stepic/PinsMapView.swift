//
//  PinsMapView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 11.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import FLKAutoLayout

class PinsMapView: UIView {
    enum Day {
        var color: UIColor {
            switch self {
            case .empty:
                return UIColor.clear
            case .solved(let pin):
                switch pin {
                case let x where x > 24:
                    return UIColor(hex: 0x578657)
                case let x where x > 9:
                    return UIColor(hex: 0x6EB36E)
                case let x where x > 4:
                    return UIColor(hex: 0x89CC89)
                case let x where x > 0:
                    return UIColor(hex: 0xB8E0B8)
                default:
                    return UIColor(hex: 0xEEEEEE)
                }
            }
        }

        case empty
        case solved(pin: Int)
    }

    private let border = CGFloat(18)
    private let monthSpacing = CGFloat(10)
    private let labelSpacing = CGFloat(8)
    private let daySpacing = CGFloat(1.5)

    private let daysInWeek = 7
    private let weeksInMonth = 5
    private let monthsInYear = 12

    private let calendar = Calendar.current

    private var howManyMonthsShouldBeDisplayed: Int {
        switch DeviceInfo.current.diagonal {
        case let x where x > 5.8:
            return DeviceInfo.current.orientation.interface.isPortrait ? 6 : 12
        case let x where x > 4.7:
            return DeviceInfo.current.orientation.interface.isPortrait ? 4 : 6
        case let x where x > 4.0:
            return DeviceInfo.current.orientation.interface.isPortrait ? 4 : 6
        default:
            return DeviceInfo.current.orientation.interface.isPortrait ? 3 : 6
        }
    }

    private var scrollView: UIScrollView?
    private var containerView: UIView?
    private var dayLayers: [[CALayer]] = []

    private var lastRenderedFrame: CGRect?
    private var cachedPins: [Int]?

    func buildMonths(_ pins: [Int]) {
        cachedPins = pins
        updateMonths()
    }

    private func updateMonth(days: [CALayer], month: PinsMap.Month, pins: [Int]) {
        for (day, (isAllowed, pin)) in zip(days, month.filled(pins: pins).days) {
            day.backgroundColor = isAllowed ? Day.solved(pin: pin).color.cgColor : Day.empty.color.cgColor
        }
    }

    private func getMonthsOfLastYear(today: Date) -> [(Int, Int)] {
        var year = calendar.component(.year, from: today)
        var month = calendar.component(.month, from: today)
        var affectedMonths = [(Int, Int)]()
        while affectedMonths.count < monthsInYear {
            affectedMonths.append((year, month))
            month -= 1
            if month == 0 {
                year -= 1
                month = monthsInYear
            }
        }

        return affectedMonths
    }

    private func updateMonths() {
        guard let pins = cachedPins else {
            return
        }

        let today = Date()
        let pinsMap = PinsMap(calendar: calendar)
        var splittedPins = (try? pinsMap.splitPinsIntoMonths(pins: pins, today: today)) ?? []

        let months = getMonthsOfLastYear(today: today)
        for (daysForCurrentMonth, (year, month)) in zip(dayLayers.reversed(), months) {
            guard let bmonth = try? pinsMap.buildMonth(year: year, month: month, lastDay: today) else {
                continue
            }

            var pinsForCurrentMonth = splittedPins.first
            if pinsForCurrentMonth != nil {
                splittedPins = Array(splittedPins.dropFirst())
            } else {
                pinsForCurrentMonth = []
            }

            updateMonth(days: daysForCurrentMonth, month: bmonth, pins: pinsForCurrentMonth!.reversed())
        }
    }

    private func initialize() {
        self.scrollView = UIScrollView()

        guard let scrollView = self.scrollView else {
            return
        }
        scrollView.alpha = 0.0
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)

        scrollView.alignTop("\(border)", leading: "\(border - monthSpacing / 2.0)", bottom: "\(-border)", trailing: "\(-border + monthSpacing / 2.0)", toView: self)
    }

    private func findMaxSide(rect: CGSize) -> CGFloat {
        let rectArea: CGFloat = rect.width * rect.height
        // Binary search with fixed iterations count
        let condition: (CGFloat) -> Bool = { (x: CGFloat) -> Bool in
            return (CGFloat(self.daysInWeek) * x <= rect.height) &&
                   (CGFloat(self.weeksInMonth) * x <= rect.width) &&
                   (CGFloat(self.daysInWeek * self.weeksInMonth) * x * x <= rectArea)
        }
        var left: CGFloat = 1
        var right: CGFloat = rect.width / 2
        for _ in 0..<Int(1e6) {
            let mid = (left + right) / 2.0
            if condition(mid) {
                left = mid
            } else {
                right = mid
            }
        }
        return (left + right) / 2.0
    }

    private func drawGrid() {
        let monthNames = Calendar.current.standaloneMonthSymbols

        // Create scrollView
        if self.scrollView == nil {
            initialize()
        }

        guard let scrollView = self.scrollView else {
            return
        }
        let frame = scrollView.frame

        // Prevent multiple drawing
        if lastRenderedFrame == frame {
            return
        } else {
            lastRenderedFrame = frame
        }

        // Remove old container
        dayLayers.removeAll(keepingCapacity: true)
        containerView?.removeFromSuperview()

        containerView = UIView()
        guard let containerView = containerView else {
            return
        }

        // Resize container view
        scrollView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.align(toView: scrollView)
        scrollView.constrainHeight(toView: containerView, predicate: "*1")
        containerView.constrainWidth("\(frame.width * CGFloat(ceil(Double(monthsInYear) / Double(howManyMonthsShouldBeDisplayed))))")

        // Create and resize month titles
        var monthsLabels = [StepikLabel]()
        for i in 0..<monthsInYear {
            let label = StepikLabel()
            label.font = UIFont.systemFont(ofSize: 12, weight: .light)
            label.colorMode = .dark
            label.text = monthNames[i]
            label.sizeToFit()
            monthsLabels.append(label)
        }
        let maxLabelHeight = monthsLabels.map({ $0.bounds.height }).max() ?? 0

        // Calculate month size (w/o spacing between months)
        let oneMonthWidth = (frame.width - CGFloat(howManyMonthsShouldBeDisplayed) * monthSpacing) / CGFloat(howManyMonthsShouldBeDisplayed)
        let oneMonthHeight = frame.height - labelSpacing - maxLabelHeight
        let oneMonthSize = CGSize(width: oneMonthWidth, height: oneMonthHeight)

        // Calculate month size (w/o spacing between months and days)
        let boundedHeight = CGFloat(oneMonthSize.height - CGFloat(daysInWeek - 1) * daySpacing)
        let boundedWidth = CGFloat(oneMonthSize.width - CGFloat(weeksInMonth - 1) * daySpacing)
        let daySide = findMaxSide(rect: CGSize(width: boundedWidth, height: boundedHeight))
        // We found max side for day-rect, so we should add unaccounted space
        let widthError = max(0, (oneMonthSize.width - (CGFloat(weeksInMonth) * daySide) - (CGFloat(weeksInMonth - 1) * daySpacing)) / 2)

        let halfSpacing = CGFloat(monthSpacing / 2.0)
        let monthsNums = getMonthsOfLastYear(today: Date()).reversed().map { $0.1 }

        var x = CGFloat(0)
        for i in 0..<monthsInYear {
            x += halfSpacing + widthError

            let labelX = x

            var y = CGFloat(0)
            var days: [CALayer] = []
            for week in 0..<weeksInMonth {
                y = CGFloat(0)
                for dayOfWeek in 0..<daysInWeek {
                    let dayRect = CALayer()
                    dayRect.cornerRadius = 2
                    dayRect.frame = CGRect(x: x, y: y, width: daySide, height: daySide)
                    dayRect.backgroundColor = Day.empty.color.cgColor
                    containerView.layer.addSublayer(dayRect)

                    days.append(dayRect)
                    y += daySide + (dayOfWeek < daysInWeek - 1 ? daySpacing : 0)
                }
                x += daySide + (week < weeksInMonth - 1 ? daySpacing : 0)
            }

            let labelY = y + labelSpacing
            let label = monthsLabels[monthsNums[i] - 1]
            containerView.addSubview(label)
            label.frame = CGRect(x: labelX, y: labelY, width: label.frame.width, height: label.frame.height)

            x += halfSpacing + widthError

            if i == monthsInYear - howManyMonthsShouldBeDisplayed - 1 {
                scrollView.contentOffset = CGPoint(x: x, y: scrollView.contentOffset.y)
            }

            dayLayers.append(days)
        }

        // Delay to prevent 'jumps' when layers not rendered
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIView.animate(withDuration: 0.2) {
                self.scrollView?.alpha = 1.0
            }
        }
        updateMonths()
    }

    override func layoutSubviews() {
        DispatchQueue.main.async {
            self.drawGrid()
        }
    }
}
