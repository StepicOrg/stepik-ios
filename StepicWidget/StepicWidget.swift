import WidgetKit
import SwiftUI

struct WidgetContentProvider: TimelineProvider {
    typealias Entry = WidgetContent

    let contentFileManager: WidgetContentFileManagerProtocol

    func placeholder(in context: Context) -> WidgetContent {
        .snapshotEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetContent) -> Void) {
        completion(.snapshotEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = self.readContent()
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 5, to: entry.date)!

        let timeline = Timeline(
            entries: [entry],
            policy: .after(nextUpdateDate)
        )

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
        StaticConfiguration(
            kind: kind,
            provider: WidgetContentProvider(contentFileManager: contentFileManager)
        ) { entry in
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
