import Foundation
import PromiseKit

protocol DownloadsProviderProtocol {
    func fetchCachedCourses() -> Guarantee<[Course]>
    func deleteCachedCourses(_ courses: [Course]) -> Guarantee<Void>
    func isAdaptiveCourse(courseID: Course.IdType) -> Bool
    func getCourseSize(_ course: Course) -> UInt64
}

final class DownloadsProvider: DownloadsProviderProtocol {
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let adaptiveStorageManager: AdaptiveStorageManagerProtocol
    private let videoFileManager: VideoStoredFileManagerProtocol
    private let storageUsageService: StorageUsageServiceProtocol

    private var videoFileSizeCache: [Video.IdType: UInt64] = [:]

    init(
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol,
        videoFileManager: VideoStoredFileManagerProtocol,
        storageUsageService: StorageUsageServiceProtocol
    ) {
        self.coursesPersistenceService = coursesPersistenceService
        self.adaptiveStorageManager = adaptiveStorageManager
        self.videoFileManager = videoFileManager
        self.storageUsageService = storageUsageService
    }

    func fetchCachedCourses() -> Guarantee<[Course]> {
        return Guarantee { seal in
            self.coursesPersistenceService.fetchAll().done { courses in
                let cachedCourses = courses.filter { !self.getCourseCachedSteps($0).isEmpty }
                seal(cachedCourses)
            }
        }
    }

    func deleteCachedCourses(_ courses: [Course]) -> Guarantee<Void> {
        let deleteCoursesGuarantees = courses.map { course in
            Guarantee<Void> { seal in
                let steps = self.getCourseCachedSteps(course)

                for step in steps {
                    if step.block.type == .video, let video = step.block.video {
                        try? self.videoFileManager.removeVideoStoredFile(videoID: video.id)
                        video.cachedQuality = nil
                    }
                    CoreDataHelper.instance.deleteFromStore(step, save: false)
                }

                seal(())
            }
        }

        return when(
            guarantees: deleteCoursesGuarantees
        ).done {
            CoreDataHelper.instance.save()
        }
    }

    func isAdaptiveCourse(courseID: Course.IdType) -> Bool {
        return self.adaptiveStorageManager.canOpenInAdaptiveMode(courseId: courseID)
    }

    func getCourseSize(_ course: Course) -> UInt64 {
        return self.storageUsageService.getCourseSize(course: course)
    }

    private func getCourseCachedSteps(_ course: Course) -> [Step] {
        var resultSteps = [Step]()

        for section in course.sections {
            for unit in section.units {
                guard let lesson = unit.lesson else {
                    continue
                }

                let cachedSteps = lesson.steps.filter { step in
                    if step.block.type == .video, let videoID = step.block.video?.id {
                        return self.videoFileManager.getVideoStoredFile(videoID: videoID) != nil
                    }
                    return true
                }

                resultSteps.append(contentsOf: cachedSteps)
            }
        }

        return resultSteps
    }
}
