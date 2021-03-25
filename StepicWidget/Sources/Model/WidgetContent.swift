import UIKit
import WidgetKit

struct WidgetContent: TimelineEntry {
    var date = Date()
    let userCourses: [WidgetUserCourse]
}

extension WidgetContent {
    static var snapshotEntry: WidgetContent {
        WidgetContent(
            userCourses: [
                .snapshotEntry,
                Self.makeThumbnailSnapshotEntry(imageName: "cover-58852"),
                Self.makeThumbnailSnapshotEntry(imageName: "cover-54849"),
                Self.makeThumbnailSnapshotEntry(imageName: "cover-54403")
            ]
        )
    }

    private static func makeThumbnailSnapshotEntry(imageName: String) -> WidgetUserCourse {
        WidgetUserCourse(
            id: imageName.hash,
            title: "",
            subtitle: "",
            progress: 0,
            thumbnailData: UIImage(named: imageName)?.jpegData(compressionQuality: 0.9)
        )
    }
}
