import Foundation

enum WidgetConstants {
    static let maxUserCoursesCount = 6
    static let timelineUpdateTimeInterval: TimeInterval = 1800

    enum URL {
        static let scheme = "https"
        static let host = "stepik.org"
        static let stepikURL = "\(Self.scheme)://\(Self.host)"

        static let widgetHost = "stepik.widget.link"
        static let widgetURL = "\(Self.scheme)://\(Self.widgetHost)"
    }
}
