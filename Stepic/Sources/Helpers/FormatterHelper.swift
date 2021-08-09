import Foundation
import SwiftDate

enum FormatterHelper {
    // MARK: Numbers

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

    /// Format Submission's score with 2 decimal points if has decimals; 0.75 -> "0.75", 1.0 -> "1"
    static func submissionScore(_ score: Float) -> String {
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

    static func price(_ price: Float, currencyCode: String) -> String {
        self.price(price, currencySymbol: CurrencySymbolMap.getSymbolFromCurrency(code: currencyCode) ?? currencyCode)
    }

    static func price(_ price: Float, currencySymbol: String) -> String {
        let hasDecimals = price.truncatingRemainder(dividingBy: 1) != 0
        let priceString = hasDecimals ? String(format: "%.2f", price) : "\(Int(price))"
        return "\(priceString) \(currencySymbol)"
    }

    // MARK: Count

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

    /// Format points count with localized and pluralized suffix; 17.2 -> "17.2 points", 1 -> "1 point", 5 -> "5 points"
    static func pointsCount(_ count: Float) -> String {
        let hasDecimals = count.truncatingRemainder(dividingBy: 1) != 0
        return hasDecimals
            ? "\(String(format: "%.2f", count)) \(NSLocalizedString("points234", comment: ""))"
            : self.pointsCount(Int(count))
    }

    /// Format authors count with localized and pluralized suffix; 1 -> "1 author", 5 -> "5 authors"
    static func authorsCount(_ count: Int) -> String {
        let pluralizedCountString = StringHelper.pluralize(
            number: count,
            forms: [
                NSLocalizedString("authors1", comment: ""),
                NSLocalizedString("authors234", comment: ""),
                NSLocalizedString("authors567890", comment: "")
            ]
        )
        return "\(count) \(pluralizedCountString)"
    }

    /// Format followers count with localized and pluralized suffix.
    ///
    /// 1 -> "1 follower", 5 -> "5 followers", 1000 -> "1K followers"
    static func longFollowersCount(_ count: Int) -> String {
        if count >= 1000 {
            let thousands = Float(count) / 1000.0
            let fractionalPart = thousands.truncatingRemainder(dividingBy: 1)

            if fractionalPart >= 0.1 {
                return "\(String(format: "%.1f", thousands))K \(NSLocalizedString("followers567890", comment: ""))"
            } else {
                return "\(Int(thousands))K \(NSLocalizedString("followers567890", comment: ""))"
            }
        } else {
            let pluralizedCountString = StringHelper.pluralize(
                number: count,
                forms: [
                    NSLocalizedString("followers1", comment: ""),
                    NSLocalizedString("followers234", comment: ""),
                    NSLocalizedString("followers567890", comment: "")
                ]
            )
            return "\(count) \(pluralizedCountString)"
        }
    }

    /// Format reviews count with localized and pluralized suffix; 1 -> "1 review", 5 -> "5 reviews"
    static func reviewsCount(_ count: Int) -> String {
        let pluralizedCountString = StringHelper.pluralize(
            number: count,
            forms: [
                NSLocalizedString("reviews1", comment: ""),
                NSLocalizedString("reviews234", comment: ""),
                NSLocalizedString("reviews567890", comment: "")
            ]
        )
        return "\(count) \(pluralizedCountString)"
    }

    /// Format reviews count with localized and pluralized suffix; 1 -> "1 new course for review", 5 -> "5 new courses for review"
    static func userCoursesReviewsPossibleReviewsCount(_ count: Int) -> String {
        let pluralizedCountString = StringHelper.pluralize(
            number: count,
            forms: [
                NSLocalizedString("UserCoursesReviewsPossibleReviews1", comment: ""),
                NSLocalizedString("UserCoursesReviewsPossibleReviews234", comment: ""),
                NSLocalizedString("UserCoursesReviewsPossibleReviews567890", comment: "")
            ]
        )
        return "\(count) \(pluralizedCountString)"
    }

    /// Format reviews count with localized and pluralized suffix; 1 -> "1 review", 5 -> "5 reviews"
    static func reviewSummariesCount(_ count: Int) -> String {
        let pluralizedCountString = StringHelper.pluralize(
            number: count,
            forms: [
                NSLocalizedString("reviewSummaries1", comment: ""),
                NSLocalizedString("reviewSummaries234", comment: ""),
                NSLocalizedString("reviewSummaries567890", comment: "")
            ]
        )
        return "\(count) \(pluralizedCountString)"
    }

    /// Format submissions count with localized and pluralized suffix; 1 -> "1 submission", 5 -> "5 submissions"
    static func submissionsCount(_ count: Int) -> String {
        let pluralizedCountString = StringHelper.pluralize(
            number: count,
            forms: [
                NSLocalizedString("submissions1", comment: ""),
                NSLocalizedString("submissions234", comment: ""),
                NSLocalizedString("submissions567890", comment: "")
            ]
        )
        return "\(count) \(pluralizedCountString)"
    }

    // MARK: Date

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

    /// Format minutes count with localized and pluralized suffix; 1 -> "1 minute", 5 -> "5 minutes"
    static func minutesCount(_ count: Int) -> String {
        let pluralizedCountString = StringHelper.pluralize(
            number: count,
            forms: [
                NSLocalizedString("minutes1", comment: ""),
                NSLocalizedString("minutes234", comment: ""),
                NSLocalizedString("minutes567890", comment: "")
            ]
        )
        return "\(count) \(pluralizedCountString)"
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

    /// Format date with full month and year; "18 October 2018 00:00"
    static func dateStringWithFullMonthAndYear(_ dateInRegion: DateInRegion) -> String {
        dateInRegion.toFormat("dd MMMM yyyy HH:mm")
    }

    /// Format a date to a string representation relative to another reference date (default current).
    static func dateToRelativeString(_ date: Date, referenceDate: Date = Date()) -> String {
        date.in(region: .UTC).toRelative(
            since: DateInRegion(referenceDate, region: .UTC),
            style: RelativeFormatter.defaultStyle(),
            locale: Locales.current
        )
    }

    // MARK: Video

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

    // MARK: Titles

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

    /// Format lesson title with section and unit positions
    static func lessonTitle(_ lesson: Lesson) -> String {
        guard let unit = lesson.unit,
              let section = unit.section else {
            return lesson.title
        }

        return "\(section.position).\(unit.position) \(lesson.title)"
    }

    /// Format username with full name otherwise with user id.
    static func username(_ user: User) -> String {
        user.fullName.isEmpty ? "User \(user.id)" : user.fullName
    }

    /// Format username with full name otherwise with user id.
    static func username(_ userInfo: UserInfo) -> String {
        let fullName = "\(userInfo.firstName) \(userInfo.lastName)".trimmed()
        return fullName.isEmpty ? "User \(userInfo.id)" : fullName
    }
}
