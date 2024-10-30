import SwiftUI
import WidgetKit

struct ContinueCourseView: View {
    let course: WidgetUserCourse?

    @ViewBuilder
    var body: some View {
        if let course = self.course {
            buildContentView(for: course)
                .widgetURL(course.url)
        } else {
            emptyView
                .widgetURL(WidgetURL.catalog.url)
        }
    }

    @ViewBuilder
    private func buildContentView(for course: WidgetUserCourse) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                CourseThumbnailView(thumbnailData: course.thumbnailData)
                    .frame(width: 44, height: 44)
                Spacer()
                Image(systemName: "arrow.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }

            Text(course.title)
                .font(Font.system(size: 15, weight: .semibold))
                .lineLimit(2)
                .padding(.top, 8)

            Text(course.subtitle)
                .font(.caption2)
                .lineLimit(1)
                .padding(.top, 2)

            Spacer()

            HStack {
                Spacer()
                Text("\(Formatter.progress(course.progress))")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }.padding(.bottom, 2)

            ProgressBar(value: course.progress / 100.0)
                .frame(height: 4)
                .background(Color.white.opacity(0.12))
                .cornerRadius(2)
        }
        .padding()
        .foregroundColor(Color.white)
        .safeContainerBackground { Color.backgroundColor }
    }

    private var emptyView: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Button(action: {
                    print("button tapped")
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                        .padding()
                }
                .frame(width: 48, height: 48)
                .background(Color.white.opacity(0.12))
                .cornerRadius(8)

                Spacer()

                Image("stepik-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }

            Spacer()

            Text("ContinueCourseEmptyTitle")
                .font(Font.system(size: 15, weight: .semibold))
        }
        .padding()
        .foregroundColor(Color.white)
        .safeContainerBackground { Color.backgroundColor }
    }
}

struct ContinueCourseView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContinueCourseView(course: .snapshotEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            ContinueCourseView(course: .snapshotEntry)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .dark)

            ContinueCourseView(course: nil)
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            ContinueCourseView(course: nil)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .environment(\.colorScheme, .dark)
        }
    }
}
