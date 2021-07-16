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

    func getUnitDownloadState(
        _ unit: UnitPlainObject,
        in section: SectionPlainObject
    ) -> Guarantee<CourseInfoTabSyllabus.DownloadState>
    func getSectionDownloadState(_ section: SectionPlainObject) -> Guarantee<CourseInfoTabSyllabus.DownloadState>
    func getCourseDownloadState(_ course: CoursePlainObject) -> Guarantee<CourseInfoTabSyllabus.DownloadState>
}

extension SyllabusDownloadsServiceProtocol {
    func getUnitDownloadState(_ unit: Unit, in section: Section) -> Guarantee<CourseInfoTabSyllabus.DownloadState> {
        self.getUnitDownloadState(UnitPlainObject(unit: unit), in: SectionPlainObject(section: section))
    }

    func getSectionDownloadState(_ section: Section) -> Guarantee<CourseInfoTabSyllabus.DownloadState> {
        self.getSectionDownloadState(SectionPlainObject(section: section))
    }

    func getCourseDownloadState(_ course: Course) -> Guarantee<CourseInfoTabSyllabus.DownloadState> {
        self.getCourseDownloadState(CoursePlainObject(course: course))
    }
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

    private let attemptsRepository: AttemptsRepositoryProtocol
    private let submissionsRepository: SubmissionsRepositoryProtocol
    private let stepsNetworkService: StepsNetworkServiceProtocol
    private let userAccountService: UserAccountServiceProtocol
    private let storageUsageService: StorageUsageServiceProtocol

    private lazy var privateQueue = DispatchQueue(label: "com.AlexKarpov.Stepic.SyllabusDownloadsService")

    private struct MutableState {
        // Section -> Unit -> [Videos|Images]
        var unitIDsBySectionID: [Section.IdType: Set<Unit.IdType>] = [:]
        // Video
        var videoIDsByUnitID: [Unit.IdType: Set<Video.IdType>] = [:]
        var progressByVideoID: [Video.IdType: Float] = [:]
        var activeVideoDownloads: Set<Video.IdType> = []
        // Image
        var imageURLsByUnitID: [Unit.IdType: Set<URL>] = [:]
        var imageDownloadTaskIDByURL: [URL: DownloaderTaskProtocol.IDType] = [:]
        var progressByImageURL: [URL: Float] = [:]
        var activeImageDownloads: Set<URL> = []
        // Units ids requested to be downloaded but not being started yet.
        // To be able to return `DownloadState.waiting`.
        var pendingUnitIDs: Set<Unit.IdType> = []
    }
    /// Protected `MutableState` value that provides thread-safe access to state values.
    @Protected
    private var mutableState = MutableState()

    init(
        videoDownloadingService: VideoDownloadingServiceProtocol,
        videoFileManager: VideoStoredFileManagerProtocol,
        imageDownloadingService: DownloadingServiceProtocol,
        imageFileManager: ImageStoredFileManagerProtocol,
        attemptsRepository: AttemptsRepositoryProtocol,
        submissionsRepository: SubmissionsRepositoryProtocol,
        stepsNetworkService: StepsNetworkServiceProtocol,
        storageUsageService: StorageUsageServiceProtocol,
        userAccountService: UserAccountServiceProtocol
    ) {
        self.videoDownloadingService = videoDownloadingService
        self.videoFileManager = videoFileManager
        self.imageDownloadingService = imageDownloadingService
        self.imageFileManager = imageFileManager
        self.attemptsRepository = attemptsRepository
        self.submissionsRepository = submissionsRepository
        self.stepsNetworkService = stepsNetworkService
        self.storageUsageService = storageUsageService
        self.userAccountService = userAccountService

        self.subscribeOnDownloadEvents()
    }

    // MARK: Download

    func download(unit: Unit) -> Promise<Void> {
        guard let lesson = unit.lesson else {
            return Promise(error: Error.lessonNotFound)
        }

        self.mutableState.pendingUnitIDs.insert(unit.id)

        return Promise { seal in
            self.fetchSteps(for: lesson).done { steps in
                try self.startDownloading(unit: unit, steps: steps)
                seal.fulfill(())
            }.catch { _ in
                self.mutableState.pendingUnitIDs.remove(unit.id)
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
        unitIDsToBeDownloaded.forEach { self.mutableState.pendingUnitIDs.insert($0) }

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
                unitIDsToBeDownloaded.forEach { self.mutableState.pendingUnitIDs.remove($0) }
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
                    self.mutableState.pendingUnitIDs.remove(unit.id)
                }
            }
        }
    }

    private func startDownloading(section: Section? = nil, unit: Unit, steps: [Step]) throws {
        let uncachedVideos = steps.compactMap { step -> Video? in
            guard step.block.type == .video,
                  let video = step.block.video,
                  !video.urls.isEmpty else {
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
            self.mutableState.pendingUnitIDs.remove(unit.id)
            self.delegate?.syllabusDownloadsService(self, didReceiveCompletion: true, forUnitWithID: unit.id)
            return
        }

        if let section = section {
            self.mutableState.unitIDsBySectionID[section.id, default: []].insert(unit.id)
        }

        uncachedVideoIDs.forEach { self.mutableState.videoIDsByUnitID[unit.id, default: []].insert($0) }
        uncachedImageURLs.forEach { self.mutableState.imageURLsByUnitID[unit.id, default: []].insert($0) }

        // Start video downloads
        for video in uncachedVideos where !self.mutableState.activeVideoDownloads.contains(video.id) {
            try self.videoDownloadingService.download(video: video)
            self.mutableState.activeVideoDownloads.insert(video.id)
        }

        // Start image downloads
        for imageURL in uncachedImageURLs where !self.mutableState.activeImageDownloads.contains(imageURL) {
            let filename = self.imageFileManager.makeImageFilenameFromImageDownloadURL(imageURL)
            let taskID = try self.imageDownloadingService.download(url: imageURL, destination: filename)
            self.mutableState.imageDownloadTaskIDByURL[imageURL] = taskID
            self.mutableState.activeImageDownloads.insert(imageURL)
        }
    }

    private func subscribeOnDownloadEvents() {
        self.videoDownloadingService.subscribeOnEvents { [weak self] event in
            guard let strongSelf = self else {
                return
            }

            strongSelf.privateQueue.async {
                strongSelf.handleVideoDownloadEvent(event)
            }
        }

        self.imageDownloadingService.subscribeOnEvents { [weak self] event in
            guard let strongSelf = self else {
                return
            }

            strongSelf.privateQueue.async {
                strongSelf.handleImageDownloadEvent(event)
            }
        }
    }

    /// Handle events from video downloading service
    private func handleVideoDownloadEvent(_ event: VideoDownloadingServiceEvent) {
        let videoID = event.videoID

        // Remove unit from the pending state
        if let unitID = self.mutableState.videoIDsByUnitID.first(where: { $0.value.contains(videoID) })?.key {
            self.mutableState.pendingUnitIDs.remove(unitID)
        }

        switch event.state {
        case .error(let error):
            self.mutableState.progressByVideoID.removeValue(forKey: videoID)
            self.mutableState.activeVideoDownloads.remove(videoID)

            DispatchQueue.main.async {
                self.delegate?.syllabusDownloadsService(self, didFailLoadVideoWithError: error)
            }
        case .active(let progress):
            self.mutableState.progressByVideoID[videoID] = progress
            self.reportVideoDownloadProgress(progress, videoID: videoID)
        case .completed:
            self.mutableState.progressByVideoID[videoID] = Self.progressCompletedValue
            self.mutableState.activeVideoDownloads.remove(videoID)

            self.reportVideoDownloadProgress(Self.progressCompletedValue, videoID: videoID)

            DispatchQueue.main.async {
                self.delegate?.syllabusDownloadsService(self, didReceiveCompletion: true, forVideoWithID: videoID)
            }
        }
    }

    /// Handle events from image downloading service
    private func handleImageDownloadEvent(_ event: DownloadingServiceEvent) {
        let taskID = event.taskID

        guard let imageURL = self.mutableState.imageDownloadTaskIDByURL.first(where: { $1 == taskID })?.key else {
            return
        }

        let unitID = self.mutableState.imageURLsByUnitID.first(where: { $1.contains(imageURL) })?.key
        if let unitID = unitID {
            self.mutableState.pendingUnitIDs.remove(unitID)
        }

        switch event.state {
        case .error(let error):
            self.mutableState.progressByImageURL.removeValue(forKey: imageURL)
            self.mutableState.activeImageDownloads.remove(imageURL)
            self.mutableState.imageDownloadTaskIDByURL.removeValue(forKey: imageURL)

            DispatchQueue.main.async {
                self.delegate?.syllabusDownloadsService(self, didFailLoadImageWithError: error, forUnitWithID: unitID)
            }
        case .active(let progress):
            self.mutableState.progressByImageURL[imageURL] = progress
            self.reportImageDownloadProgress(progress, url: imageURL, taskID: taskID)
        case .completed:
            self.mutableState.progressByImageURL[imageURL] = Self.progressCompletedValue
            self.mutableState.activeImageDownloads.remove(imageURL)
            self.mutableState.imageDownloadTaskIDByURL.removeValue(forKey: imageURL)

            self.reportImageDownloadProgress(Self.progressCompletedValue, url: imageURL, taskID: taskID)

            DispatchQueue.main.async {
                self.delegate?.syllabusDownloadsService(self, didReceiveCompletion: true, forImageURL: imageURL)
            }
        }
    }

    private func reportVideoDownloadProgress(_ progress: Float, videoID: Video.IdType) {
        DispatchQueue.main.async {
            self.delegate?.syllabusDownloadsService(self, didReceiveProgress: progress, forVideoWithID: videoID)
        }

        guard let unitID = self.mutableState.videoIDsByUnitID.first(where: { $0.value.contains(videoID) })?.key else {
            return
        }

        self.updateUnitAndSectionDownloadProgress(unitID: unitID)
    }

    private func reportImageDownloadProgress(_ progress: Float, url: URL, taskID: DownloaderTaskProtocol.IDType) {
        DispatchQueue.main.async {
            self.delegate?.syllabusDownloadsService(self, didReceiveProgress: progress, forImageURL: url)
        }

        guard let unitID = self.mutableState.imageURLsByUnitID.first(where: { $0.value.contains(url) })?.key else {
            return
        }

        self.updateUnitAndSectionDownloadProgress(unitID: unitID)
    }

    private func updateUnitAndSectionDownloadProgress(unitID: Unit.IdType) {
        if let unitProgress = self.getUnitDownloadProgress(unitID: unitID) {
            DispatchQueue.main.async {
                self.delegate?.syllabusDownloadsService(self, didReceiveProgress: unitProgress, forUnitWithID: unitID)
            }

            if unitProgress == Self.progressCompletedValue {
                DispatchQueue.main.async {
                    self.delegate?.syllabusDownloadsService(self, didReceiveCompletion: true, forUnitWithID: unitID)
                }
            }
        }

        if let sectionID = self.mutableState.unitIDsBySectionID.first(where: { $0.value.contains(unitID) })?.key,
           let sectionProgress = self.getSectionDownloadProgress(sectionID: sectionID) {
            DispatchQueue.main.async {
                self.delegate?.syllabusDownloadsService(
                    self, didReceiveProgress: sectionProgress, forSectionWithID: sectionID
                )
            }

            if sectionProgress == Self.progressCompletedValue {
                DispatchQueue.main.async {
                    self.delegate?.syllabusDownloadsService(
                        self, didReceiveCompletion: true, forSectionWithID: sectionID
                    )
                }
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

                        self.mutableState.videoIDsByUnitID[unit.id]?.remove(video.id)
                        self.mutableState.activeVideoDownloads.remove(video.id)
                        self.mutableState.progressByVideoID.removeValue(forKey: video.id)
                    } catch {
                        seal.reject(Error.removeUnitFailed)
                    }
                }

                for imageURL in step.block.imageSourceURLs {
                    do {
                        try self.imageFileManager.removeImageStoredFile(imageURL: imageURL)

                        self.mutableState.imageURLsByUnitID[unit.id]?.remove(imageURL)
                        self.mutableState.activeImageDownloads.remove(imageURL)
                        self.mutableState.progressByImageURL.removeValue(forKey: imageURL)
                        self.mutableState.imageDownloadTaskIDByURL.removeValue(forKey: imageURL)
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
            self.mutableState.unitIDsBySectionID.removeValue(forKey: section.id)
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
        self.mutableState.pendingUnitIDs.remove(unitID)

        let cancelVideoPromises = lesson.steps
            .filter { $0.block.type == .video }
            .compactMap { $0.block.video }
            .filter { self.mutableState.activeVideoDownloads.contains($0.id) }
            .map { video -> Promise<Void> in
                Promise { seal in
                    do {
                        try self.videoDownloadingService.cancelDownload(videoID: video.id)

                        self.mutableState.videoIDsByUnitID[unitID]?.remove(video.id)
                        self.mutableState.progressByVideoID.removeValue(forKey: video.id)
                        self.mutableState.activeVideoDownloads.remove(video.id)

                        seal.fulfill(())
                    } catch {
                        seal.reject(Error.cancelUnitFailed)
                    }
                }
            }

        let cancelImagePromises = lesson.steps
            .flatMap { $0.block.imageSourceURLs }
            .filter { self.mutableState.activeImageDownloads.contains($0) }
            .map { imageURL -> Promise<Void> in
                Promise { seal in
                    guard let taskID = self.mutableState.imageDownloadTaskIDByURL[imageURL] else {
                        throw Error.cancelUnitFailed
                    }

                    do {
                        try self.imageDownloadingService.cancelDownload(taskID: taskID)

                        self.mutableState.imageURLsByUnitID[unitID]?.remove(imageURL)
                        self.mutableState.progressByImageURL.removeValue(forKey: imageURL)
                        self.mutableState.activeImageDownloads.remove(imageURL)

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
                self.mutableState.unitIDsBySectionID.removeValue(forKey: section.id)
                seal.fulfill(())
            }.catch { _ in
                seal.reject(Error.cancelSectionFailed)
            }
        }
    }

    // MARK: Downloading state

    func getUnitDownloadState(
        _ unit: UnitPlainObject,
        in section: SectionPlainObject
    ) -> Guarantee<CourseInfoTabSyllabus.DownloadState> {
        Guarantee { seal in
            self.privateQueue.async {
                let downloadState = self._getUnitDownloadState(unit: unit, section: section)
                DispatchQueue.main.async {
                    seal(downloadState)
                }
            }
        }
    }

    func getSectionDownloadState(_ section: SectionPlainObject) -> Guarantee<CourseInfoTabSyllabus.DownloadState> {
        Guarantee { seal in
            self.privateQueue.async {
                let downloadState = self._getSectionDownloadState(section: section)
                DispatchQueue.main.async {
                    seal(downloadState)
                }
            }
        }
    }

    func getCourseDownloadState(_ course: CoursePlainObject) -> Guarantee<CourseInfoTabSyllabus.DownloadState> {
        Guarantee { seal in
            self.privateQueue.async {
                let downloadState = self._getCourseDownloadState(course: course)
                DispatchQueue.main.async {
                    seal(downloadState)
                }
            }
        }
    }

    private func _getUnitDownloadState(
        unit: UnitPlainObject,
        section: SectionPlainObject
    ) -> CourseInfoTabSyllabus.DownloadState {
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
            .filter { lesson.stepsIDs.contains($0.id) }
            .count != lesson.stepsIDs.count
        if hasUncachedSteps {
            return .notCached
        }

        // Iterate through steps and determine final state
        let stepsWithVideoCount = steps
            .filter { $0.block.type == .video && !($0.block.video?.urls.isEmpty ?? true) }
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
            .compactMap { step -> StepPlainObject? in
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
        let videosDownloadProgresses = stepsWithVideo.compactMap { self.getVideoDownloadProgress(videoID: $0.id) }

        let imagesDownloadProgresses = self.mutableState.imageURLsByUnitID[unit.id, default: []]
            .compactMap { self.getImageDownloadProgress(url: $0) }
        let imagesDownloadProgress = imagesDownloadProgresses.isEmpty
            ? nil
            : imagesDownloadProgresses.reduce(0, +) / Float(self.mutableState.imageURLsByUnitID[unit.id, default: []].count)

        if !videosDownloadProgresses.isEmpty {
            let requestedVideosDownloadCount = Float(self.mutableState.videoIDsByUnitID[unit.id, default: []].count)
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
        if self.mutableState.pendingUnitIDs.contains(unit.id) {
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
    private func _getSectionDownloadState(section: SectionPlainObject) -> CourseInfoTabSyllabus.DownloadState {
        let units = section.units

        // Unreachable and exam not available
        if section.isExam || !section.isReachable {
            return .notAvailable
        }

        // If have unloaded units for lesson then show "not available" state
        let hasUncachedUnits = units
            .filter { section.unitsIDs.contains($0.id) }
            .count != section.unitsIDs.count
        if hasUncachedUnits {
            return .notAvailable
        }

        let unitStates = units.map { self._getUnitDownloadState(unit: $0, section: section) }
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

    private func _getCourseDownloadState(course: CoursePlainObject) -> CourseInfoTabSyllabus.DownloadState {
        let sectionStates = course.sections.map { self._getSectionDownloadState(section: $0) }

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

        if course.sectionsIDs.count == cachedSectionsCount {
            return .cached(
                bytesTotal: courseSizeInBytes,
                hasCachedVideosOrImages: containsSectionWithCachedResources
            )
        }

        return containsUncachedSection ? .notCached : .notAvailable
    }

    private func getVideoDownloadProgress(videoID: Video.IdType) -> Float? {
        self.mutableState.activeVideoDownloads.contains(videoID) ? self.mutableState.progressByVideoID[videoID] : nil
    }

    private func getImageDownloadProgress(url: URL) -> Float? {
        self.mutableState.activeImageDownloads.contains(url) ? self.mutableState.progressByImageURL[url] : nil
    }

    private func getUnitDownloadProgress(unitID: Unit.IdType) -> Float? {
        let videoIDs = self.mutableState.videoIDsByUnitID[unitID, default: []]
        let imageURLs = self.mutableState.imageURLsByUnitID[unitID, default: []]

        if videoIDs.isEmpty && imageURLs.isEmpty {
            return nil
        }

        var videosProgress: Float?
        if !videoIDs.isEmpty {
            videosProgress = videoIDs.reduce(Float(0), { $0 + (self.mutableState.progressByVideoID[$1] ?? Float(0)) })
                / Float(videoIDs.count)
        }

        var imagesProgress: Float?
        if !imageURLs.isEmpty {
            imagesProgress = imageURLs.reduce(Float(0), { $0 + (self.mutableState.progressByImageURL[$1] ?? Float(0)) })
                / Float(imageURLs.count)
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
        guard let unitIDs = self.mutableState.unitIDsBySectionID[sectionID] else {
            return nil
        }

        if unitIDs.isEmpty {
            return nil
        }

        return unitIDs.reduce(0, { $0 + (self.getUnitDownloadProgress(unitID: $1) ?? 0) }) / Float(unitIDs.count)
    }

    // MARK: - Private Helpers -

    private func restoreDownloading(section: SectionPlainObject, unit: UnitPlainObject) throws {
        guard let lesson = unit.lesson else {
            throw Error.lessonNotFound
        }

        let videos = lesson.steps
            .filter { $0.block.type == .video }
            .compactMap { $0.block.video }

        for video in videos where !self.mutableState.activeVideoDownloads.contains(video.id) {
            if self.videoDownloadingService.isTaskActive(videoID: video.id) {
                self.mutableState.activeVideoDownloads.insert(video.id)
                self.mutableState.videoIDsByUnitID[unit.id, default: []].insert(video.id)
                self.mutableState.unitIDsBySectionID[section.id, default: []].insert(unit.id)
            }
        }

        let imageURLs = lesson.steps.flatMap { $0.block.imageSourceURLs }

        for imageURL in imageURLs where !self.mutableState.activeImageDownloads.contains(imageURL) {
            guard let taskID = self.mutableState.imageDownloadTaskIDByURL[imageURL] else {
                continue
            }

            if self.imageDownloadingService.isTaskActive(taskID: taskID) {
                self.mutableState.activeImageDownloads.insert(imageURL)
                self.mutableState.imageURLsByUnitID[unit.id, default: []].insert(imageURL)
                self.mutableState.unitIDsBySectionID[section.id, default: []].insert(unit.id)
            }
        }
    }

    private func fetchSteps(for lesson: Lesson) -> Promise<[Step]> {
        firstly {
            self.stepsNetworkService.fetch(ids: lesson.stepsArray)
        }.then { steps -> Promise<[Step]> in
            lesson.steps = steps
            CoreDataHelper.shared.save()

            return .value(steps)
        }.then { steps -> Promise<[Step]> in
            when(
                fulfilled: steps.map { self.fetchAttemptForStep($0) }
            ).map { steps }
        }
    }

    private func fetchAttemptForStep(_ step: Step) -> Promise<Void> {
        guard step.block.managedName != nil,
              step.block.name != BlockType.text.rawValue,
              step.block.name != BlockType.video.rawValue else {
            return .value(())
        }

        guard let userID = self.userAccountService.currentUser?.id else {
            return Promise(error: Error.unknownUser)
        }

        return firstly { () -> Promise<[Attempt]> in
            self.attemptsRepository
                .fetch(stepID: step.id, userID: userID, blockName: step.block.name)
                .map { $0.0 }
        }.then { attempts -> Promise<Attempt> in
            if let attempt = attempts.first {
                return .value(attempt)
            }
            return self.attemptsRepository.create(stepID: step.id, blockName: step.block.name)
        }.then { attempt in
            self.submissionsRepository
                .fetchSubmissionsForAttempt(attemptID: attempt.id, blockName: step.block.name, dataSourceType: .remote)
                .asVoid()
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
        case unknownUser
    }
}
