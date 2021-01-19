import WidgetKit

struct WidgetContent: TimelineEntry {
    var date: Date = Date()
    let userCourses: [WidgetUserCourse]
}

extension WidgetContent {
    static let snapshotEntry = WidgetContent(
        userCourses: [
            WidgetUserCourse(
                id: 5207,
                title: "Creating a course on Stepik",
                subtitle: "by Stepik Team",
                progress: 76.0,
                thumbnailData: nil
            )
        ]
    )
}
