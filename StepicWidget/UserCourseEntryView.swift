import SwiftUI
import WidgetKit

struct UserCourseEntryView: View {
    let entry: UserCourseEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                CourseThumbnailView(thumbnailData: entry.thumbnailData)
                    .frame(width: 44, height: 44)
                Spacer()
                Image(systemName: "arrow.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }

            Text(entry.title)
                .font(Font.system(size: 15, weight: .semibold))
                .lineLimit(2)
                .padding(.top, 8)

            Text(entry.subtitle)
                .font(.caption2)
                .lineLimit(1)
                .padding(.top, 2)

            Spacer()

            HStack {
                Spacer()
                Text("\(formattedProgress())")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }.padding(.bottom, 2)

            ProgressBar(value: entry.progress / 100.0)
                .frame(height: 4)
        }
        .padding()
        .foregroundColor(Color.white)
        .background(Color.backgroundColor)
    }

    private func formattedProgress() -> String {
        let hasDecimals = entry.progress.truncatingRemainder(dividingBy: 1) != 0
        let stringValue = hasDecimals ? String(format: "%.2f", entry.progress) : "\(Int(entry.progress))"
        return "\(stringValue)%"
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
        }
    }
}
