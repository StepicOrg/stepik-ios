import SwiftUI
import WidgetKit

@main
struct StepicWidget: Widget {
    let kind: String = "StepicWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetContentProvider.default) { entry in
            ContinueLearningEntryView(entry: entry)
        }
        .configurationDisplayName("ConfigurationDisplayName")
        .description("ConfigurationDescription")
        .supportedFamilies([.systemSmall, .systemMedium])
        .safeContentMarginsDisabled()
    }
}

extension View {
    @ViewBuilder
    func safeContainerBackground(@ViewBuilder content: () -> some View) -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(for: .widget, content: content)
        } else {
            self.background(content())
        }
    }
}

extension WidgetConfiguration {
    func safeContentMarginsDisabled() -> some WidgetConfiguration {
        if #available(iOS 15.0, *) {
            return contentMarginsDisabled()
        } else {
            return self
        }
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
