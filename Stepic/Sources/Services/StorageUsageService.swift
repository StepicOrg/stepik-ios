import Foundation

protocol StorageUsageServiceProtocol: class {
    typealias Bytes = UInt64

    /// Returns video stored file in bytes, otherwise returns nil if file not found.
    func getVideoFileSize(videoID: Video.IdType) -> Bytes?
    func getStepSize(step: Step) -> Bytes
    func getLessonSize(lesson: Lesson) -> Bytes
    func getUnitSize(unit: Unit) -> Bytes
    func getSectionSize(section: Section) -> Bytes
    func getCourseSize(course: Course) -> Bytes
}

extension StorageUsageServiceProtocol {
    func getStepSize(step: Step) -> Bytes {
        if step.block.type == .video, let videoID = step.block.video?.id {
            return self.getVideoFileSize(videoID: videoID) ?? 0
        } else {
            return UInt64((step.block.text ?? "").utf8.count)
        }
    }

    func getLessonSize(lesson: Lesson) -> Bytes {
        return lesson.steps.reduce(0) { $0 + self.getStepSize(step: $1) }
    }

    func getUnitSize(unit: Unit) -> Bytes {
        if let lesson = unit.lesson {
            return self.getLessonSize(lesson: lesson)
        }
        return 0
    }

    func getSectionSize(section: Section) -> Bytes {
        return section.units.reduce(0) { $0 + self.getUnitSize(unit: $1) }
    }

    func getCourseSize(course: Course) -> Bytes {
        return course.sections.reduce(0) { $0 + self.getSectionSize(section: $1) }
    }
}

final class StorageUsageService: StorageUsageServiceProtocol {
    private let videoFileManager: VideoStoredFileManagerProtocol

    init(videoFileManager: VideoStoredFileManagerProtocol) {
        self.videoFileManager = videoFileManager
    }

    func getVideoFileSize(videoID: Video.IdType) -> Bytes? {
        return self.videoFileManager.getVideoStoredFile(videoID: videoID)?.size
    }
}
