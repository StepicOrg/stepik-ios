import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    typealias Entry = WidgetContent

    let contentFileManager: WidgetContentFileManagerProtocol

    func placeholder(in context: Context) -> WidgetContent {
        .snapshotEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetContent) -> Void) {
        let entry = WidgetContent.snapshotEntry
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries = [self.readContent()]

        let currentDate = Date()
        let interval = 5

        for index in 0 ..< entries.count {
            entries[index].date = Calendar.current.date(byAdding: .minute, value: index * interval, to: currentDate)!
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private func readContent() -> WidgetContent {
        let userCourses = self.contentFileManager.readUserCourses()
        return WidgetContent(userCourses: userCourses)
    }
}

@main
struct StepicWidget: Widget {
    let kind: String = "StepicWidget"

    let contentFileManager: WidgetContentFileManagerProtocol = WidgetContentFileManager(
        containerURL: FileManager.widgetContainerURL
    )

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(contentFileManager: contentFileManager)) { entry in
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
