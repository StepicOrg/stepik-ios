import Foundation
import PromiseKit

// MARK: SyllabusDownloadsServiceDelegate -

protocol SyllabusDownloadsServiceDelegate: class {
    func syllabusDownloadsService(
        _ service: SyllabusDownloadsServiceProtocol,
        didReceiveProgress progress: Float,
        forVideoWithID videoID: Video.IdType
    )
    func syllabusDownloadsService(
        _ service: SyllabusDownloadsServiceProtocol,
        didReceiveProgress progress: Float,
        forUnitWithID unitID: Unit.IdType
    )
    func syllabusDownloadsService(
        _ service: SyllabusDownloadsServiceProtocol,
        didReceiveProgress progress: Float,
        forSectionWithID sectionID: Section.IdType
    )

    func syllabusDownloadsService(
        _ service: SyllabusDownloadsServiceProtocol,
        didReceiveCompletion isCompleted: Bool,
        forVideoWithID videoID: Video.IdType
    )
    func syllabusDownloadsService(
        _ service: SyllabusDownloadsServiceProtocol,
        didReceiveCompletion isCompleted: Bool,
        forUnitWithID unitID: Unit.IdType
    )
    func syllabusDownloadsService(
        _ service: SyllabusDownloadsServiceProtocol,
        didReceiveCompletion isCompleted: Bool,
        forSectionWithID sectionID: Section.IdType
    )

    func syllabusDownloadsService(
        _ service: SyllabusDownloadsServiceProtocol,
        didFailLoadVideoWithError error: Swift.Error
    )
}

// MARK: - SyllabusDownloadsServiceProtocol -

protocol SyllabusDownloadsServiceProtocol: class {
    var delegate: SyllabusDownloadsServiceDelegate? { get set }

    func download(unit: Unit) -> Promise<Void>
    func download(section: Section) -> Promise<Void>

    func remove(unit: Unit) -> Promise<Void>
    func remove(section: Section) -> Promise<Void>
    func remove(course: Course) -> Promise<Void>

    func cancel(unit: Unit) -> Promise<Void>
    func cancel(section: Section) -> Promise<Void>

    func getDownloadingStateForUnit(_ unit: Unit, in section: Section) -> CourseInfoTabSyllabus.DownloadState
    func getDownloadingStateForSection(_ section: Section) -> CourseInfoTabSyllabus.DownloadState
    func getDownloadingStateForCourse(_ course: Course) -> CourseInfoTabSyllabus.DownloadState
}

// MARK: - SyllabusDownloadsService: SyllabusDownloadsServiceProtocol -

final class SyllabusDownloadsService: SyllabusDownloadsServiceProtocol {
    private static let progressCompletedValue: Float = 1.0

    weak var delegate: SyllabusDownloadsServiceDelegate?

    private let videoDownloadingService: VideoDownloadingServiceProtocol
    private let videoFileManager: VideoStoredFileManagerProtocol
    private let stepsNetworkService: StepsNetworkServiceProtocol
    private let storageUsageService: StorageUsageServiceProtocol

    // Section -> Unit -> Videos
    private var unitIDsBySectionID: [Section.IdType: Set<Unit.IdType>] = [:]
    private var videoIDsByUnitID: [Unit.IdType: Set<Video.IdType>] = [:]
    private var progressByVideoID: [Video.IdType: Float] = [:]
    private var activeVideoDownloads: Set<Video.IdType> = []

    init(
        videoDownloadingService: VideoDownloadingServiceProtocol,
        videoFileManager: VideoStoredFileManagerProtocol,
        stepsNetworkService: StepsNetworkServiceProtocol,
        storageUsageService: StorageUsageServiceProtocol
    ) {
        self.videoDownloadingService = videoDownloadingService
        self.videoFileManager = videoFileManager
        self.stepsNetworkService = stepsNetworkService
        self.storageUsageService = storageUsageService

        self.subscribeOnVideoDownloadingEvents()
    }

    // MARK: Download

    func download(unit: Unit) -> Promise<Void> {
        guard let lesson = unit.lesson else {
            return Promise(error: Error.lessonNotFound)
        }

        return firstly {
            self.fetchSteps(for: lesson)
        }.done { steps in
            try self.startDownloading(unit: unit, steps: steps)
        }
    }

    func download(section: Section) -> Promise<Void> {
        let hasUncachedUnits = section.units
            .filter { section.unitsArray.contains($0.id) }
            .count != section.unitsArray.count
        if hasUncachedUnits {
            return Promise(error: Error.downloadSectionFailed)
        }

        let fetchStepsPromises = section.units.compactMap { unit -> (Unit, Lesson)? in
            if let lesson = unit.lesson {
                return (unit, lesson)
            }
            return nil
        }.map { result -> Promise<(Unit, [Step])> in
            self.fetchSteps(for: result.1).map { (result.0, $0) }
        }

        return when(
            fulfilled: fetchStepsPromises
        ).done { result in
            for (unit, steps) in result {
                try? self.startDownloading(section: section, unit: unit, steps: steps)
            }
        }
    }

    private func startDownloading(section: Section? = nil, unit: Unit, steps: [Step]) throws {
        let uncachedVideos = steps.compactMap { step -> Video? in
            guard step.block.type == .video,
                  let video = step.block.video else {
                return nil
            }

            return self.videoFileManager.getVideoStoredFile(videoID: video.id) == nil ? video : nil
        }
        let uncachedVideosIDs = Set(uncachedVideos.map { $0.id })

        if uncachedVideosIDs.isEmpty {
            return
        }

        if let section = section {
            self.unitIDsBySectionID[section.id, default: []].insert(unit.id)
        }

        let uniqueUncachedVideosIDs = uncachedVideosIDs.symmetricDifference(self.videoIDsByUnitID[unit.id, default: []])
        uncachedVideosIDs.forEach { self.videoIDsByUnitID[unit.id, default: []].insert($0) }

        let uniqueUncachedVideos = uncachedVideos.filter { uniqueUncachedVideosIDs.contains($0.id) }
        for video in uniqueUncachedVideos where !self.activeVideoDownloads.contains(video.id) {
            try self.videoDownloadingService.download(video: video)
            self.activeVideoDownloads.insert(video.id)
        }
    }

    private func subscribeOnVideoDownloadingEvents() {
        self.videoDownloadingService.subscribeOnEvents { [weak self] event in
            DispatchQueue.main.async {
                self?.handleUpdate(with: event)
            }
        }
    }

    /// Handle events from downloading service
    private func handleUpdate(with event: VideoDownloadingServiceEvent) {
        let videoID = event.videoID

        switch event.state {
        case .error(let error):
            self.progressByVideoID[videoID] = nil
            self.activeVideoDownloads.remove(videoID)

            self.delegate?.syllabusDownloadsService(self, didFailLoadVideoWithError: error)
        case .active(let progress):
            self.progressByVideoID[videoID] = progress
            self.reportDownloadingProgress(progress, forVideoWithID: videoID)
        case .completed:
            self.progressByVideoID[videoID] = SyllabusDownloadsService.progressCompletedValue
            self.activeVideoDownloads.remove(videoID)

            self.reportDownloadingProgress(SyllabusDownloadsService.progressCompletedValue, forVideoWithID: videoID)
            self.delegate?.syllabusDownloadsService(self, didReceiveCompletion: true, forVideoWithID: videoID)
        }
    }

    private func reportDownloadingProgress(_ progress: Float, forVideoWithID videoID: Video.IdType) {
        self.delegate?.syllabusDownloadsService(self, didReceiveProgress: progress, forVideoWithID: videoID)

        guard let unitID = self.videoIDsByUnitID.first(where: { $0.value.contains(videoID) })?.key else {
            return
        }

        if let unitProgress = self.getUnitDownloadProgress(unitID: unitID) {
            self.delegate?.syllabusDownloadsService(self, didReceiveProgress: unitProgress, forUnitWithID: unitID)

            if unitProgress == SyllabusDownloadsService.progressCompletedValue {
                self.delegate?.syllabusDownloadsService(self, didReceiveCompletion: true, forUnitWithID: unitID)
            }
        }

        if let sectionID = self.unitIDsBySectionID.first(where: { $0.value.contains(unitID) })?.key,
           let sectionProgress = self.getSectionDownloadProgress(sectionID: sectionID) {
            self.delegate?.syllabusDownloadsService(
                self, didReceiveProgress: sectionProgress, forSectionWithID: sectionID
            )

            if sectionProgress == SyllabusDownloadsService.progressCompletedValue {
                self.delegate?.syllabusDownloadsService(self, didReceiveCompletion: true, forSectionWithID: sectionID)
            }
        }
    }

    // MARK: Remove

    func remove(unit: Unit) -> Promise<Void> {
        guard let lesson = unit.lesson else {
            return Promise(error: Error.lessonNotFound)
        }

        let removeStepsPromises = lesson.steps
            .map { step -> Promise<Void> in
                Promise { seal in
                    if step.block.type == .video, let video = step.block.video {
                        do {
                            try self.videoFileManager.removeVideoStoredFile(videoID: video.id)
                            video.cachedQuality = nil

                            self.videoIDsByUnitID[unit.id]?.remove(video.id)
                            self.progressByVideoID[video.id] = nil
                        } catch {
                            seal.reject(Error.removeUnitFailed)
                        }
                    }

                    CoreDataHelper.instance.deleteFromStore(step, save: false)

                    seal.fulfill(())
                }
            }

        return Promise { seal in
            when(fulfilled: removeStepsPromises).done { _ in
                CoreDataHelper.instance.save()
                seal.fulfill(())
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func remove(section: Section) -> Promise<Void> {
        return when(
            fulfilled: section.units.map {
                self.remove(unit: $0)
            }
        ).done { _ in
            self.unitIDsBySectionID[section.id] = nil
        }
    }

    func remove(course: Course) -> Promise<Void> {
        return when(
            fulfilled: course.sections.map {
                self.remove(section: $0)
            }
        )
    }

    // MARK: Cancel

    func cancel(unit: Unit) -> Promise<Void> {
        guard let lesson = unit.lesson else {
            return Promise(error: Error.lessonNotFound)
        }

        let cancelVideosPromises = lesson.steps
            .filter { $0.block.type == .video }
            .compactMap { $0.block.video }
            .filter { self.activeVideoDownloads.contains($0.id) }
            .map { video -> Promise<Void> in
                Promise { seal in
                    do {
                        try self.videoDownloadingService.cancelDownload(videoID: video.id)

                        self.videoIDsByUnitID[unit.id]?.remove(video.id)
                        self.progressByVideoID[video.id] = nil

                        seal.fulfill(())
                    } catch {
                        seal.reject(Error.cancelUnitFailed)
                    }
                }
            }

        return when(fulfilled: cancelVideosPromises)
    }

    func cancel(section: Section) -> Promise<Void> {
        return Promise { seal in
            when(
                fulfilled: section.units.map { self.cancel(unit: $0) }
            ).done { _ in
                self.unitIDsBySectionID[section.id] = nil
                seal.fulfill(())
            }.catch { _ in
                seal.reject(Error.cancelSectionFailed)
            }
        }
    }

    // MARK: Downloading state

    func getDownloadingStateForUnit(_ unit: Unit, in section: Section) -> CourseInfoTabSyllabus.DownloadState {
        // If section is unreachable or exam then all units are not available
        guard !section.isExam, section.isReachable else {
            return .notAvailable
        }

        guard let lesson = unit.lesson else {
            // We should call this method only with completely loaded units
            // But return "not cached" in this case
            return .notCached
        }

        let steps = lesson.steps
        let unitSizeInBytes = self.storageUsageService.getUnitSize(unit: unit)

        // If have unloaded steps for lesson then show "not cached" state
        let hasUncachedSteps = steps
            .filter { lesson.stepsArray.contains($0.id) }
            .count != lesson.stepsArray.count
        if hasUncachedSteps {
            return .notCached
        }

        // Iterate through steps and determine final state
        let stepsWithVideoCount = steps
            .filter { $0.block.type == .video }
            .count
        // Lesson has no steps with video and all steps cached -> return "cached" state.
        if stepsWithVideoCount == 0 {
            return .cached(bytesTotal: unitSizeInBytes)
        }

        let stepsWithCachedVideoCount = steps
            .filter { $0.block.type == .video }
            .compactMap { $0.block.video?.id }
            .filter { self.videoFileManager.getVideoStoredFile(videoID: $0) != nil }
            .count

        // Check if video is downloading
        let stepsWithVideo = steps
            .filter { $0.block.type == .video }
            .compactMap { $0.block.video }
        let downloadingVideosProgresses = stepsWithVideo.compactMap { self.getVideoDownloadProgress($0) }

        if !downloadingVideosProgresses.isEmpty {
            let requestedVideosToDownloadCount = Float(self.videoIDsByUnitID[unit.id].require().count)
            return .downloading(
                progress: downloadingVideosProgresses.reduce(0, +) / requestedVideosToDownloadCount
            )
        }

        // Try to restore downloads
        try? self.restoreDownloading(section: section, unit: unit)

        // Some videos aren't cached
        if stepsWithCachedVideoCount != stepsWithVideoCount {
            return .notCached
        }

        // All videos are cached
        return .cached(bytesTotal: unitSizeInBytes)
    }

    func getDownloadingStateForSection(_ section: Section) -> CourseInfoTabSyllabus.DownloadState {
        let units = section.units

        // Unreachable and exam not available
        if section.isExam || !section.isReachable {
            return .notAvailable
        }

        // If have unloaded units for lesson then show "not available" state
        let hasUncachedUnits = units
            .filter { section.unitsArray.contains($0.id) }
            .count != section.unitsArray.count
        if hasUncachedUnits {
            return .notAvailable
        }

        let unitStates = units.map { self.getDownloadingStateForUnit($0, in: section) }
        var shouldBeCachedUnitsCount = 0
        var notAvailableUnitsCount = 0
        var downloadingUnitProgresses: [Float] = []
        var sectionSizeInBytes: UInt64 = 0

        for state in unitStates {
            switch state {
            case .notAvailable:
                notAvailableUnitsCount += 1
            case .notCached:
                shouldBeCachedUnitsCount += 1
            case .downloading(let progress):
                downloadingUnitProgresses.append(progress)
            case .cached(let unitSizeinBytes):
                sectionSizeInBytes += unitSizeinBytes
            default:
                break
            }
        }

        // Downloading state
        if !downloadingUnitProgresses.isEmpty && !units.isEmpty {
            return .downloading(
                progress: downloadingUnitProgresses.reduce(0, +) / Float(downloadingUnitProgresses.count)
            )
        }

        // If all units are not available to downloading then section is not available too
        if notAvailableUnitsCount == units.count {
            return .notAvailable
        }

        // If some units are not cached then section is available to downloading
        if shouldBeCachedUnitsCount > 0 {
            return .notCached
        }

        // All units are cached, section too
        return .cached(bytesTotal: sectionSizeInBytes)
    }

    func getDownloadingStateForCourse(_ course: Course) -> CourseInfoTabSyllabus.DownloadState {
        let sectionStates = course.sections.map { self.getDownloadingStateForSection($0) }

        var cachedSectionsCount = 0
        var courseSizeInBytes: UInt64 = 0
        var containsUncachedSection = false

        for sectionDownloadState in sectionStates {
            switch sectionDownloadState {
            case .notCached:
                containsUncachedSection = true
            case .cached(let bytesTotal):
                cachedSectionsCount += 1
                courseSizeInBytes += bytesTotal
            default:
                continue
            }
        }

        if course.sectionsArray.count == cachedSectionsCount {
            return .cached(bytesTotal: courseSizeInBytes)
        }

        return containsUncachedSection ? .notCached : .notAvailable
    }

    private func getVideoDownloadProgress(_ video: Video) -> Float? {
        return self.activeVideoDownloads.contains(video.id) ? self.progressByVideoID[video.id] : nil
    }

    private func getUnitDownloadProgress(unitID: Unit.IdType) -> Float? {
        guard let videoIDs = self.videoIDsByUnitID[unitID] else {
            return nil
        }

        if videoIDs.isEmpty {
            return nil
        }

        return videoIDs.reduce(0, { $0 + (self.progressByVideoID[$1] ?? 0) }) / Float(videoIDs.count)
    }

    private func getSectionDownloadProgress(sectionID: Section.IdType) -> Float? {
        guard let unitIDs = self.unitIDsBySectionID[sectionID] else {
            return nil
        }

        if unitIDs.isEmpty {
            return nil
        }

        return unitIDs.reduce(0, { $0 + (self.getUnitDownloadProgress(unitID: $1) ?? 0) }) / Float(unitIDs.count)
    }

    // MARK: - Private helpers -

    private func restoreDownloading(section: Section, unit: Unit) throws {
        guard let lesson = unit.lesson else {
            throw Error.lessonNotFound
        }

        let videos = lesson.steps
            .filter { $0.block.type == .video }
            .compactMap { $0.block.video }

        for video in videos where !self.activeVideoDownloads.contains(video.id) {
            if self.videoDownloadingService.isTaskActive(videoID: video.id) {
                self.activeVideoDownloads.insert(video.id)
                self.videoIDsByUnitID[unit.id, default: []].insert(video.id)
                self.unitIDsBySectionID[section.id, default: []].insert(unit.id)
            }
        }
    }

    private func fetchSteps(for lesson: Lesson) -> Promise<[Step]> {
        return firstly {
            self.stepsNetworkService.fetch(ids: lesson.stepsArray)
        }.then { steps -> Promise<[Step]> in
            lesson.steps = steps
            CoreDataHelper.instance.save()
            return .value(steps)
        }
    }

    // MARK: - Types -

    enum Error: Swift.Error {
        case lessonNotFound
        case removeUnitFailed
        case downloadSectionFailed
        case cancelUnitFailed
        case cancelSectionFailed
    }
}
