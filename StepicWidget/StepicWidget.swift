import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> UserCourseEntry {
        .snapshotEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (UserCourseEntry) -> ()) {
        let entry = UserCourseEntry.snapshotEntry
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entries: [UserCourseEntry] = [UserCourseEntry.snapshotEntry]

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
            UserCourseEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct StepicWidget_Previews: PreviewProvider {
    static var previews: some View {
        UserCourseEntryView(entry: .snapshotEntry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
