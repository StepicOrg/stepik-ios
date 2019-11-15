import Foundation
import PromiseKit

protocol DownloadsProviderProtocol {
    func fetchCachedSteps() -> Guarantee<[Course: [Step]]>
    func getVideoFileSize(videoID: Video.IdType) -> UInt64
}

final class DownloadsProvider: DownloadsProviderProtocol {
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let videoFileManager: VideoStoredFileManagerProtocol

    private var videoFileSizeCache: [Video.IdType: UInt64] = [:]

    init(
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        videoFileManager: VideoStoredFileManagerProtocol
    ) {
        self.coursesPersistenceService = coursesPersistenceService
        self.videoFileManager = videoFileManager
    }

    func fetchCachedSteps() -> Guarantee<[Course: [Step]]> {
        return Guarantee { seal in
            self.coursesPersistenceService.fetchAll().done { courses in
                var cachedStepsByCourse: [Course: [Step]] = [:]

                for course in courses {
                    let cachedSteps = self.getCachedSteps(for: course)
                    if !cachedSteps.isEmpty {
                        let keyCourse = cachedStepsByCourse.first(where: { $0.key.id == course.id })?.key ?? course
                        cachedStepsByCourse[keyCourse, default: []].append(contentsOf: cachedSteps)
                    }
                }

                seal(cachedStepsByCourse)
            }
        }
    }

    func getVideoFileSize(videoID: Video.IdType) -> UInt64 {
        if let cachedVideoFileSize = self.videoFileSizeCache[videoID] {
            return cachedVideoFileSize
        } else {
            let cachedVideoFileSize = self.videoFileManager.getVideoStoredFile(videoID: videoID)?.size ?? 0
            self.videoFileSizeCache[videoID] = cachedVideoFileSize
            return cachedVideoFileSize
        }
    }

    // MARK: - Private API

    private func getCachedSteps(for course: Course) -> [Step] {
        var resultSteps = [Step]()

        for section in course.sections {
            for unit in section.units {
                guard let lesson = unit.lesson else {
                    continue
                }

                let cachedSteps = lesson.steps.filter { step in
                    if step.block.type == .Video,
                       let videoID = step.block.video?.id {
                        let videoStoredFile = self.videoFileManager.getVideoStoredFile(videoID: videoID)
                        self.videoFileSizeCache[videoID] = videoStoredFile?.size
                        return videoStoredFile != nil
                    }
                    return true
                }

                resultSteps.append(contentsOf: cachedSteps)
            }
        }

        return resultSteps
    }
}
