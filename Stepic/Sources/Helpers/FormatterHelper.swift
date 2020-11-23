import Foundation
import SwiftDate

enum FormatterHelper {
    /// Format number; 1000 -> "1K", 900 -> "900"
    static func longNumber(_ number: Int) -> String {
        number >= 1000
            ? "\(String(format: "%.1f", Double(number) / 1000.0))K"
            : "\(number)"
    }

    /// Format integer number with percent sign; 50 -> "50%"
    static func integerPercent(_ number: Int) -> String {
        "\(number)%"
    }

    /// Format floating point number with percent sign; 0.5 -> "50%"
    static func integerPercent(_ float: Float) -> String {
        FormatterHelper.integerPercent(Int(float * 100))
    }

    /// Format floating point rating with 2 decimal points; 0.123456 -> "0.12"
    static func averageRating(_ number: Float) -> String {
        String(format: "%.2f", number)
    }

    /// Format Progress's score value with 2 decimal points if has decimals; 0.123456 -> "0.12", 1.0 -> "1"
    static func progressScore(_ score: Float) -> String {
        let hasDecimals = score.truncatingRemainder(dividingBy: 1) != 0
        return hasDecimals ? String(format: "%.2f", score) : "\(Int(score))"
    }

    static func megabytesInBytes(_ bytes: UInt64, checkForLessThanOne: Bool = true) -> String {
        let megabytesTotal = bytes / 1024 / 1024

        var prefix = ""
        if megabytesTotal < 1 && checkForLessThanOne {
            prefix = "< "
        }

        let adjustedMegabytes = max(1, megabytesTotal)

        return "\(prefix)\(adjustedMegabytes) \(NSLocalizedString("Mb", comment: ""))"
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

    /// Format courses count with localized and pluralized suffix.
    ///
    /// 1 -> "1 course", 5 -> "5 courses"
    /// 100 -> "99+ courses"
    static func catalogBlockCoursesCount(_ count: Int) -> String {
        if count > 99 {
            return "99+ \(NSLocalizedString("courses567890", comment: ""))"
        }

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

    /// Format points count with localized and pluralized suffix; 1 -> "1 point", 5 -> "5 points"
    static func pointsCount(_ count: Int) -> String {
        let pluralizedCountString = StringHelper.pluralize(
            number: count,
            forms: [
                NSLocalizedString("points1", comment: ""),
                NSLocalizedString("points234", comment: ""),
                NSLocalizedString("points567890", comment: "")
            ]
        )
        return "\(count) \(pluralizedCountString)"
    }

    /// Format days count with localized and pluralized suffix; 1 -> "1 day", 5 -> "5 days"
    static func daysCount(_ count: Int) -> String {
        let pluralizedCountString = StringHelper.pluralize(
            number: count,
            forms: [
                NSLocalizedString("days1", comment: ""),
                NSLocalizedString("days234", comment: ""),
                NSLocalizedString("days567890", comment: "")
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

    /// Format a date to a string representation relative to another reference date (default current).
    static func dateToRelativeString(_ date: Date, referenceDate: Date = Date()) -> String {
        date.in(region: .UTC).toRelative(
            since: DateInRegion(referenceDate, region: .UTC),
            style: RelativeFormatter.defaultStyle(),
            locale: Locales.current
        )
    }

    /// Format download video quality to a string representation; `DownloadVideoQuality.medium` -> "360p"
    static func downloadVideoQualityInProgressiveScan(_ quality: DownloadVideoQuality) -> String {
        "\(quality.rawValue)p"
    }

    /// Format download video quality with localized and human readable format; `DownloadVideoQuality.low` -> "Low (270p)"
    static func humanReadableDownloadVideoQuality(_ quality: DownloadVideoQuality) -> String {
        let suffix = "(\(Self.downloadVideoQualityInProgressiveScan(quality)))"
        switch quality {
        case .low:
            return "\(NSLocalizedString("SettingDownloadVideoQualityLow", comment: "")) \(suffix)"
        case .medium:
            return "\(NSLocalizedString("SettingDownloadVideoQualityMedium", comment: "")) \(suffix)"
        case .high:
            return "\(NSLocalizedString("SettingDownloadVideoQualityHigh", comment: "")) \(suffix)"
        case .veryHigh:
            return "\(NSLocalizedString("SettingDownloadVideoQualityVeryHigh", comment: "")) \(suffix)"
        }
    }

    /// Format stream video quality to a string representation; `StreamVideoQuality.medium` -> "360p"
    static func streamVideoQualityInProgressiveScan(_ quality: StreamVideoQuality) -> String {
        "\(quality.rawValue)p"
    }

    /// Format stream video quality with localized and human readable format; `StreamVideoQuality.low` -> "Low (270p)"
    static func humanReadableStreamVideoQuality(_ quality: StreamVideoQuality) -> String {
        let suffix = "(\(Self.streamVideoQualityInProgressiveScan(quality)))"
        switch quality {
        case .low:
            return "\(NSLocalizedString("SettingStreamVideoQualityLow", comment: "")) \(suffix)"
        case .medium:
            return "\(NSLocalizedString("SettingStreamVideoQualityMedium", comment: "")) \(suffix)"
        case .high:
            return "\(NSLocalizedString("SettingStreamVideoQualityHigh", comment: "")) \(suffix)"
        case .veryHigh:
            return "\(NSLocalizedString("SettingStreamVideoQualityVeryHigh", comment: "")) \(suffix)"
        }
    }

    static func prettyVersion(versionNumber: String?, buildNumber: String?) -> String {
        guard let version = versionNumber else {
            return NSLocalizedString("AppVersionUnknownTitle", comment: "")
        }

        let build = buildNumber ?? "0"

        return String(
            format: NSLocalizedString("AppVersionTitle", comment: ""),
            arguments: [version, build]
        )
    }
}
