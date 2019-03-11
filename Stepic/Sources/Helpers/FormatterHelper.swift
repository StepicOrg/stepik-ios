import Foundation

enum FormatterHelper {
    /// Format number; 1000 -> "1K", 900 -> "900"
    static func longNumber(_ number: Int) -> String {
        return number >= 1000
            ? "\(String(format: "%.1f", Double(number) / 1000.0))K"
            : "\(number)"
    }

    /// Format integer number with percent sign; 50 -> "50%"
    static func integerPercent(_ number: Int) -> String {
        return "\(number)%"
    }

    /// Format floating point number with percent sign; 0.5 -> "50%"
    static func integerPercent(_ float: Float) -> String {
        return FormatterHelper.integerPercent(Int(float * 100))
    }

    /// Format floating point rating with 2 decimal points; 0.123456 -> "0.12"
    static func averageRating(_ number: Float) -> String {
        return String(format: "%.2f", number)
    }

    /// Format courses count with localized and pluralized suffix; 1 -> "1 course", 5 -> "5 courses"
    static func coursesCount(_ count: Int) -> String {
        let pluralizedCountString = StringHelper.pluralize(
            number: count,
            forms: [
                NSLocalizedString("courses1", comment: ""),
                NSLocalizedString("courses234", comment: ""),
                NSLocalizedString("courses567890", comment: "")
            ]
        )
        return "\(count) \(pluralizedCountString)"
    }

    /// Format hours count with localized and pluralized suffix; 1 -> "1 hour", 5 -> "5 hours"
    static func hoursInSeconds(_ seconds: TimeInterval) -> String {
        let hour = 3600.0
        let hours = Int(ceil(seconds / hour))

        let pluralizedHoursString = StringHelper.pluralize(
            number: hours,
            forms: [
                NSLocalizedString("hours1", comment: ""),
                NSLocalizedString("hours234", comment: ""),
                NSLocalizedString("hours567890", comment: "")
            ]
        )

        return "\(hours) \(pluralizedHoursString)"
    }

    /// Format date with full month and year; "18 October 2018 00:00"
    static func dateStringWithFullMonthAndYear(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy HH:mm"

        return dateFormatter.string(from: date)
    }
}
