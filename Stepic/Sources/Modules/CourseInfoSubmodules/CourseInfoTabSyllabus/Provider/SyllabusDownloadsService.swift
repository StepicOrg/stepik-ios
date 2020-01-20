import Foundation
import PromiseKit

// MARK: SyllabusDownloadsServiceDelegate -

protocol SyllabusDownloadsServiceDelegate: AnyObject {
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

protocol SyllabusDownloadsServiceProtocol: AnyObject {
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

    // Video
    private let videoDownloadingService: VideoDownloadingServiceProtocol
    private let videoFileManager: VideoStoredFileManagerProtocol
    // Image
    private let imageDownloadingService: DownloadingServiceProtocol
    private let imageFileManager: StoredFileManagerProtocol

    private let stepsNetworkService: StepsNetworkServiceProtocol
    private let storageUsageService: StorageUsageServiceProtocol

    // Section -> Unit -> [Videos|Images]
    private var unitIDsBySectionID: [Section.IdType: Set<Unit.IdType>] = [:]
    // Video
    private var videoIDsByUnitID: [Unit.IdType: Set<Video.IdType>] = [:]
    private var progressByVideoID: [Video.IdType: Float] = [:]
    private var activeVideoDownloads: Set<Video.IdType> = []
    // Image
    private var imageURLsByUnitID: [Unit.IdType: Set<URL>] = [:]
    private var imageDownloadingTaskIDByURL: [URL: DownloaderTaskProtocol.IDType] = [:]
    //private var progressByVideoID: [Video.IdType: Float] = [:]
    private var activeImageDownloads: Set<URL> = []
    // Units ids requested to be downloaded but not being started yet.
    // To be able to return `DownloadState.waiting`.
    private var pendingUnitsIDs: Set<Unit.IdType> = []

    init(
        videoDownloadingService: VideoDownloadingServiceProtocol,
        videoFileManager: VideoStoredFileManagerProtocol,
        imageDownloadingService: DownloadingServiceProtocol,
        imageFileManager: StoredFileManagerProtocol,
        stepsNetworkService: StepsNetworkServiceProtocol,
        storageUsageService: StorageUsageServiceProtocol
    ) {
        self.videoDownloadingService = videoDownloadingService
        self.videoFileManager = videoFileManager
        self.imageDownloadingService = imageDownloadingService
        self.imageFileManager = imageFileManager
        self.stepsNetworkService = stepsNetworkService
        self.storageUsageService = storageUsageService

        self.subscribeOnDownloadingEvents()
    }

    // MARK: Download

    func download(unit: Unit) -> Promise<Void> {
        guard let lesson = unit.lesson else {
            return Promise(error: Error.lessonNotFound)
        }

        self.pendingUnitsIDs.insert(unit.id)

        return Promise { seal in
            self.fetchSteps(for: lesson).done { steps in
                try self.startDownloading(unit: unit, steps: steps)
                seal.fulfill(())
            }.catch { _ in
                self.pendingUnitsIDs.remove(unit.id)
                seal.reject(Error.downloadUnitFailed)
            }
        }
    }

    func download(section: Section) -> Promise<Void> {
        let hasUncachedUnits = section.units
            .filter { section.unitsArray.contains($0.id) }
            .count != section.unitsArray.count
        if hasUncachedUnits {
            return Promise(error: Error.downloadSectionFailed)
        }

        // Move units to pending state.
        let unitIDsToBeDownloaded = section.units.compactMap { $0.lesson != nil ? $0.id : nil }
        unitIDsToBeDownloaded.forEach { self.pendingUnitsIDs.insert($0) }

        let fetchStepsPromises = section.units.compactMap { unit -> (Unit, Lesson)? in
            if let lesson = unit.lesson {
                return (unit, lesson)
            }
            return nil
        }.map { result -> Promise<(Unit, [Step])> in
            self.fetchSteps(for: result.1).map { (result.0, $0) }
        }

        let fetchStepsPromise = Promise { seal in
            when(
                fulfilled: fetchStepsPromises
            ).done {
                seal.fulfill($0)
            }.catch { _ in
                unitIDsToBeDownloaded.forEach { self.pendingUnitsIDs.remove($0) }
                seal.reject(Error.downloadSectionFailed)
            }
        }

        return firstly {
            fetchStepsPromise
        }.done { result in
            for (unit, steps) in result {
                do {
                    try self.startDownloading(section: section, unit: unit, steps: steps)
                } catch {
                    self.pendingUnitsIDs.remove(unit.id)
                }
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

        let uncachedImagesURLs = Set(steps.compactMap { self.getUncachedImages(step: $0) }.flatMap { $0 })

        if uncachedVideosIDs.isEmpty && uncachedImagesURLs.isEmpty {
            self.pendingUnitsIDs.remove(unit.id)
            self.delegate?.syllabusDownloadsService(self, didReceiveCompletion: true, forUnitWithID: unit.id)
            return
        }

        if let section = section {
            self.unitIDsBySectionID[section.id, default: []].insert(unit.id)
        }

        // Update info about Unit -> [video id]
        let uniqueUncachedVideosIDs = uncachedVideosIDs.symmetricDifference(self.videoIDsByUnitID[unit.id, default: []])
        uncachedVideosIDs.forEach { self.videoIDsByUnitID[unit.id, default: []].insert($0) }

        // Update info about Unit -> [image URL]
        let uniqueUncachedImagesURLs = uncachedImagesURLs.symmetricDifference(
            self.imageURLsByUnitID[unit.id, default: []]
        )
        uncachedImagesURLs.forEach { self.imageURLsByUnitID[unit.id, default: []].insert($0) }

        // Start videos downloads
        let uniqueUncachedVideos = uncachedVideos.filter { uniqueUncachedVideosIDs.contains($0.id) }
        for video in uniqueUncachedVideos where !self.activeVideoDownloads.contains(video.id) {
            try self.videoDownloadingService.download(video: video)
            self.activeVideoDownloads.insert(video.id)
        }

        // Start images downloads
        for imageURL in uniqueUncachedImagesURLs where !self.activeImageDownloads.contains(imageURL) {
            let fileName = self.makeImageFileName(from: imageURL)
            let imageTaskID = try self.imageDownloadingService.download(url: imageURL, destinationFileName: fileName)
            self.imageDownloadingTaskIDByURL[imageURL] = imageTaskID
            self.activeImageDownloads.insert(imageURL)
        }
    }

    private func makeImageFileName(from url: URL) -> String {
        ImageStoredFileManager.makeFileName(imageURL: url)
    }

    private func getUncachedImages(step: Step) -> [URL] {
        guard let text = step.block.text else {
            return []
        }

        let imagesURLStrings = HTMLExtractor.extractAllTagsAttribute(tag: "img", attribute: "src", from: text)
        let imagesURLs = Set(imagesURLStrings.compactMap { URL(string: $0) })

        return imagesURLs.compactMap { imageURL -> URL? in
            let fileName = self.makeImageFileName(from: imageURL)
            return self.imageFileManager.getLocalStoredFile(fileName: fileName) == nil ? imageURL : nil
        }
    }

    private func subscribeOnDownloadingEvents() {
        self.videoDownloadingService.subscribeOnEvents { [weak self] event in
            DispatchQueue.main.async {
                self?.handleVideoUpdate(with: event)
            }
        }

        self.imageDownloadingService.subscribeOnEvents { [weak self] event in
            DispatchQueue.main.async {
                let imageTaskID = event.taskID
                print(event)
                print(imageTaskID)
            }
        }
    }

    /// Handle events from video downloading service
    private func handleVideoUpdate(with event: VideoDownloadingServiceEvent) {
        let videoID = event.videoID

        // Remove unit from the pending state
        if let unitID = self.videoIDsByUnitID.first(where: { $0.value.contains(videoID) })?.key {
            self.pendingUnitsIDs.remove(unitID)
        }

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
        when(
            fulfilled: section.units.map { self.remove(unit: $0) }
        ).done { _ in
            self.unitIDsBySectionID[section.id] = nil
        }
    }

    func remove(course: Course) -> Promise<Void> {
        when(
            fulfilled: course.sections.map { self.remove(section: $0) }
        )
    }

    // MARK: Cancel

    func cancel(unit: Unit) -> Promise<Void> {
        guard let lesson = unit.lesson else {
            return Promise(error: Error.lessonNotFound)
        }

        self.pendingUnitsIDs.remove(unit.id)

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
        Promise { seal in
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

        // Maybe it's still in the pending state
        if self.pendingUnitsIDs.contains(unit.id) {
            return .waiting
        }

        // Some videos aren't cached
        if stepsWithCachedVideoCount != stepsWithVideoCount {
            return .notCached
        }

        // All videos are cached
        return .cached(bytesTotal: unitSizeInBytes)
    }

    // swiftlint:disable:next cyclomatic_complexity
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
        var pendingUnitsCount = 0
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
            case .waiting:
                pendingUnitsCount += 1
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

        // If all units are in the pending state, then section too
        if pendingUnitsCount == units.count {
            return .waiting
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
        self.activeVideoDownloads.contains(video.id) ? self.progressByVideoID[video.id] : nil
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
        firstly {
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
        case downloadUnitFailed
        case downloadSectionFailed
        case cancelUnitFailed
        case cancelSectionFailed
    }
}
