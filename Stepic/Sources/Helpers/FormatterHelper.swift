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
    static func hoursInSeconds(_ seconds: TimeInterval, roundingRule: FloatingPointRoundingRule = .up) -> String {
        let hour = 3600.0
        let hours = Int((seconds / hour).rounded(roundingRule))

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

    /// Format minutes count with localized and pluralized suffix; 1 -> "1 minute", 5 -> "5 minutes"
    static func minutesInSeconds(_ seconds: TimeInterval, roundingRule: FloatingPointRoundingRule = .up) -> String {
        let minute = 60.0
        let minutes = Int((seconds / minute).rounded(roundingRule))

        let pluralizedMinutesString = StringHelper.pluralize(
            number: minutes,
            forms: [
                NSLocalizedString("minutes1", comment: ""),
                NSLocalizedString("minutes234", comment: ""),
                NSLocalizedString("minutes567890", comment: "")
            ]
        )

        return "\(minutes) \(pluralizedMinutesString)"
    }

    /// Format seconds with localized and pluralized suffix; 1 -> "1 second", 5 -> "5 seconds"
    static func seconds(_ seconds: TimeInterval, roundingRule: FloatingPointRoundingRule = .up) -> String {
        let seconds = Int(seconds.rounded(roundingRule))

        let pluralizedHoursString = StringHelper.pluralize(
            number: seconds,
            forms: [
                NSLocalizedString("seconds1", comment: ""),
                NSLocalizedString("seconds234", comment: ""),
                NSLocalizedString("seconds567890", comment: "")
            ]
        )

        return "\(seconds) \(pluralizedHoursString)"
    }

    /// Format date with full month and year; "18 October 2018 00:00"
    static func dateStringWithFullMonthAndYear(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy HH:mm"

        return dateFormatter.string(from: date)
    }
}
