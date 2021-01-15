import SwiftUI
import WidgetKit

struct UserCourseEntryView: View {
    let entry: UserCourseEntry

    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            SmallUserCourseView(entry: entry)
        default:
            MediumUserCourseView(entries: [entry])
        }
    }
}

struct UserCourseEntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UserCourseEntryView(entry: .snapshotEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            UserCourseEntryView(entry: .snapshotEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .dark)

            UserCourseEntryView(entry: .snapshotEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            UserCourseEntryView(entry: .snapshotEntry)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)
        }
    }
}
