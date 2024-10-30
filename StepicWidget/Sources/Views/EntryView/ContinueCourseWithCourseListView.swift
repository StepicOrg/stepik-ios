import SwiftUI
import WidgetKit

struct ContinueCourseWithCourseListView: View {
    private static let maxSecondaryCoursesCount = WidgetConstants.maxUserCoursesCount - 1

    let courses: [WidgetUserCourse]

    private var primaryCourse: WidgetUserCourse { self.courses[0] }

    private var secondaryCourses: [WidgetUserCourse] {
        Array(self.courses.prefix(Self.maxSecondaryCoursesCount + 1).dropFirst())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if courses.isEmpty {
                Link(destination: WidgetURL.catalog.url) {
                    primaryCourseEmptyView.padding()
                }
            } else {
                Link(destination: WidgetURL.course(id: primaryCourse.id).url) {
                    primaryCourseView.padding()
                }
            }

            HStack {
                if secondaryCourses.isEmpty {
                    Link(destination: WidgetURL.catalog.url) {
                        secondaryCoursesEmptyView
                    }
                } else {
                    secondaryCoursesListView
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.15))
        }
        .foregroundColor(Color.white)
        .safeContainerBackground { Color.backgroundColor }
    }

    private var primaryCourseView: some View {
        HStack(alignment: .center) {
            CourseThumbnailView(thumbnailData: primaryCourse.thumbnailData)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 0) {
                Text(primaryCourse.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(primaryCourse.subtitle)
                    .font(.caption2)
                    .lineLimit(1)

                HStack(alignment: .firstTextBaseline) {
                    ProgressBar(value: primaryCourse.progress / 100.0)
                        .frame(height: 4)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(2)
                    Text("\(Formatter.progress(primaryCourse.progress))")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }
            }

            Image(systemName: "arrow.right")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 17, height: 24)
                .frame(maxHeight: .infinity, alignment: .top)
        }
    }

    private var primaryCourseEmptyView: some View {
        HStack(alignment: .top) {
            Button(action: {
                print("Edit button was tapped")
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

            VStack(alignment: .leading) {
                Text("ContinueCourseEmptyTitle")
                    .font(.headline)
                    .lineLimit(1)

                Text("ContinueCourseEmptySubtitle")
                    .font(.caption2)
                    .lineLimit(1)
            }
        }
    }

    private var secondaryCoursesListView: some View {
        HStack(spacing: 16) {
            ForEach(secondaryCourses, id: \.id) { entry in
                Link(destination: WidgetURL.course(id: entry.id).url) {
                    CourseThumbnailView(thumbnailData: entry.thumbnailData)
                        .frame(width: 48, height: 48)
                }
            }

            if secondaryCourses.count < Self.maxSecondaryCoursesCount {
                Link(destination: WidgetURL.catalog.url) {
                    Button(action: {
                        print("Edit button was tapped")
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
                }
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private var secondaryCoursesEmptyView: some View {
        Button(action: {
            print("Edit button was tapped")
        }) {
            HStack(alignment: .center) {
                Image(systemName: "plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)

                Spacer()

                Text("CourseListEmptyTitle")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
            }.padding()
        }
        .frame(height: 48)
        .background(Color.white.opacity(0.12))
        .cornerRadius(8)
    }
}

struct ContinueCourseWithCourseList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContinueCourseWithCourseListView(courses: [.snapshotEntry])
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            ContinueCourseWithCourseListView(courses: [.snapshotEntry])
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)

            ContinueCourseWithCourseListView(courses: [])
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            ContinueCourseWithCourseListView(
                courses: [.snapshotEntry, .snapshotEntry]
            ).previewContext(WidgetPreviewContext(family: .systemMedium))

            ContinueCourseWithCourseListView(
                courses: [.snapshotEntry, .snapshotEntry, .snapshotEntry, .snapshotEntry, .snapshotEntry]
            ).previewContext(WidgetPreviewContext(family: .systemMedium))

            ContinueCourseWithCourseListView(
                courses: [.snapshotEntry, .snapshotEntry, .snapshotEntry, .snapshotEntry, .snapshotEntry]
            )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .environment(\.colorScheme, .dark)
        }
    }
}
