import SwiftUI
import WidgetKit

struct MediumContinueLearningView: View {
    private static let maxSecondaryEntriesCount = 5

    let entries: [WidgetUserCourse]

    private var primaryEntry: WidgetUserCourse { self.entries[0] }

    private var secondaryEntries: [WidgetUserCourse] {
        Array(self.entries.prefix(Self.maxSecondaryEntriesCount + 1).dropFirst())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if entries.isEmpty {
                primaryEntryEmptyView
                    .padding()
            } else {
                primaryEntryView
                    .padding()
            }

            HStack {
                if secondaryEntries.isEmpty {
                    emptySecondaryEntriesView
                } else {
                    secondaryEntriesListView
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.15))
        }
        .foregroundColor(Color.white)
        .background(Color.backgroundColor)
    }

    private var primaryEntryView: some View {
        HStack(alignment: .center) {
            CourseThumbnailView(thumbnailData: primaryEntry.thumbnailData)
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 0) {
                Text(primaryEntry.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(primaryEntry.subtitle)
                    .font(.caption2)
                    .lineLimit(1)

                HStack(alignment: VerticalAlignment.firstTextBaseline) {
                    ProgressBar(value: primaryEntry.progress / 100.0)
                        .frame(height: 4)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(2)
                    Text("\(Formatter.progress(primaryEntry.progress))")
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

    private var primaryEntryEmptyView: some View {
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
                Text("Find your first course")
                    .font(.headline)
                    .lineLimit(1)

                Text("There will be your progress")
                    .font(.caption2)
                    .lineLimit(1)
            }
        }
    }

    private var secondaryEntriesListView: some View {
        HStack(spacing: 16) {
            ForEach(secondaryEntries, id: \.id) { entry in
                CourseThumbnailView(thumbnailData: entry.thumbnailData)
                    .frame(width: 48, height: 48)
            }

            if secondaryEntries.count < Self.maxSecondaryEntriesCount {
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
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptySecondaryEntriesView: some View {
        Button(action: {
            print("Edit button was tapped")
        }) {
            HStack(alignment: .center) {
                Image(systemName: "plus")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)

                Spacer()

                Text("Find More Courses")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
            }.padding()
        }
        .frame(height: 48)
        .background(Color.white.opacity(0.12))
        .cornerRadius(8)
    }
}

struct MediumUserCourseView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MediumContinueLearningView(entries: [.snapshotEntry])
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            MediumContinueLearningView(entries: [.snapshotEntry])
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .environment(\.colorScheme, .dark)

            MediumContinueLearningView(entries: [])
                .previewContext(WidgetPreviewContext(family: .systemMedium))

            MediumContinueLearningView(
                entries: [.snapshotEntry, .snapshotEntry]
            ).previewContext(WidgetPreviewContext(family: .systemMedium))

            MediumContinueLearningView(
                entries: [.snapshotEntry, .snapshotEntry, .snapshotEntry, .snapshotEntry, .snapshotEntry]
            ).previewContext(WidgetPreviewContext(family: .systemMedium))

            MediumContinueLearningView(
                entries: [.snapshotEntry, .snapshotEntry, .snapshotEntry, .snapshotEntry, .snapshotEntry]
            )
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .environment(\.colorScheme, .dark)
        }
    }
}
