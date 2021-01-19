import SwiftUI
import WidgetKit

struct ContinueLearningEntryView: View {
    let entry: WidgetContent

    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            ContinueCourseView(course: entry.userCourses.first)
        default:
            ContinueCourseWithCourseListView(courses: entry.userCourses)
        }
    }
}

struct ContinueLearningEntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContinueLearningEntryView(entry: .snapshotEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            ContinueLearningEntryView(entry: .snapshotEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .dark)

            ContinueLearningEntryView(entry: .snapshotEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            ContinueLearningEntryView(entry: .snapshotEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)
        }
    }
}
