import Foundation

struct WidgetUserCourse: Codable {
    let id: Int
    let title: String
    let subtitle: String
    let progress: Float
    let thumbnailData: Data?
}

extension WidgetUserCourse {
    static let snapshotEntry = WidgetUserCourse(
        id: 5207,
        title: "Creating a course on Stepik",
        subtitle: "by Stepik Team",
        progress: 76.0,
        thumbnailData: nil
    )
}
