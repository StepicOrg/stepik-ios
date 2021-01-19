import WidgetKit

struct WidgetContentProvider: TimelineProvider {
    typealias Entry = WidgetContent

    let stepikNetworkService: StepikNetworkService = .shared
    let contentFileManager: WidgetContentFileManagerProtocol = WidgetContentFileManager.default
    let tokenFileManager: StepikWidgetTokenFileManagerProtocol = StepikWidgetTokenFileManager.default

    private let userDefaults = WidgetContentProviderUserDefaults()

    func placeholder(in context: Context) -> WidgetContent {
        .snapshotEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetContent) -> Void) {
        completion(.snapshotEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        if self.userDefaults.shouldPerformRemoteRequest {
            self.userDefaults.updateLastDateRemoteRequestPerformed()
            self.fetchRemoteContent { result in
                switch result {
                case .success(let remoteContent):
                    let localContent = self.fetchLocalContent()
                    let resultContent = self.mergedContent(local: localContent, remote: remoteContent)

                    try? self.contentFileManager.writeUserCourses(resultContent.userCourses)

                    self.presentTimeline(entry: resultContent, completion: completion)
                case .failure:
                    self.presentTimeline(entry: self.fetchLocalContent(), completion: completion)
                }
            }
        } else {
            self.presentTimeline(entry: self.fetchLocalContent(), completion: completion)
        }
    }

    // MARK: Private API

    private func presentTimeline(entry: Entry, completion: @escaping (Timeline<Entry>) -> ()) {
        let nextUpdateDate = Calendar.current.date(
            byAdding: .second,
            value: Int(WidgetConstants.timelineUpdateTimeInterval),
            to: Date()
        )!

        let timeline = Timeline(
            entries: [entry],
            policy: .after(nextUpdateDate)
        )

        completion(timeline)
    }

    private func fetchLocalContent() -> WidgetContent {
        let userCourses = self.contentFileManager.readUserCourses()
        return WidgetContent(userCourses: userCourses)
    }

    private func fetchRemoteContent(completion: @escaping (Result<WidgetContent>) -> ()) {
        self.stepikNetworkService.token = self.tokenFileManager.read()

        self.stepikNetworkService.getUserCourses { userCoursesResult in
            guard case .success(let userCoursesResponse) = userCoursesResult else {
                return completion(.failure(Error.remoteFetchFailed))
            }

            let coursesIDs = Array(
                userCoursesResponse.userCourses
                    .sorted(by: { $0.lastViewed > $1.lastViewed })
                    .map(\.course)
                    .prefix(WidgetConstants.maxUserCoursesCount)
            )

            if coursesIDs.isEmpty {
                return completion(.failure(Error.emptyData))
            }

            self.stepikNetworkService.getCourses(ids: coursesIDs) { coursesResult in
                guard case .success(let coursesResponse) = coursesResult else {
                    return completion(.failure(Error.remoteFetchFailed))
                }

                let progressesIDs = coursesResponse.courses.compactMap(\.progress)
                assert(coursesResponse.courses.count == progressesIDs.count)

                if progressesIDs.isEmpty {
                    return completion(.failure(Error.emptyData))
                }

                self.stepikNetworkService.getProgresses(ids: progressesIDs) { progressesResult in
                    guard case .success(let progressesResponse) = progressesResult else {
                        return completion(.failure(Error.remoteFetchFailed))
                    }

                    let userCourses = zip(
                        coursesResponse.courses,
                        progressesResponse.progresses
                    ).map { (course, progress) in
                        WidgetUserCourse(
                            id: course.id,
                            title: course.title ?? "",
                            subtitle: course.summary ?? "",
                            progress: progress.percentPassed,
                            thumbnailData: nil
                        )
                    }
                    let content = WidgetContent(userCourses: userCourses)

                    completion(.success(content))
                }
            }
        }
    }

    private func mergedContent(local: WidgetContent, remote: WidgetContent) -> WidgetContent {
        var resultUserCourses = [WidgetUserCourse]()

        for remoteUserCourse in remote.userCourses {
            if let localUserCourse = local.userCourses.first(where: { $0.id == remoteUserCourse.id }) {
                // Prefer local subtitle because it could be formatted with authors.
                let subtitle = localUserCourse.subtitle.isEmpty ? remoteUserCourse.subtitle : localUserCourse.subtitle

                let newUserCourse = WidgetUserCourse(
                    id: remoteUserCourse.id,
                    title: remoteUserCourse.title.isEmpty ? localUserCourse.title : remoteUserCourse.title,
                    subtitle: subtitle,
                    progress: remoteUserCourse.progress,
                    thumbnailData: remoteUserCourse.thumbnailData ?? localUserCourse.thumbnailData
                )

                resultUserCourses.append(newUserCourse)
            } else {
                resultUserCourses.append(remoteUserCourse)
            }
        }

        return WidgetContent(userCourses: resultUserCourses)
    }

    enum Error: Swift.Error {
        case remoteFetchFailed
        case emptyData
    }
}

// MARK: - WidgetContentProviderUserDefaults -

fileprivate class WidgetContentProviderUserDefaults {
    private static let lastDateRemoteDataRequestedKey = "lastDateRemoteDataRequestedKey"

    var shouldPerformRemoteRequest: Bool {
        Date().timeIntervalSince(self.lastDateRemoteRequestPerformed) >= WidgetConstants.timelineUpdateTimeInterval
    }

    private var lastDateRemoteRequestPerformed: Date {
        get {
            if let defaultsDate = UserDefaults.standard.object(forKey: Self.lastDateRemoteDataRequestedKey) as? Date {
                return defaultsDate
            } else {
                return Date(timeIntervalSince1970: 0)
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.lastDateRemoteDataRequestedKey)
        }
    }

    func updateLastDateRemoteRequestPerformed() {
        self.lastDateRemoteRequestPerformed = Date()
    }
}
