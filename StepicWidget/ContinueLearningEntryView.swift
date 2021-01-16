import SwiftUI
import WidgetKit

struct ContinueLearningEntryView: View {
    let entries: [UserCourseEntry]

    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            SmallContinueLearningView(entry: entries.first)
        default:
            MediumContinueLearningView(entries: entries)
        }
    }
}

struct UserCourseEntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContinueLearningEntryView(entries: [.snapshotEntry])
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            ContinueLearningEntryView(entries: [.snapshotEntry])
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .dark)

            ContinueLearningEntryView(entries: [.snapshotEntry])
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            ContinueLearningEntryView(entries: [.snapshotEntry])
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)
        }
    }
}
