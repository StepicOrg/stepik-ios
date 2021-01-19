import WidgetKit
import SwiftUI

@main
struct StepicWidget: Widget {
    let kind: String = "StepicWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetContentProvider()) { entry in
            ContinueLearningEntryView(entry: entry)
        }
        .configurationDisplayName("ConfigurationDisplayName")
        .description("ConfigurationDescription")
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
