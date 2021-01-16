import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    typealias Entry = WidgetContent

    func placeholder(in context: Context) -> WidgetContent {
        .snapshotEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetContent) -> Void) {
        let entry = WidgetContent.snapshotEntry
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries: [WidgetContent] = [WidgetContent.snapshotEntry]

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate)
//            entries.append(entry)
//        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

@main
struct StepicWidget: Widget {
    let kind: String = "StepicWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
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
