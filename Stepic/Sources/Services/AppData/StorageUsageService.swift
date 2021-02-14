import Foundation

protocol StorageUsageServiceProtocol: AnyObject {
    typealias Bytes = UInt64

    /// Returns video stored file in bytes, otherwise returns nil if file not found.
    func getVideoFileSize(videoID: Video.IdType) -> Bytes?
    func getStepSize(step: StepPlainObject) -> Bytes
    func getLessonSize(lesson: LessonPlainObject) -> Bytes
    func getUnitSize(unit: UnitPlainObject) -> Bytes
    func getSectionSize(section: SectionPlainObject) -> Bytes
    func getCourseSize(course: Course) -> Bytes
}

extension StorageUsageServiceProtocol {
    func getStepSize(step: Step) -> Bytes {
        self.getStepSize(step: StepPlainObject(step: step))
    }

    func getLessonSize(lesson: Lesson) -> Bytes {
        self.getLessonSize(lesson: LessonPlainObject(lesson: lesson))
    }

    func getUnitSize(unit: Unit) -> Bytes {
        self.getUnitSize(unit: UnitPlainObject(unit: unit))
    }

    func getSectionSize(section: Section) -> Bytes {
        self.getSectionSize(section: SectionPlainObject(section: section))
    }
}

extension StorageUsageServiceProtocol {
    func getLessonSize(lesson: LessonPlainObject) -> Bytes {
        lesson.steps.reduce(0) { $0 + self.getStepSize(step: $1) }
    }

    func getUnitSize(unit: UnitPlainObject) -> Bytes {
        if let lesson = unit.lesson {
            return self.getLessonSize(lesson: lesson)
        }
        return 0
    }

    func getSectionSize(section: SectionPlainObject) -> Bytes {
        section.units.reduce(0) { $0 + self.getUnitSize(unit: $1) }
    }

    func getCourseSize(course: Course) -> Bytes {
        course.sections.reduce(0) { $0 + self.getSectionSize(section: $1) }
    }
}

final class StorageUsageService: StorageUsageServiceProtocol {
    private let videoFileManager: VideoStoredFileManagerProtocol
    private let imageFileManager: ImageStoredFileManagerProtocol

    init(
        videoFileManager: VideoStoredFileManagerProtocol,
        imageFileManager: ImageStoredFileManagerProtocol
    ) {
        self.videoFileManager = videoFileManager
        self.imageFileManager = imageFileManager
    }

    // MARK: Protocol Conforming

    func getVideoFileSize(videoID: Video.IdType) -> Bytes? {
        self.videoFileManager.getVideoStoredFile(videoID: videoID)?.size
    }

    func getStepSize(step: StepPlainObject) -> Bytes {
        if step.block.type == .video, let videoID = step.block.video?.id {
            return self.getVideoFileSize(videoID: videoID) ?? 0
        } else {
            let cachedImagesSize = step.block.imageSourceURLs
                .compactMap { self.imageFileManager.getImageStoredFile(imageURL: $0) }
                .map { $0.size }
                .reduce(0, +)

            let textSize = UInt64((step.block.text ?? "").utf8.count)

            return textSize + cachedImagesSize
        }
    }
}
