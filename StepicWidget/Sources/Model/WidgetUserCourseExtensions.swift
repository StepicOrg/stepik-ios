import WidgetKit

extension WidgetUserCourse: Identifiable {}

extension WidgetUserCourse {
    var url: URL {
        WidgetURL.course(id: self.id).url
    }
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
