import Foundation
import PromiseKit

// swiftlint:disable file_length

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

    func getUnitDownloadState(_ unit: Unit, in section: Section) -> CourseInfoTabSyllabus.DownloadState
    func getSectionDownloadState(_ section: Section) -> CourseInfoTabSyllabus.DownloadState
    func getCourseDownloadState(_ course: Course) -> CourseInfoTabSyllabus.DownloadState
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
    private let imageFileManager: ImageStoredFileManagerProtocol

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
    private var imageDownloadTaskIDByURL: [URL: DownloaderTaskProtocol.IDType] = [:]
    private var progressByImageURL: [URL: Float] = [:]
    private var activeImageDownloads: Set<URL> = []
    // Units ids requested to be downloaded but not being started yet.
    // To be able to return `DownloadState.waiting`.
    private var pendingUnitIDs: Set<Unit.IdType> = []

    init(
        videoDownloadingService: VideoDownloadingServiceProtocol,
        videoFileManager: VideoStoredFileManagerProtocol,
        imageDownloadingService: DownloadingServiceProtocol,
        imageFileManager: ImageStoredFileManagerProtocol,
        stepsNetworkService: StepsNetworkServiceProtocol,
        storageUsageService: StorageUsageServiceProtocol
    ) {
        self.videoDownloadingService = videoDownloadingService
        self.videoFileManager = videoFileManager
        self.imageDownloadingService = imageDownloadingService
        self.imageFileManager = imageFileManager
        self.stepsNetworkService = stepsNetworkService
        self.storageUsageService = storageUsageService

        self.subscribeOnDownloadEvents()
    }

    // MARK: Download

    func download(unit: Unit) -> Promise<Void> {
        guard let lesson = unit.lesson else {
            return Promise(error: Error.lessonNotFound)
        }

        self.pendingUnitIDs.insert(unit.id)

        return Promise { seal in
            self.fetchSteps(for: lesson).done { steps in
                try self.startDownloading(unit: unit, steps: steps)
                seal.fulfill(())
            }.catch { _ in
                self.pendingUnitIDs.remove(unit.id)
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
        unitIDsToBeDownloaded.forEach { self.pendingUnitIDs.insert($0) }

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
                unitIDsToBeDownloaded.forEach { self.pendingUnitIDs.remove($0) }
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
                    self.pendingUnitIDs.remove(unit.id)
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
        let uncachedVideoIDs = Set(uncachedVideos.map { $0.id })

        let uncachedImageURLs = Set(
            steps.flatMap {
                $0.block.imageSourceURLs.compactMap { imageURL -> URL? in
                    self.imageFileManager.getImageStoredFile(imageURL: imageURL) == nil ? imageURL : nil
                }
            }
        )

        if uncachedVideoIDs.isEmpty && uncachedImageURLs.isEmpty {
            self.pendingUnitIDs.remove(unit.id)
            self.delegate?.syllabusDownloadsService(self, didReceiveCompletion: true, forUnitWithID: unit.id)
            return
        }

        if let section = section {
            self.unitIDsBySectionID[section.id, default: []].insert(unit.id)
        }

        uncachedVideoIDs.forEach { self.videoIDsByUnitID[unit.id, default: []].insert($0) }
        uncachedImageURLs.forEach { self.imageURLsByUnitID[unit.id, default: []].insert($0) }

        // Start video downloads
        for video in uncachedVideos where !self.activeVideoDownloads.contains(video.id) {
            try self.videoDownloadingService.download(video: video)
            self.activeVideoDownloads.insert(video.id)
        }

        // Start image downloads
        for imageURL in uncachedImageURLs where !self.activeImageDownloads.contains(imageURL) {
            let filename = self.imageFileManager.makeImageFilenameFromImageDownloadURL(imageURL)
            let taskID = try self.imageDownloadingService.download(url: imageURL, destination: filename)
            self.imageDownloadTaskIDByURL[imageURL] = taskID
            self.activeImageDownloads.insert(imageURL)
        }
    }

    private func subscribeOnDownloadEvents() {
        self.videoDownloadingService.subscribeOnEvents { [weak self] event in
            DispatchQueue.main.async {
                self?.handleVideoDownloadEvent(event)
            }
        }

        self.imageDownloadingService.subscribeOnEvents { [weak self] event in
            DispatchQueue.main.async {
                self?.handleImageDownloadEvent(event)
            }
        }
    }

    /// Handle events from video downloading service
    private func handleVideoDownloadEvent(_ event: VideoDownloadingServiceEvent) {
        let videoID = event.videoID

        // Remove unit from the pending state
        if let unitID = self.videoIDsByUnitID.first(where: { $0.value.contains(videoID) })?.key {
            self.pendingUnitIDs.remove(unitID)
        }

        switch event.state {
        case .error(let error):
            self.progressByVideoID.removeValue(forKey: videoID)
            self.activeVideoDownloads.remove(videoID)

            self.delegate?.syllabusDownloadsService(self, didFailLoadVideoWithError: error)
        case .active(let progress):
            self.progressByVideoID[videoID] = progress
            self.reportVideoDownloadProgress(progress, videoID: videoID)
        case .completed:
            self.progressByVideoID[videoID] = Self.progressCompletedValue
            self.activeVideoDownloads.remove(videoID)

            self.reportVideoDownloadProgress(Self.progressCompletedValue, videoID: videoID)
            self.delegate?.syllabusDownloadsService(self, didReceiveCompletion: true, forVideoWithID: videoID)
        }
    }

    /// Handle events from image downloading service
    private func handleImageDownloadEvent(_ event: DownloadingServiceEvent) {
        let taskID = event.taskID

        guard let imageURL = self.imageDownloadTaskIDByURL.first(where: { $1 == taskID })?.key else {
            return
        }

        let unitID = self.imageURLsByUnitID.first(where: { $1.contains(imageURL) })?.key
        if let unitID = unitID {
            self.pendingUnitIDs.remove(unitID)
        }

        switch event.state {
        case .error(let error):
            self.progressByImageURL.removeValue(forKey: imageURL)
            self.activeImageDownloads.remove(imageURL)
            self.imageDownloadTaskIDByURL.removeValue(forKey: imageURL)

            self.delegate?.syllabusDownloadsService(self, didFailLoadImageWithError: error, forUnitWithID: unitID)
        case .active(let progress):
            self.progressByImageURL[imageURL] = progress
            self.reportImageDownloadProgress(progress, url: imageURL, taskID: taskID)
        case .completed:
            self.progressByImageURL[imageURL] = Self.progressCompletedValue
            self.activeImageDownloads.remove(imageURL)
            self.imageDownloadTaskIDByURL.removeValue(forKey: imageURL)

            self.reportImageDownloadProgress(Self.progressCompletedValue, url: imageURL, taskID: taskID)
            self.delegate?.syllabusDownloadsService(self, didReceiveCompletion: true, forImageURL: imageURL)
        }
    }

    private func reportVideoDownloadProgress(_ progress: Float, videoID: Video.IdType) {
        self.delegate?.syllabusDownloadsService(self, didReceiveProgress: progress, forVideoWithID: videoID)

        guard let unitID = self.videoIDsByUnitID.first(where: { $0.value.contains(videoID) })?.key else {
            return
        }

        self.updateUnitAndSectionDownloadProgress(unitID: unitID)
    }

    private func reportImageDownloadProgress(_ progress: Float, url: URL, taskID: DownloaderTaskProtocol.IDType) {
        self.delegate?.syllabusDownloadsService(self, didReceiveProgress: progress, forImageURL: url)

        guard let unitID = self.imageURLsByUnitID.first(where: { $0.value.contains(url) })?.key else {
            return
        }

        self.updateUnitAndSectionDownloadProgress(unitID: unitID)
    }

    private func updateUnitAndSectionDownloadProgress(unitID: Unit.IdType) {
        if let unitProgress = self.getUnitDownloadProgress(unitID: unitID) {
            self.delegate?.syllabusDownloadsService(self, didReceiveProgress: unitProgress, forUnitWithID: unitID)

            if unitProgress == Self.progressCompletedValue {
                self.delegate?.syllabusDownloadsService(self, didReceiveCompletion: true, forUnitWithID: unitID)
            }
        }

        if let sectionID = self.unitIDsBySectionID.first(where: { $0.value.contains(unitID) })?.key,
           let sectionProgress = self.getSectionDownloadProgress(sectionID: sectionID) {
            self.delegate?.syllabusDownloadsService(
                self, didReceiveProgress: sectionProgress, forSectionWithID: sectionID
            )

            if sectionProgress == Self.progressCompletedValue {
                self.delegate?.syllabusDownloadsService(self, didReceiveCompletion: true, forSectionWithID: sectionID)
            }
        }
    }

    // MARK: Remove

    func remove(unit: Unit) -> Promise<Void> {
        guard let lesson = unit.lesson else {
            return Promise(error: Error.lessonNotFound)
        }

        let removeStepPromises = lesson.steps.map { step -> Promise<Void> in
            Promise { seal in
                if step.block.type == .video, let video = step.block.video {
                    do {
                        try self.videoFileManager.removeVideoStoredFile(videoID: video.id)
                        video.cachedQuality = nil

                        self.videoIDsByUnitID[unit.id]?.remove(video.id)
                        self.activeVideoDownloads.remove(video.id)
                        self.progressByVideoID.removeValue(forKey: video.id)
                    } catch {
                        seal.reject(Error.removeUnitFailed)
                    }
                }

                for imageURL in step.block.imageSourceURLs {
                    do {
                        try self.imageFileManager.removeImageStoredFile(imageURL: imageURL)

                        self.imageURLsByUnitID[unit.id]?.remove(imageURL)
                        self.activeImageDownloads.remove(imageURL)
                        self.progressByImageURL.removeValue(forKey: imageURL)
                        self.imageDownloadTaskIDByURL.removeValue(forKey: imageURL)
                    } catch {
                        seal.reject(Error.removeUnitFailed)
                    }
                }

                seal.fulfill(())
            }
        }

        return Promise { seal in
            when(
                fulfilled: removeStepPromises
            ).done { _ in
                DispatchQueue.main.async {
                    CoreDataHelper.shared.save()
                }
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
            self.unitIDsBySectionID.removeValue(forKey: section.id)
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

        let unitID = unit.id
        self.pendingUnitIDs.remove(unitID)

        let cancelVideoPromises = lesson.steps
            .filter { $0.block.type == .video }
            .compactMap { $0.block.video }
            .filter { self.activeVideoDownloads.contains($0.id) }
            .map { video -> Promise<Void> in
                Promise { seal in
                    do {
                        try self.videoDownloadingService.cancelDownload(videoID: video.id)

                        self.videoIDsByUnitID[unitID]?.remove(video.id)
                        self.progressByVideoID.removeValue(forKey: video.id)
                        self.activeVideoDownloads.remove(video.id)

                        seal.fulfill(())
                    } catch {
                        seal.reject(Error.cancelUnitFailed)
                    }
                }
            }

        let cancelImagePromises = lesson.steps
            .flatMap { $0.block.imageSourceURLs }
            .filter { self.activeImageDownloads.contains($0) }
            .map { imageURL -> Promise<Void> in
                Promise { seal in
                    guard let taskID = self.imageDownloadTaskIDByURL[imageURL] else {
                        throw Error.cancelUnitFailed
                    }

                    do {
                        try self.imageDownloadingService.cancelDownload(taskID: taskID)

                        self.imageURLsByUnitID[unitID]?.remove(imageURL)
                        self.progressByImageURL.removeValue(forKey: imageURL)
                        self.activeImageDownloads.remove(imageURL)

                        seal.fulfill(())
                    } catch {
                        seal.reject(Error.cancelUnitFailed)
                    }
                }
            }

        return when(fulfilled: cancelVideoPromises + cancelImagePromises)
    }

    func cancel(section: Section) -> Promise<Void> {
        Promise { seal in
            when(
                fulfilled: section.units.map { self.cancel(unit: $0) }
            ).done { _ in
                self.unitIDsBySectionID.removeValue(forKey: section.id)
                seal.fulfill(())
            }.catch { _ in
                seal.reject(Error.cancelSectionFailed)
            }
        }
    }

    // MARK: Downloading state

    func getUnitDownloadState(_ unit: Unit, in section: Section) -> CourseInfoTabSyllabus.DownloadState {
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
        let stepsWithImagesCount = steps
            .filter { !$0.block.imageSourceURLs.isEmpty }
            .count
        // Lesson has no steps with video and images then all steps cached -> return "cached" state.
        if stepsWithVideoCount == 0 && stepsWithImagesCount == 0 {
            return .cached(bytesTotal: unitSizeInBytes, hasCachedVideosOrImages: false)
        }

        let stepsWithCachedVideoCount = steps
            .filter { $0.block.type == .video }
            .compactMap { $0.block.video?.id }
            .filter { self.videoFileManager.getVideoStoredFile(videoID: $0) != nil }
            .count

        let stepsWithCachedImagesCount = steps
            .filter { !$0.block.imageSourceURLs.isEmpty }
            .compactMap { step -> Step? in
                for imageURL in step.block.imageSourceURLs {
                    if self.imageFileManager.getImageStoredFile(imageURL: imageURL) == nil {
                        return nil
                    }
                }
                return step
            }
            .count

        if stepsWithVideoCount == stepsWithCachedVideoCount && stepsWithImagesCount == stepsWithCachedImagesCount {
            return .cached(bytesTotal: unitSizeInBytes, hasCachedVideosOrImages: true)
        }

        // Check if video or images downloading
        let stepsWithVideo = steps
            .filter { $0.block.type == .video }
            .compactMap { $0.block.video }
        let videosDownloadProgresses = stepsWithVideo.compactMap { self.getVideoDownloadProgress($0) }

        let imagesDownloadProgresses = self.imageURLsByUnitID[unit.id, default: []]
            .compactMap { self.getImageDownloadProgress(url: $0) }
        let imagesDownloadProgress = imagesDownloadProgresses.isEmpty
            ? nil
            : imagesDownloadProgresses.reduce(0, +) / Float(self.imageURLsByUnitID[unit.id, default: []].count)

        if !videosDownloadProgresses.isEmpty {
            let requestedVideosDownloadCount = Float(self.videoIDsByUnitID[unit.id, default: []].count)
            let videosDownloadProgress = videosDownloadProgresses.reduce(0, +) / requestedVideosDownloadCount

            if let imagesDownloadProgress = imagesDownloadProgress {
                return .downloading(progress: (videosDownloadProgress + imagesDownloadProgress) / 2)
            }

            return .downloading(progress: videosDownloadProgress)
        } else if let imagesDownloadProgress = imagesDownloadProgress {
            return .downloading(progress: imagesDownloadProgress)
        }

        // Try to restore downloads
        try? self.restoreDownloading(section: section, unit: unit)

        // Maybe it's still in the pending state
        if self.pendingUnitIDs.contains(unit.id) {
            return .waiting
        }

        // Some videos or images aren't cached
        let hasUncachedVideos = stepsWithCachedVideoCount != stepsWithVideoCount
        let hasUncachedImages = stepsWithCachedImagesCount != stepsWithImagesCount
        if hasUncachedVideos || hasUncachedImages {
            return .notCached
        }

        // All downloadables are cached
        return .cached(bytesTotal: unitSizeInBytes, hasCachedVideosOrImages: true)
    }

    // swiftlint:disable:next cyclomatic_complexity
    func getSectionDownloadState(_ section: Section) -> CourseInfoTabSyllabus.DownloadState {
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

        let unitStates = units.map { self.getUnitDownloadState($0, in: section) }
        var shouldBeCachedUnitsCount = 0
        var notAvailableUnitsCount = 0
        var pendingUnitsCount = 0
        var downloadingUnitProgresses: [Float] = []
        var sectionSizeInBytes: UInt64 = 0
        var containsUnitWithCachedResources = false

        for state in unitStates {
            switch state {
            case .notAvailable:
                notAvailableUnitsCount += 1
            case .notCached:
                shouldBeCachedUnitsCount += 1
            case .downloading(let progress):
                downloadingUnitProgresses.append(progress)
            case .cached(let unitSizeInBytes, let hasCachedVideosOrImages):
                sectionSizeInBytes += unitSizeInBytes
                if hasCachedVideosOrImages {
                    containsUnitWithCachedResources = true
                }
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
        return .cached(bytesTotal: sectionSizeInBytes, hasCachedVideosOrImages: containsUnitWithCachedResources)
    }

    func getCourseDownloadState(_ course: Course) -> CourseInfoTabSyllabus.DownloadState {
        let sectionStates = course.sections.map { self.getSectionDownloadState($0) }

        var cachedSectionsCount = 0
        var courseSizeInBytes: UInt64 = 0
        var containsUncachedSection = false
        var containsSectionWithCachedResources = false

        for sectionDownloadState in sectionStates {
            switch sectionDownloadState {
            case .notCached:
                containsUncachedSection = true
            case .cached(let bytesTotal, let hasCachedVideosOrImages):
                cachedSectionsCount += 1
                courseSizeInBytes += bytesTotal
                if hasCachedVideosOrImages {
                    containsSectionWithCachedResources = true
                }
            default:
                continue
            }
        }

        if course.sectionsArray.count == cachedSectionsCount {
            return .cached(
                bytesTotal: courseSizeInBytes,
                hasCachedVideosOrImages: containsSectionWithCachedResources
            )
        }

        return containsUncachedSection ? .notCached : .notAvailable
    }

    private func getVideoDownloadProgress(_ video: Video) -> Float? {
        self.activeVideoDownloads.contains(video.id) ? self.progressByVideoID[video.id] : nil
    }

    private func getImageDownloadProgress(url: URL) -> Float? {
        self.activeImageDownloads.contains(url) ? self.progressByImageURL[url] : nil
    }

    private func getUnitDownloadProgress(unitID: Unit.IdType) -> Float? {
        let videoIDs = self.videoIDsByUnitID[unitID, default: []]
        let imageURLs = self.imageURLsByUnitID[unitID, default: []]

        if videoIDs.isEmpty && imageURLs.isEmpty {
            return nil
        }

        var videosProgress: Float?
        if !videoIDs.isEmpty {
            videosProgress = videoIDs.reduce(0, { $0 + (self.progressByVideoID[$1] ?? 0) }) / Float(videoIDs.count)
        }

        var imagesProgress: Float?
        if !imageURLs.isEmpty {
            imagesProgress = imageURLs.reduce(0, { $0 + (self.progressByImageURL[$1] ?? 0) }) / Float(imageURLs.count)
        }

        if let videosProgress = videosProgress, let imagesProgress = imagesProgress {
            return (videosProgress + imagesProgress) / 2
        } else if let videosProgress = videosProgress {
            return videosProgress
        } else if let imagesProgress = imagesProgress {
            return imagesProgress
        }

        return nil
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

    // MARK: - Private Helpers -

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

        let imageURLs = lesson.steps.flatMap { $0.block.imageSourceURLs }

        for imageURL in imageURLs where !self.activeImageDownloads.contains(imageURL) {
            guard let taskID = self.imageDownloadTaskIDByURL[imageURL] else {
                continue
            }

            if self.imageDownloadingService.isTaskActive(taskID: taskID) {
                self.activeImageDownloads.insert(imageURL)
                self.imageURLsByUnitID[unit.id, default: []].insert(imageURL)
                self.unitIDsBySectionID[section.id, default: []].insert(unit.id)
            }
        }
    }

    private func fetchSteps(for lesson: Lesson) -> Promise<[Step]> {
        firstly {
            self.stepsNetworkService.fetch(ids: lesson.stepsArray)
        }.then { steps -> Promise<[Step]> in
            DispatchQueue.main.async {
                lesson.steps = steps
                CoreDataHelper.shared.save()
            }
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
