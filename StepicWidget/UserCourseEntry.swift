import WidgetKit

struct UserCourseEntry: Codable, TimelineEntry, Identifiable {
    var date: Date = Date()
    let id: Int
    let title: String
    let subtitle: String
    let progress: Float
    let thumbnailData: Data?
}

extension UserCourseEntry {
    static let snapshotEntry = UserCourseEntry(
        id: 5207,
        title: "Creating a course on Stepik",
        subtitle: "by Stepik Team",
        progress: 76.0,
        thumbnailData: nil
    )
}
