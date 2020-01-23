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
    private let imageFileManager: ImageStoredFileManagerProtocol
    private let storageUsageService: StorageUsageServiceProtocol

    private var videoFileSizeCache: [Video.IdType: UInt64] = [:]

    init(
        coursesPersistenceService: CoursesPersistenceServiceProtocol,
        adaptiveStorageManager: AdaptiveStorageManagerProtocol,
        videoFileManager: VideoStoredFileManagerProtocol,
        imageFileManager: ImageStoredFileManagerProtocol,
        storageUsageService: StorageUsageServiceProtocol
    ) {
        self.coursesPersistenceService = coursesPersistenceService
        self.adaptiveStorageManager = adaptiveStorageManager
        self.videoFileManager = videoFileManager
        self.imageFileManager = imageFileManager
        self.storageUsageService = storageUsageService
    }

    func fetchCachedCourses() -> Guarantee<[Course]> {
        Guarantee { seal in
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

                    step.block.imageSourceURLs.forEach {
                        try? self.imageFileManager.removeImageStoredFile(imageURL: $0)
                    }
                }

                seal(())
            }
        }

        return when(
            guarantees: deleteCoursesGuarantees
        ).done {
            CoreDataHelper.shared.save()
        }
    }

    func isAdaptiveCourse(courseID: Course.IdType) -> Bool {
        self.adaptiveStorageManager.canOpenInAdaptiveMode(courseId: courseID)
    }

    func getCourseSize(_ course: Course) -> UInt64 {
        self.storageUsageService.getCourseSize(course: course)
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

                    let cachedImages = step.block.imageSourceURLs
                        .compactMap { self.imageFileManager.getImageStoredFile(imageURL: $0) }

                    return !cachedImages.isEmpty
                }

                resultSteps.append(contentsOf: cachedSteps)
            }
        }

        return resultSteps
    }
}
