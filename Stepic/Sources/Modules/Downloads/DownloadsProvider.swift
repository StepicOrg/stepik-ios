import Foundation
import PromiseKit

protocol DownloadsProviderProtocol {
    func fetchCachedSteps() -> Guarantee<[Course: [Step]]>
    func getVideoFileSize(videoID: Video.IdType) -> UInt64
    func isAdaptiveCourse(courseID: Course.IdType) -> Bool
    func deleteSteps(_ steps: [Step]) -> Guarantee<(succeededIDs: [Step.IdType], failedIDs: [Step.IdType])>
}

final class DownloadsProvider: DownloadsProviderProtocol {
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let videoFileManager: VideoStoredFileManagerProtocol
    private let adaptiveStorageManager: AdaptiveStorageManagerProtocol

    private var videoFileSizeCache: [Video.IdType: UInt64] = [:]

    init(
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        videoFileManager: VideoStoredFileManagerProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol
    ) {
        self.coursesPersistenceService = coursesPersistenceService
        self.videoFileManager = videoFileManager
        self.adaptiveStorageManager = adaptiveStorageManager
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

    func isAdaptiveCourse(courseID: Course.IdType) -> Bool {
        return self.adaptiveStorageManager.canOpenInAdaptiveMode(courseId: courseID)
    }

    func deleteSteps(_ steps: [Step]) -> Guarantee<(succeededIDs: [Step.IdType], failedIDs: [Step.IdType])> {
        var succeededIDs = [Step.IdType]()
        var failedIDs = [Step.IdType]()

        return Guarantee { seal in
            for step in steps {
                let stepID = step.id

                if step.block.type == .video {
                    guard let video = step.block.video else {
                        failedIDs.append(stepID)
                        continue
                    }

                    do {
                        try self.deleteVideo(video)
                    } catch {
                        failedIDs.append(stepID)
                    }

                    succeededIDs.append(stepID)
                } else {
                    self.deleteStep(step)
                    succeededIDs.append(stepID)
                }
            }

            CoreDataHelper.instance.save()

            seal((succeededIDs, failedIDs))
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
                    if step.block.type == .video,
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

    private func deleteVideo(_ video: Video) throws {
        try self.videoFileManager.removeVideoStoredFile(videoID: video.id)
        video.cachedQuality = nil
    }

    private func deleteStep(_ step: Step) {
        CoreDataHelper.instance.deleteFromStore(step, save: false)
    }
}
