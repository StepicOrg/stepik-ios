//
//  CourseInfoTabSyllabusCourseInfoTabSyllabusInteractor.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright 2018 stepik-ios. All rights reserved.
//

import Foundation
import PromiseKit

protocol CourseInfoTabSyllabusInteractorProtocol {
    func getCourseSyllabus()
    func fetchSyllabusSection(request: CourseInfoTabSyllabus.ShowSyllabusSection.Request)
    func doDownloadButtonAction(request: CourseInfoTabSyllabus.DownloadButtonAction.Request)
}

final class CourseInfoTabSyllabusInteractor: CourseInfoTabSyllabusInteractorProtocol {
    let presenter: CourseInfoTabSyllabusPresenterProtocol
    let provider: CourseInfoTabSyllabusProviderProtocol
    let videoFileManager: VideoStoredFileManagerProtocol
    let downloadingService: SyllabusStructureDownloadingService = SyllabusStructureDownloadingService(
        videoDownloadingService: VideoDownloadingService.shared
    )

    private var currentCourse: Course?
    private var currentSections: [UniqueIdentifierType: Section] = [:]
    private var currentUnits: [UniqueIdentifierType: Unit?] = [:]

    private var isOnline = false {
        willSet {
            if !newValue && self.isOnline {
                fatalError("Online -> offline transition not supported")
            }
        }
    }
    private var didLoadFromNetwork = false {
        willSet {
            if !newValue && self.didLoadFromNetwork {
                fatalError("Online -> offline transition not supported")
            }
        }
    }

    // Fetch syllabus only after previous fetch completed
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    // Online mode: present section only previous presentation completed
    private let sectionPresentSemaphore = DispatchSemaphore(value: 1)
    // Online mode: fetch section only when offline fetching completed
    private let sectionFetchSemaphore = DispatchSemaphore(value: 0)

    private lazy var backgroundQueue = DispatchQueue(label: "course_info_interactor.syllabus")

    init(
        presenter: CourseInfoTabSyllabusPresenterProtocol,
        provider: CourseInfoTabSyllabusProviderProtocol,
        videoFileManager: VideoStoredFileManagerProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
        self.videoFileManager = videoFileManager

        self.downloadingService.delegate = self
    }

    // MARK: Public methods

    func getCourseSyllabus() {
        guard let course = self.currentCourse else {
            return
        }

        self.backgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.fetchSemaphore.wait()

            let isOnline = strongSelf.isOnline
            print("course info tab syllabus interactor: start fetching syllabus, isOnline = \(isOnline)")

            strongSelf.fetchSyllabusInAppropriateMode(
                course: course,
                isOnline: isOnline
            ).done { response in
                DispatchQueue.main.async {
                    print("course info tab syllabus interactor: finish fetching syllabus, isOnline = \(isOnline)")
                    strongSelf.presenter.presentCourseSyllabus(response: response)

                    if isOnline && !strongSelf.didLoadFromNetwork {
                        strongSelf.didLoadFromNetwork = true
                        strongSelf.sectionFetchSemaphore.signal()
                    }
                }
            }.catch { _ in
                // TODO: handle
            }.finally {
                strongSelf.fetchSemaphore.signal()
            }
        }
    }

    func fetchSyllabusSection(request: CourseInfoTabSyllabus.ShowSyllabusSection.Request) {
        self.backgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            guard let section = strongSelf.currentSections[request.uniqueIdentifier] else {
                return
            }

            // Check whether section fetching completed
            strongSelf.sectionFetchSemaphore.wait()
            strongSelf.sectionFetchSemaphore.signal()

            print("course info tab syllabus interactor: start fetching section from network, id = \(section.id)")
            strongSelf.fetchSyllabusSection(section: section).done { response in
                _ = strongSelf.sectionPresentSemaphore.wait(timeout: .now() + 0.5)
                DispatchQueue.main.async { [weak self] in
                    print("course info tab syllabus interactor: finish fetching section from network, id = \(section.id)")
                    self?.presenter.presentCourseSyllabus(response: response)
                    self?.sectionPresentSemaphore.signal()
                }
            }.catch { _ in
                // TODO: handle
            }
        }
    }

    func doDownloadButtonAction(request: CourseInfoTabSyllabus.DownloadButtonAction.Request) {
        func handleUnit(id: UniqueIdentifierType) {
            guard let unit = self.currentUnits[id] as? Unit else {
                print("course info tab syllabus interactor: unit doesn't exist in current units, id = \(id)")
                return
            }

            let currentState = self.getDownloadingState(for: unit)
            switch currentState {
            case .available(let isCached):
                return isCached ? self.removeCached(unit: unit) : self.startDownloading(unit: unit)
            default:
                break
            }
        }

        func handleSection(id: UniqueIdentifierType) {
            guard let section = self.currentSections[id] else {
                print("course info tab syllabus interactor: section doesn't exist in current sections, id = \(id)")
                return
            }

            let currentState = self.getDownloadingState(for: section)
            switch currentState {
            case .available(let isCached):
                return isCached
                    ? self.removeCached(section: section)
                    : self.startDownloading(section: section)
            default:
                break
            }
        }

        func handleAll() { }

        switch request.type {
        case .all:
            return handleAll()
        case .section(let uniqueIdentifier):
            return handleSection(id: uniqueIdentifier)
        case .unit(let uniqueIdentifier):
            return handleUnit(id: uniqueIdentifier)
        }
    }

    // MARK: Private methods

    func removeCached(unit: Unit) { }

    func removeCached(section: Section) { }

    func startDownloading(unit: Unit) {
        guard let lesson = unit.lesson else {
            print("course info tab syllabus interactor: unit doesn't have lesson, unit id = \(unit.id)")
            return
        }

        self.provider.fetchSteps(for: lesson).done { steps in
            self.downloadingService.startDownloading(cut: .init(steps: steps, unit: unit, section: unit.section!, observationLevel: .unit))
        }.catch { _ in
            // TODO: error
        }
    }

    func startDownloading(section: Section) {
        let hasUncachedUnits = section.units
            .filter { section.unitsArray.contains($0.id) }
            .count != section.unitsArray.count
        if hasUncachedUnits {
            print("course info tab syllabus interactor: section doesn't have some units = \(section.id)")
            return
        }

        for unit in section.units {
            guard let lesson = unit.lesson else {
                continue
            }

            self.provider.fetchSteps(for: lesson).done { steps in
                self.downloadingService.startDownloading(cut: .init(steps: steps, unit: unit, section: section, observationLevel: .section))
            }.catch { _ in
                // TODO: error
            }
        }
    }

    private func fetchSyllabusSection(
        section: Section
    ) -> Promise<CourseInfoTabSyllabus.ShowSyllabus.Response> {
        return Promise { seal in
            self.provider.fetchUnitsWithLessons(
                for: section,
                shouldUseNetwork: true
            ).done { units in
                self.updateCurrentData(units: units, shouldRemoveAll: false)

                let data = self.makeSyllabusDataFromCurrentData()
                seal.fulfill(.init(result: .success(data)))
            }.catch { _ in
                // TODO: error
            }
        }
    }

    private func fetchSyllabusInAppropriateMode(
        course: Course,
        isOnline: Bool
    ) -> Promise<CourseInfoTabSyllabus.ShowSyllabus.Response> {
        return Promise { seal in
            // Load sections & progresses
            self.provider.fetchSections(for: course, shouldUseNetwork: isOnline).then {
                sections -> Promise<([Section], [[Unit]])> in
                // In offline mode load units & lessons just now
                // In online mode load units & lessons on demand

                let offlineUnitsPromise = when(
                    fulfilled: sections.map { section in
                        self.provider.fetchUnitsWithLessons(for: section, shouldUseNetwork: false)
                    }
                )
                let onlineUnitsPromise = Promise.value([[Unit]]())

                let unitsPromise = isOnline ? onlineUnitsPromise : offlineUnitsPromise
                return unitsPromise.map { (sections, $0) }
            }.done { result in
                let sections = result.0
                let units = Array(result.1.joined())

                self.updateCurrentData(sections: sections, units: units, shouldRemoveAll: true)

                let data = self.makeSyllabusDataFromCurrentData()
                seal.fulfill(.init(result: .success(data)))
            }.catch { _ in
                // TODO: error
            }
        }
    }

    private func updateCurrentData(sections: [Section]? = nil, units: [Unit], shouldRemoveAll: Bool) {
        if shouldRemoveAll {
            self.currentSections.removeAll(keepingCapacity: true)
            self.currentUnits.removeAll(keepingCapacity: true)
        }

        for section in sections ?? [] {
            self.currentSections[self.getUniqueIdentifierBySectionID(section.id)] = section
            for unitID in section.unitsArray {
                self.currentUnits[self.getUniqueIdentifierByUnitID(unitID)] = nil
            }
        }

        for unit in units {
            self.currentUnits[self.getUniqueIdentifierByUnitID(unit.id)] = unit
        }
    }

    private func makeSyllabusDataFromCurrentData() -> CourseInfoTabSyllabus.SyllabusData {
        return CourseInfoTabSyllabus.SyllabusData(
            sections: self.currentSections
                .map { uid, entity in
                    .init(
                        uniqueIdentifier: uid,
                        entity: entity,
                        downloadState: self.getDownloadingState(for: entity)
                    )
                }
                .sorted(by: { $0.entity.position < $1.entity.position }),
            units: self.currentUnits
                .map { uid, entity in
                    var state: CourseInfoTabSyllabus.DownloadState
                    if let unit = entity {
                        state = self.getDownloadingState(for: unit)
                    } else {
                        state = .notAvailable
                    }

                    return .init(
                        uniqueIdentifier: uid,
                        entity: entity,
                        downloadState: state
                    )
                }
                .sorted(by: { ($0.entity?.position ?? 0) < ($1.entity?.position ?? 0) })
        )
    }

    private func getUniqueIdentifierBySectionID(_ sectionID: Section.IdType) -> UniqueIdentifierType {
        return "\(sectionID)"
    }

    private func getUniqueIdentifierByUnitID(_ unitID: Unit.IdType) -> UniqueIdentifierType {
        return "\(unitID)"
    }

    private func getDownloadingState(for unit: Unit) -> CourseInfoTabSyllabus.DownloadState {
        guard let lesson = unit.lesson else {
            // We should call this method only with completely load units
            // But return "not cached" in this case
            return .available(isCached: false)
        }

        let steps = lesson.steps

        // If have unloaded steps for lesson then show "not cached" state
        let hasUncachedSteps = steps
            .filter { lesson.stepsArray.contains($0.id) }
            .count != lesson.stepsArray.count
        if hasUncachedSteps {
            return .available(isCached: false)
        }

        // Iterate through steps and determine final state
        let stepsWithVideoCount = steps
            .filter { $0.block.name == "video" }
            .count
        let stepsWithCachedVideoCount = steps
            .filter { $0.block.name == "video" }
            .compactMap { $0.block.video?.id }
            .filter { self.videoFileManager.getVideoStoredFile(videoID: $0) != nil }
            .count

        // Lesson has no steps with video
        if stepsWithVideoCount == 0 {
            return .notAvailable
        }

        // Some videos aren't cached
        if stepsWithCachedVideoCount != stepsWithVideoCount {
            return .available(isCached: false)
        }

        // TODO: check current downloads

        // All videos are cached
        return .available(isCached: true)
    }

    private func getDownloadingState(for section: Section) -> CourseInfoTabSyllabus.DownloadState {
        let units = section.units

        // If have unloaded units for lesson then show "not available" state
        let hasUncachedUnits = units
            .filter { section.unitsArray.contains($0.id) }
            .count != section.unitsArray.count
        if hasUncachedUnits {
            return .notAvailable
        }

        let unitStates = units.map { self.getDownloadingState(for: $0) }
        var shouldBeCachedUnitsCount = 0
        var notAvailableUnitsCount = 0

        for state in unitStates {
            switch state {
            case .notAvailable:
                notAvailableUnitsCount += 1
            case .available(let isCached):
                shouldBeCachedUnitsCount += isCached ? 0 : 1
            default:
                break
            }
        }

        // If all units are not available to downloading then section is not available to
        if notAvailableUnitsCount == units.count {
            return .notAvailable
        }

        // If some units are not cached then section is available to downloading
        if shouldBeCachedUnitsCount > 0 {
            return .available(isCached: false)
        }

        // All units are cached, section too
        return .available(isCached: true)
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension CourseInfoTabSyllabusInteractor: CourseInfoTabSyllabusInputProtocol {
    func update(with course: Course, isOnline: Bool) {
        self.currentCourse = course
        self.isOnline = isOnline
        self.getCourseSyllabus()
    }
}

extension CourseInfoTabSyllabusInteractor: SyllabusStructureDownloadingServiceDelegate {
    func downloadingService(_ downloadingService: SyllabusStructureDownloadingService, didReceiveProgress progress: Float, source: DownloadSource) {
        print(source.description, progress)
        DispatchQueue.main.async {
            switch source {
            case .unit(let unit):
                self.presenter.presentDownloadButtonUpdate(
                    response: CourseInfoTabSyllabus.DownloadButtonStateUpdate.Response(
                        type: .unit(entity: unit),
                        downloadState: .downloading(progress: progress)
                    )
                )
            case .section(let section):
                self.presenter.presentDownloadButtonUpdate(
                    response: CourseInfoTabSyllabus.DownloadButtonStateUpdate.Response(
                        type: .section(entity: section),
                        downloadState: .downloading(progress: progress)
                    )
                )
            default:
                break
            }
        }
    }
}

struct SyllabusCut {
    enum ObservationLevel: Int, Comparable {
        case unit = 0
        case section = 1
        case all = 2

        static func < (lhs: SyllabusCut.ObservationLevel, rhs: SyllabusCut.ObservationLevel) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }

    let steps: [Step]
    let unit: Unit
    let section: Section
    let observationLevel: ObservationLevel
}

protocol SyllabusStructureDownloadingServiceDelegate: class {
    func downloadingService(
        _ downloadingService: SyllabusStructureDownloadingService,
        didReceiveProgress progress: Float,
        source: DownloadSource
    )
}

enum DownloadSource: Equatable, CustomStringConvertible {
    case step(entity: Step)
    case unit(entity: Unit)
    case section(entity: Section)
    case course

    static func == (lhs: DownloadSource, rhs: DownloadSource) -> Bool {
        switch (lhs, rhs) {
        case (.step(let a), .step(let b)):
            return a.id == b.id
        case (.unit(let a), .unit(let b)):
            return a.id == b.id
        case (.section(let a), .section(let b)):
            return a.id == b.id
        case (.course, .course):
            return true
        default:
            return false
        }
    }

    var description: String {
        switch self {
        case .step(let step):
            return ".step(id = \(step.id))"
        case .unit(let unit):
            return ".unit(id = \(unit.id))"
        case .section(let section):
            return ".section(id = \(section.id))"
        case .course:
            return ".course"
        }
    }
}

final class SyllabusStructureDownloadingService {
    let videoDownloadingService: VideoDownloadingServiceProtocol

    private var currentDownloads: [DownloaderTaskProtocol.IDType: DownloadRecord] = [:]
    private var currentRecords: [DownloadRecord] = []

    weak var delegate: SyllabusStructureDownloadingServiceDelegate?

    init(
        videoDownloadingService: VideoDownloadingServiceProtocol,
        delegate: SyllabusStructureDownloadingServiceDelegate? = nil
    ) {
        self.videoDownloadingService = videoDownloadingService
        self.delegate = delegate

        self.videoDownloadingService.subscribeOnEvents { event in
            self.handleUpdate(event: event)
        }
    }

    func startDownloading(cut: SyllabusCut) {
        let observer: DownloadRecord.Observer = { [weak self] record in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.downloadingService(
                strongSelf,
                didReceiveProgress: record.progress,
                source: record.source
            )
        }

        // TODO: handle case when lesson doesn't have steps with video
        let stepsWithVideo = cut.steps.filter { $0.block.name == "video" }

        var stepsRecords: [DownloadRecord] = []
        var videosForDownloading: [(DownloadRecord, Video)] = []
        for step in stepsWithVideo {
            guard let video = step.block.video else {
                continue
            }

            let record = DownloadRecord(
                source: .step(entity: step),
                childrens: [],
                observer: observer
            )

            stepsRecords.append(record)
            videosForDownloading.append((record, video))
        }

        // Build tree: create new or merge
        // Unit

        let unitSource = DownloadSource.unit(entity: cut.unit)
        let shouldUnitReportProgress = cut.observationLevel >= .unit
        var newUnitRecord: DownloadRecord?

        if let unitWithGivenSourceInTree = self.currentRecords.first(
            where: { $0.source == unitSource }
        ) {
            // Unit exists in the tree, assign steps
            unitWithGivenSourceInTree.childrens.append(contentsOf: stepsRecords)
            unitWithGivenSourceInTree.shouldReportProgress = shouldUnitReportProgress
            stepsRecords.forEach { $0.parent = unitWithGivenSourceInTree }
        } else {
            // Insert unit to the tree
            let record = DownloadRecord(
                source: unitSource,
                childrens: stepsRecords,
                shouldReportProgress: shouldUnitReportProgress,
                observer: observer
            )
            self.currentRecords.append(record)
            stepsRecords.forEach { $0.parent = record }
            newUnitRecord = record
        }

        // Section

        let sectionSource = DownloadSource.section(entity: cut.section)
        let sectionChildrens = [newUnitRecord].compactMap { $0 }
        let shouldSectionReportProgress = cut.observationLevel >= .section
        var newSectionRecord: DownloadRecord?

        if let sectionWithGivenSourceInTree = self.currentRecords.first(
            where: { $0.source == sectionSource }
        ) {
            // Section exists in the tree, assign unit
            sectionWithGivenSourceInTree.childrens.append(contentsOf: sectionChildrens)
            sectionWithGivenSourceInTree.shouldReportProgress = shouldSectionReportProgress
            sectionChildrens.forEach { $0.parent = sectionWithGivenSourceInTree }
        } else {
            // Insert unit to the tree
            let record = DownloadRecord(
                source: sectionSource,
                childrens: sectionChildrens,
                shouldReportProgress: shouldSectionReportProgress,
                observer: observer
            )
            self.currentRecords.append(record)
            sectionChildrens.forEach { $0.parent = record }
            newSectionRecord = record
        }

        // Course

        let courseSource = DownloadSource.course
        let courseChildrens = [newSectionRecord].compactMap { $0 }
        let shouldCourseReportProgress = cut.observationLevel >= .all

        if let courseWithGivenSourceInTree = self.currentRecords.first(
            where: { $0.source == courseSource }
        ) {
            // Course exists in the tree, assign section
            courseWithGivenSourceInTree.childrens.append(contentsOf: courseChildrens)
            courseWithGivenSourceInTree.shouldReportProgress = shouldCourseReportProgress
            courseChildrens.forEach { $0.parent = courseWithGivenSourceInTree }
        } else {
            // Insert unit to the tree
            let record = DownloadRecord(
                source: courseSource,
                childrens: courseChildrens,
                shouldReportProgress: shouldCourseReportProgress
            )
            self.currentRecords.append(record)
            courseChildrens.forEach { $0.parent = record }
        }

        // Start downloading

        for (record, video) in videosForDownloading {
            // FIXME: VideosInfo
            let url = video.getUrlForQuality(VideosInfo.watchingVideoQuality)
            let taskID = self.videoDownloadingService.download(
                videoID: video.id,
                url: url
            )

            self.currentDownloads[taskID] = record
        }
    }

    private func markAsDirtyAllTree(record: DownloadRecord) {
        if let parent = record.parent {
            record.isDirty = true
            self.markAsDirtyAllTree(record: parent)
        }
    }

    private func handleUpdate(event: VideoDownloadingServiceEvent) {
        guard let downloadRecord = self.currentDownloads[event.taskID] else {
            return
        }

        switch event.state {
        case .error:
            // Downloading failed, remove task and detach from parent
            downloadRecord.parent?.childrens.removeAll(where: { $0 === downloadRecord })
            self.markAsDirtyAllTree(record: downloadRecord)
            self.currentDownloads.removeValue(forKey: event.taskID)
        case .active(let progress):
            downloadRecord.progress = progress
            self.markAsDirtyAllTree(record: downloadRecord)
        case .completed(_):
            downloadRecord.progress = 1.0
            self.markAsDirtyAllTree(record: downloadRecord)
            self.currentDownloads.removeValue(forKey: event.taskID)
        }
    }

    private final class DownloadRecord {
        typealias Observer = (DownloadRecord) -> Void

        let source: DownloadSource
        var parent: DownloadRecord?
        var childrens: [DownloadRecord]

        private var observer: Observer?

        /// Set true if should report progress
        var shouldReportProgress: Bool {
            didSet {
                if self.shouldReportProgress {
                    self.observer?(self)
                }
            }
        }

        /// Set true if some childrens were updated
        var isDirty = false {
            didSet {
                if self.isDirty && self.shouldReportProgress {
                    self.observer?(self)
                }
            }
        }
        private var currentProgress: Float = 0

        var progress: Float {
            get {
                if case .step(_) = self.source {
                    return self.currentProgress
                } else {
                    if self.isDirty {
                        self.currentProgress = self.childrens.map { $0.progress }.reduce(0, +)
                            / Float(self.childrens.count)
                        self.isDirty = false
                    }
                    return self.currentProgress
                }
            }
            set {
                if case .step(_) = self.source {
                    self.currentProgress = max(self.currentProgress, newValue)
                }
            }
        }

        init(
            source: DownloadSource,
            childrens: [DownloadRecord],
            shouldReportProgress: Bool = false,
            observer: Observer? = nil
        ) {
            self.source = source
            self.childrens = childrens
            self.shouldReportProgress = shouldReportProgress
            self.observer = observer
        }
    }
}
