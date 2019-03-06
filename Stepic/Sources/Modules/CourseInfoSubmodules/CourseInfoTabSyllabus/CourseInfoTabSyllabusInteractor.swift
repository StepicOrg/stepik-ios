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
    func doSectionsFetching(request: CourseInfoTabSyllabus.ShowSyllabus.Request)
    func doSectionFetching(request: CourseInfoTabSyllabus.ShowSyllabusSection.Request)
    func doDownloadButtonAction(request: CourseInfoTabSyllabus.DownloadButtonAction.Request)
    func doUnitSelection(request: CourseInfoTabSyllabus.UnitSelect.Request)
    func doPersonalDeadlinesAction(request: CourseInfoTabSyllabus.PersonalDeadlinesButtonInteraction.Request)
}

final class CourseInfoTabSyllabusInteractor: CourseInfoTabSyllabusInteractorProtocol {
    weak var moduleOutput: CourseInfoTabSyllabusOutputProtocol?

    private let presenter: CourseInfoTabSyllabusPresenterProtocol
    private let provider: CourseInfoTabSyllabusProviderProtocol
    private let videoFileManager: VideoStoredFileManagerProtocol
    private let syllabusDownloadsInteractionService: SyllabusDownloadsInteractionServiceProtocol
    private let personalDeadlinesService: PersonalDeadlinesServiceProtocol
    private let nextLessonService: NextLessonServiceProtocol
    private let tooltipStorageManager: TooltipStorageManagerProtocol

    private var currentCourse: Course?
    private var currentSections: [UniqueIdentifierType: Section] = [:] {
        didSet {
            self.refreshNextLessonService()
        }
    }

    private var currentUnits: [UniqueIdentifierType: Unit?] = [:] {
        didSet {
            self.refreshNextLessonService()
        }
    }

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

    private var shouldOpenedAnalyticsEventSend = false

    // Fetch syllabus only after previous fetch completed
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    // Online mode: fetch section only when offline fetching completed
    private let sectionFetchSemaphore = DispatchSemaphore(value: 0)

    private lazy var sectionsFetchBackgroundQueue = DispatchQueue(label: "com.AlexKarpov.Stepic.CourseInfoTabSyllabusInteractor.SectionsFetch")
    private lazy var unitsFetchBackgroundQueue = DispatchQueue(label: "com.AlexKarpov.Stepic.CourseInfoTabSyllabusInteractor.UnitsFetch")

    init(
        presenter: CourseInfoTabSyllabusPresenterProtocol,
        provider: CourseInfoTabSyllabusProviderProtocol,
        videoFileManager: VideoStoredFileManagerProtocol,
        syllabusDownloadsInteractionService: SyllabusDownloadsInteractionServiceProtocol,
        personalDeadlinesService: PersonalDeadlinesServiceProtocol,
        nextLessonService: NextLessonServiceProtocol,
        tooltipStorageManager: TooltipStorageManagerProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
        self.videoFileManager = videoFileManager
        self.personalDeadlinesService = personalDeadlinesService
        self.nextLessonService = nextLessonService
        self.tooltipStorageManager = tooltipStorageManager

        self.syllabusDownloadsInteractionService = syllabusDownloadsInteractionService
        self.syllabusDownloadsInteractionService.delegate = self
    }

    // MARK: Public methods

    func doSectionsFetching(request: CourseInfoTabSyllabus.ShowSyllabus.Request) {
        guard let course = self.currentCourse else {
            return
        }

        self.sectionsFetchBackgroundQueue.async { [weak self] in
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
                        strongSelf.updateSyllabusHeader()
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

    func doSectionFetching(request: CourseInfoTabSyllabus.ShowSyllabusSection.Request) {
        self.unitsFetchBackgroundQueue.async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            // Check whether section fetching completed
            strongSelf.sectionFetchSemaphore.wait()
            strongSelf.sectionFetchSemaphore.signal()

            guard let section = strongSelf.currentSections[request.uniqueIdentifier] else {
                return
            }

            print("course info tab syllabus interactor: start fetching section from network, id = \(section.id)")
            strongSelf.fetchSyllabusSection(section: section).done { response in
                DispatchQueue.main.async {
                    print("course info tab syllabus interactor: finish fetching section from network, id = \(section.id)")
                    strongSelf.presenter.presentCourseSyllabus(response: response)
                    strongSelf.updateSyllabusHeader()
                }
            }.catch { error in
                print("course info tab syllabus interactor: error while fetching section from network, error = \(error)")
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
                return isCached
                    ? self.removeCached(unit: unit)
                    : self.startDownloading(unit: unit)
            case .downloading(_):
                self.cancelDownloading(unit: unit)
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
            case .downloading(_):
                self.cancelDownloading(section: section)
            default:
                break
            }
        }

        func handleAll() {
            self.presenter.presentWaitingState(response: .init(shouldDismiss: false))
            self.forceLoadAllSectionsIfNeeded().done {
                for (uid, section) in self.currentSections {
                    let sectionState = self.getDownloadingState(for: section)
                    if case .available(let isCached) = sectionState, !isCached {
                        handleSection(id: uid)
                    }
                }
                self.updateSyllabusHeader(shouldForceDisableDownloadAll: true)
            }.ensure {
                self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
            }.catch { _ in
                // TODO: handle error
            }
        }

        switch request.type {
        case .all:
            return handleAll()
        case .section(let uniqueIdentifier):
            return handleSection(id: uniqueIdentifier)
        case .unit(let uniqueIdentifier):
            return handleUnit(id: uniqueIdentifier)
        }
    }

    func doUnitSelection(request: CourseInfoTabSyllabus.UnitSelect.Request) {
        guard let unit = self.currentUnits[request.uniqueIdentifier] as? Unit else {
            return
        }

        // If all units already loaded then just present unit
        // otherwise fetch all sections
        // TODO: remove after APPS-2206
        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))
        self.forceLoadAllSectionsIfNeeded().done { _ in
            self.requestUnitPresentation(unit)
        }.catch { _ in
            print("course info tab syllabus interactor: unable to load all sections, request unit presentation w/o completed syllabus structure")
            self.requestUnitPresentation(unit)
        }.finally {
            self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
        }
    }

    func doPersonalDeadlinesAction(request: CourseInfoTabSyllabus.PersonalDeadlinesButtonInteraction.Request) {
        guard let course = self.currentCourse else {
            return
        }

        if self.personalDeadlinesService.hasDeadlines(in: course) {
            self.moduleOutput?.presentPersonalDeadlinesSettings(for: course)
        } else {
            self.moduleOutput?.presentPersonalDeadlinesCreation(for: course)
        }
    }

    // MARK: Private methods

    private func forceLoadAllSectionsIfNeeded() -> Promise<Void> {
        let allSections = Array(self.currentSections.values)
        let allUnits = allSections.map { $0.unitsArray }.reduce([], +)
        let availableUnits = self.currentUnits.values.compactMap { $0?.id }

        return Promise { seal in
            if availableUnits.sorted() == allUnits.sorted() {
                seal.fulfill(())
            } else {
                // Load all units in each section
                let unitsPromises = self.currentSections.values.map { self.fetchSyllabusSection(section: $0) }
                when(fulfilled: unitsPromises).done { _ in
                    seal.fulfill(())
                }.catch { error in
                    seal.reject(error)
                }
            }
        }
    }

    private func updateSyllabusHeader(shouldForceDisableDownloadAll: Bool = false) {
        guard let course = self.currentCourse else {
            return
        }

        let isPersonalDeadlinesAvailable = self.personalDeadlinesService.canAddDeadlines(
            in: course
        ) || self.personalDeadlinesService.hasDeadlines(in: course)

        let isDownloadAllAvailable: Bool = {
            if case .available(_) = self.getDownloadingStateForCourse() {
                return true
            }
            return false
        }() && !shouldForceDisableDownloadAll
        self.presenter.presentCourseSyllabusHeader(
            response: .init(
                isPersonalDeadlinesAvailable: isPersonalDeadlinesAvailable,
                isDownloadAllAvailable: isDownloadAllAvailable,
                isPersonalDeadlinesTooltipVisible: !self.tooltipStorageManager.didShowOnPersonalDeadlinesButton
            )
        )

        self.tooltipStorageManager.didShowOnPersonalDeadlinesButton = true
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
            }.catch { error in
                print("course info tab syllabus interactor: unable to fetch section, error = \(error)")
                seal.reject(Error.fetchFailed)
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
            }.catch { error in
                print("course info tab syllabus interactor: unable to fetch syllabus, error = \(error)")
                seal.reject(Error.fetchFailed)
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
                .sorted(by: { ($0.entity?.position ?? 0) < ($1.entity?.position ?? 0) }),
            sectionsDeadlines: self.currentCourse?.sectionDeadlines ?? [],
            isEnrolled: self.currentCourse?.enrolled ?? false
        )
    }

    private func getUniqueIdentifierBySectionID(_ sectionID: Section.IdType) -> UniqueIdentifierType {
        return "\(sectionID)"
    }

    private func getUniqueIdentifierByUnitID(_ unitID: Unit.IdType) -> UniqueIdentifierType {
        return "\(unitID)"
    }

    private func refreshNextLessonService() {
        let orderedSections = self.currentSections.values.sorted(by: { $0.position < $1.position })
        self.nextLessonService.configure(with: orderedSections)
    }

    private func requestUnitPresentation(_ unit: Unit) {
        // Check whether unit is in exam section
        if let section = self.currentSections[self.getUniqueIdentifierBySectionID(unit.sectionId)],
            section.isExam, section.isReachable {
            self.moduleOutput?.presentExamLesson()
            return
        }

        self.moduleOutput?.presentLesson(in: unit)
    }

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension CourseInfoTabSyllabusInteractor: CourseInfoTabSyllabusInputProtocol {
    func handleControllerAppearance() {
        if let course = self.currentCourse {
            AmplitudeAnalyticsEvents.Sections.opened(
                courseID: course.id,
                courseTitle: course.title
            ).send()
            self.shouldOpenedAnalyticsEventSend = false
        } else {
            self.shouldOpenedAnalyticsEventSend = true
        }
    }

    func update(with course: Course, isOnline: Bool) {
        print("course info tab syllabus interactor: updated from parent module, isOnline = \(isOnline)")
        self.currentCourse = course
        self.isOnline = isOnline
        self.getCourseSyllabus()

        if self.shouldOpenedAnalyticsEventSend {
            AmplitudeAnalyticsEvents.Sections.opened(
                courseID: course.id,
                courseTitle: course.title
            ).send()
            self.shouldOpenedAnalyticsEventSend = false
        }
    }
}

extension CourseInfoTabSyllabusInteractor: SyllabusDownloadsInteractionServiceDelegate {
    private func getStateUpdateByDownloadSource(
        _ source: SyllabusTreeNode.Source
    ) -> CourseInfoTabSyllabus.DownloadButtonStateUpdate.Source? {
        switch source {
        case .unit(let id):
            if let unit = self.currentUnits[self.getUniqueIdentifierByUnitID(id)] as? Unit {
                return .unit(entity: unit)
            }
            return nil
        case .section(let id):
            if let section = self.currentSections[self.getUniqueIdentifierBySectionID(id)] {
                return .section(entity: section)
            }
            return nil
        default:
            return nil
        }
    }

    func downloadsInteractionService(
        _ downloadsInteractionService: SyllabusDownloadsInteractionServiceProtocol,
        didReceiveProgress progress: Float,
        source: SyllabusTreeNode.Source
    ) {
        let sourceType = self.getStateUpdateByDownloadSource(source)
        DispatchQueue.main.async { [weak self] in
            if let sourceType = sourceType {
                self?.presenter.presentDownloadButtonUpdate(
                    response: CourseInfoTabSyllabus.DownloadButtonStateUpdate.Response(
                        source: sourceType,
                        downloadState: .downloading(progress: progress)
                    )
                )
            }
        }
    }

    func downloadsInteractionService(
        _ downloadsInteractionService: SyllabusDownloadsInteractionServiceProtocol,
        didReceiveCompletion completed: Bool,
        source: SyllabusTreeNode.Source
    ) {
        let sourceType = self.getStateUpdateByDownloadSource(source)
        DispatchQueue.main.async { [weak self] in
            if let sourceType = sourceType {
                self?.presenter.presentDownloadButtonUpdate(
                    response: CourseInfoTabSyllabus.DownloadButtonStateUpdate.Response(
                        source: sourceType,
                        downloadState: .available(isCached: completed)
                    )
                )
            }
        }
    }
}

extension CourseInfoTabSyllabusInteractor: SectionNavigationDelegate {
    func didRequestPreviousUnitPresentationForLessonInUnit(unitID: Unit.IdType) {
        guard let unit = self.currentUnits[self.getUniqueIdentifierByUnitID(unitID)] as? Unit,
              let previousUnit = self.nextLessonService.findPreviousUnit(for: unit) as? Unit else {
            return
        }

        self.requestUnitPresentation(previousUnit)
    }

    func didRequestNextUnitPresentationForLessonInUnit(unitID: Unit.IdType) {
        guard let unit = self.currentUnits[self.getUniqueIdentifierByUnitID(unitID)] as? Unit,
              let nextUnit = self.nextLessonService.findNextUnit(for: unit) as? Unit else {
            return
        }

        self.requestUnitPresentation(nextUnit)
    }
}

// MARK: Private methods for file managing & downloading

extension CourseInfoTabSyllabusInteractor {
    private func cancelDownloading(unit: Unit) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Unit.cancel, parameters: nil)
        AmplitudeAnalyticsEvents.Downloads.cancelled(content: "lesson").send()

        guard let lesson = unit.lesson else {
            print("course info tab syllabus interactor: unit doesn't have lesson, unit id = \(unit.id)")
            return
        }

        try? self.syllabusDownloadsInteractionService.cancelDownloading(
            syllabusTree: self.makeSyllabusTree(unit: unit, steps: lesson.steps)
        )
    }

    private func cancelDownloading(section: Section) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Section.cancel, parameters: nil)
        AmplitudeAnalyticsEvents.Downloads.cancelled(content: "section").send()

        for unit in section.units {
            guard let lesson = unit.lesson else {
                print("course info tab syllabus interactor: unit doesn't have lesson, unit id = \(unit.id)")
                return
            }

            try? self.syllabusDownloadsInteractionService.cancelDownloading(
                syllabusTree: self.makeSyllabusTree(section: section, unit: unit, steps: lesson.steps)
            )
        }
    }

    private func removeCached(unit: Unit) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Unit.delete, parameters: nil)
        AmplitudeAnalyticsEvents.Downloads.deleted(content: "lesson").send()

        guard let lesson = unit.lesson else {
            print("course info tab syllabus interactor: unit doesn't have lesson, unit id = \(unit.id)")
            return
        }

        for step in lesson.steps {
            guard let video = step.block.video else {
                return
            }

            do {
                try self.videoFileManager.removeVideoStoredFile(videoID: video.id)
                video.cachedQuality = nil
                CoreDataHelper.instance.save()
            } catch {
                print("course info tab syllabus interactor: error while file removing = \(error)")
            }
        }

        self.presenter.presentDownloadButtonUpdate(
            response: CourseInfoTabSyllabus.DownloadButtonStateUpdate.Response(
                source: .unit(entity: unit),
                downloadState: self.getDownloadingState(for: unit)
            )
        )
    }

    private func removeCached(section: Section) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Section.delete, parameters: nil)
        AmplitudeAnalyticsEvents.Downloads.deleted(content: "section").send()

        section.units.forEach { self.removeCached(unit: $0) }

        self.presenter.presentDownloadButtonUpdate(
            response: CourseInfoTabSyllabus.DownloadButtonStateUpdate.Response(
                source: .section(entity: section),
                downloadState: self.getDownloadingState(for: section)
            )
        )
    }

    private func startDownloading(unit: Unit) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Unit.cache, parameters: nil)
        AmplitudeAnalyticsEvents.Downloads.started(content: "lesson").send()

        guard let lesson = unit.lesson else {
            print("course info tab syllabus interactor: unit doesn't have lesson, unit id = \(unit.id)")
            return
        }

        self.presenter.presentDownloadButtonUpdate(
            response: CourseInfoTabSyllabus.DownloadButtonStateUpdate.Response(
                source: .unit(entity: unit),
                downloadState: .waiting
            )
        )

        self.provider.fetchSteps(for: lesson).done { steps in
            try? self.syllabusDownloadsInteractionService.startDownloading(
                syllabusTree: self.makeSyllabusTree(unit: unit, steps: steps)
            )
        }.catch { _ in
            // TODO: error
        }
    }

    private func startDownloading(section: Section) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Section.cache, parameters: nil)
        AmplitudeAnalyticsEvents.Downloads.started(content: "section").send()

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
                try? self.syllabusDownloadsInteractionService.startDownloading(
                    syllabusTree: self.makeSyllabusTree(section: section, unit: unit, steps: steps)
                )
            }.catch { _ in
                // TODO: error
            }
        }
    }

    private func makeSyllabusTree(
        section: Section? = nil,
        unit: Unit,
        steps: [Step]
    ) -> SyllabusTreeNode {
        var stepsTrees: [SyllabusTreeNode] = []
        for step in steps {
            guard step.block.name == "video",
                let video = step.block.video else {
                    continue
            }

            if self.videoFileManager.getVideoStoredFile(videoID: video.id) == nil {
                stepsTrees.append(
                    SyllabusTreeNode(
                        value: .step(id: step.id),
                        children: [SyllabusTreeNode(value: .video(entity: video))]
                    )
                )
            }
        }

        let unitTree = SyllabusTreeNode(
            value: .unit(id: unit.id),
            children: stepsTrees
        )

        if let section = section {
            return SyllabusTreeNode(
                value: .section(id: section.id),
                children: [unitTree]
            )
        }
        return unitTree
    }

    private func getDownloadingState(for unit: Unit) -> CourseInfoTabSyllabus.DownloadState {
        // If section is unreachable or exam then all units are not available
        guard let section = self.currentSections[self.getUniqueIdentifierBySectionID(unit.sectionId)],
              !section.isExam, section.isReachable else {
            return .notAvailable
        }

        guard let lesson = unit.lesson else {
            // We should call this method only with completely loaded units
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

        // Check if video is downloading
        let stepsWithVideo = steps
            .filter { $0.block.name == "video" }
            .compactMap { $0.block.video }
        let downloadingVideosProgresses = stepsWithVideo.compactMap {
            self.syllabusDownloadsInteractionService.getDownloadProgress(for: $0)
        }

        // TODO: remove calculation, get progress for unit from service
        if downloadingVideosProgresses.count > 0 {
            return .downloading(
                progress: downloadingVideosProgresses.reduce(0, +) / Float(downloadingVideosProgresses.count)
            )
        }

        // Try to restore downloads
        try? self.syllabusDownloadsInteractionService.restoreDownloading(
            syllabusTree: self.makeSyllabusTree(unit: unit, steps: steps)
        )

        // Some videos aren't cached
        if stepsWithCachedVideoCount != stepsWithVideoCount {
            return .available(isCached: false)
        }

        // All videos are cached
        return .available(isCached: true)
    }

    private func getDownloadingStateForCourse() -> CourseInfoTabSyllabus.DownloadState {
        let sectionStates = self.currentSections.values.map { self.getDownloadingState(for: $0) }

        let containsUncachedSection = sectionStates.contains(where: { state in
            if case .available(let isCached) = state {
                return !isCached
            }
            return false
        })

        return containsUncachedSection ? .available(isCached: false) : .notAvailable
    }

    private func getDownloadingState(for section: Section) -> CourseInfoTabSyllabus.DownloadState {
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

        let unitStates = units.map { self.getDownloadingState(for: $0) }
        var shouldBeCachedUnitsCount = 0
        var notAvailableUnitsCount = 0
        var downloadingUnitProgresses: [Float] = []

        for state in unitStates {
            switch state {
            case .notAvailable:
                notAvailableUnitsCount += 1
            case .available(let isCached):
                shouldBeCachedUnitsCount += isCached ? 0 : 1
            case .downloading(let progress):
                downloadingUnitProgresses.append(progress)
            default:
                break
            }
        }

        // Downloading state
        if downloadingUnitProgresses.count == units.count && units.count > 0 {
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
            return .available(isCached: false)
        }

        // All units are cached, section too
        return .available(isCached: true)
    }
}
