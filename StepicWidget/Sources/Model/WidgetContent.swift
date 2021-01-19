import WidgetKit

struct WidgetContent: TimelineEntry {
    var date: Date = Date()
    let userCourses: [WidgetUserCourse]
}

extension WidgetContent {
    static let snapshotEntry = WidgetContent(userCourses: [.snapshotEntry])
}
