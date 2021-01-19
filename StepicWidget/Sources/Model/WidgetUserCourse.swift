import Foundation

struct WidgetUserCourse: Codable {
    let id: Int
    let title: String
    let subtitle: String
    let progress: Float
    let thumbnailData: Data?
}
