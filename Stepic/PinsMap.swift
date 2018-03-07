//
//  PinsMap.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 05.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class PinsMap {

    private var calendar: Calendar

    init(calendar: Calendar = Calendar.current) {
        self.calendar = calendar
        self.calendar.minimumDaysInFirstWeek = 1

        if let utcTimeZone = TimeZone(abbreviation: "UTC") {
            self.calendar.timeZone = utcTimeZone
        }
    }

    class Week: Equatable {
        // allowedPins[i] == false when the day should be displayed as empty day
        // e. g. a day from previous month
        var allowedPins: [Bool] = (1...7).map { _ in false }
        var pins: [Int] = (1...7).map { _ in 0 }

        init() { }

        init(allowedPins: [Bool], pins: [Int]) {
            self.allowedPins = allowedPins
            self.pins = pins
        }

        public static func == (lhs: Week, rhs: Week) -> Bool {
            return lhs.allowedPins == rhs.allowedPins && lhs.pins == rhs.pins
        }
    }

    class Month {
        var weeks: [Week] = []

        var days: [(Bool, Int)] {
            return weeks.map { zip($0.allowedPins, $0.pins) }.reduce([], +)
        }

        init(weeks: [Week]) {
            self.weeks = weeks
        }

        open func shifted(firstWeekDay: Int) -> Month {
            var i = 0
            // Copy array
            var weeks = Array(self.weeks.map { Week(allowedPins: $0.allowedPins, pins: $0.pins) })

            for week in weeks {
                weeks[i].allowedPins = week.allowedPins.shifted(by: 1 - firstWeekDay)
                weeks[i].pins = week.pins.shifted(by: 1 - firstWeekDay)
                i += 1
            }
            return Month(weeks: weeks)
        }

        open func filled(pins: [Int]) -> Month {
            var week = 0, day = 0, pin = 0
            // Copy array
            var weeks = Array(self.weeks.map { Week(allowedPins: $0.allowedPins, pins: $0.pins) })

            while week < weeks.count {
                if weeks[week].allowedPins[day] && pin < pins.count {
                    weeks[week].pins[day] = pins[pin]
                    pin += 1
                }

                if day == 6 {
                    week += 1
                    day = 0
                } else {
                    day += 1
                }
            }

            return Month(weeks: weeks)
        }

        open func trimmed(daysCount: Int) -> Month {
            var week = 0, day = 0, days = daysCount
            // Copy array
            var weeks = Array(self.weeks.map { Week(allowedPins: $0.allowedPins, pins: $0.pins) })

            while week < weeks.count {
                if days > 0 {
                    if weeks[week].allowedPins[day] {
                        days -= 1
                    }
                } else {
                    weeks[week].allowedPins[day] = false
                }

                if day == 6 {
                    week += 1
                    day = 0
                } else {
                    day += 1
                }
            }
            return Month(weeks: weeks)
        }
    }

    func buildMonth(year: Int, month: Int, lastDay: Date? = nil) throws -> Month {
        var components = DateComponents()
        components.month = month
        components.year = year

        guard let firstDayOfMonth = calendar.date(from: components),
              let monthDaysRange = calendar.range(of: .day, in: .month, for: firstDayOfMonth),
              let lastDayOfMonth = calendar.date(byAdding: .day, value: monthDaysRange.count - 1, to: firstDayOfMonth, wrappingComponents: false) else {
            throw PinsMapError.badCalendar
        }

        // Fill month with assumption then first weekday has index == 1
        let weekNumForLastDayOfMonth = calendar.component(.weekOfMonth, from: lastDayOfMonth)
        var weeks = (1...weekNumForLastDayOfMonth).map { _ in Week() }
        for dayNum in monthDaysRange.lowerBound..<monthDaysRange.upperBound {
            guard let currentDay = calendar.date(byAdding: .day, value: dayNum - 1, to: firstDayOfMonth, wrappingComponents: false) else {
                throw PinsMapError.badCalendar
            }

            let weekday = calendar.component(.weekday, from: currentDay)
            let weeknum = calendar.component(.weekOfMonth, from: currentDay)

            if weeknum <= 0 || weeknum > weekNumForLastDayOfMonth || weekday <= 0 || weekday >= monthDaysRange.upperBound {
                throw PinsMapError.badCalendar
            }

            weeks[weeknum - 1].allowedPins[weekday - 1] = true
        }

        // Shift weeks for real first weekday
        weeks = Month(weeks: weeks).shifted(firstWeekDay: calendar.firstWeekday).weeks

        // Trim for partial month
        if let dayToTrim = lastDay,
           dayToTrim >= firstDayOfMonth && dayToTrim < lastDayOfMonth {
            let howManyDaysWeShouldKeep = (calendar.dateComponents([.day], from: firstDayOfMonth, to: dayToTrim).day ?? 0) + 1
            return Month(weeks: weeks).trimmed(daysCount: howManyDaysWeShouldKeep)
        }

        return Month(weeks: weeks)
    }

    func splitPinsIntoMonths(pins: [Int], today: Date = Date()) throws -> [[Int]] {
        guard pins.count > 0 else {
            return []
        }

        var month = calendar.component(.month, from: today), day = today
        var buckets = [[Int]]()
        var bucket = [Int]()
        for pin in pins {
            let currentMonth = calendar.component(.month, from: day)
            if month != currentMonth {
                buckets.append(bucket)
                bucket.removeAll()
            }
            bucket.append(pin)
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day, wrappingComponents: false) else {
                throw PinsMapError.badCalendar
            }
            day = yesterday
            month = currentMonth
        }
        buckets.append(bucket)
        return buckets
    }
}

enum PinsMapError: Error {
    case badCalendar
}
