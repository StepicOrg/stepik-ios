import WidgetKit
import SwiftUI

@main
struct StepicWidget: Widget {
    let kind: String = "StepicWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetContentProvider()) { entry in
            ContinueLearningEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct StepicWidget_Previews: PreviewProvider {
    static var previews: some View {
        ContinueLearningEntryView(entry: .snapshotEntry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        ContinueLearningEntryView(entry: .snapshotEntry)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
