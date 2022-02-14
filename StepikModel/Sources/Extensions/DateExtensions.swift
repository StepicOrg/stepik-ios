import Foundation

extension DateFormatter {
    private static let stepikISO8601Short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC") ?? TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let stepikISO8601Medium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC") ?? TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let stepikISO8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss.SSS a'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC") ?? TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static var allStepikISO8601: [DateFormatter] {
        [self.stepikISO8601Short, self.stepikISO8601Medium, self.stepikISO8601Full]
    }

    static func parsedStepikISO8601Date(from dateString: String) -> Date? {
        for dateFormatter in self.allStepikISO8601 {
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }
}
