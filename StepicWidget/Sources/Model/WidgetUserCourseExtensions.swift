import UIKit
import WidgetKit

extension WidgetUserCourse: Identifiable {}

extension WidgetUserCourse {
    var url: URL {
        WidgetURL.course(id: self.id).url
    }
}

extension WidgetUserCourse {
    static var snapshotEntry: WidgetUserCourse {
        WidgetUserCourse(
            id: 5207,
            title: NSLocalizedString("SnapshotUserCourseTitle", comment: ""),
            subtitle: NSLocalizedString("SnapshotUserCourseSubtitle", comment: ""),
            progress: 76.0,
            thumbnailData: UIImage(named: "cover-5207")?.jpegData(compressionQuality: 0.9)
        )
    }
}
