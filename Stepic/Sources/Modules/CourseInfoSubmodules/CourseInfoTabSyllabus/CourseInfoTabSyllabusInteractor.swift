import Foundation
import PromiseKit

// swiftlint:disable file_length
protocol CourseInfoTabSyllabusInteractorProtocol {
    func doSectionsFetch(request: CourseInfoTabSyllabus.SyllabusLoad.Request)
    func doSectionFetch(request: CourseInfoTabSyllabus.SyllabusSectionLoad.Request)
    func doDownloadButtonAction(request: CourseInfoTabSyllabus.DownloadButtonAction.Request)
    func doUnitSelection(request: CourseInfoTabSyllabus.UnitSelection.Request)
    func doPersonalDeadlinesAction(request: CourseInfoTabSyllabus.PersonalDeadlinesButtonAction.Request)
}

final class CourseInfoTabSyllabusInteractor: CourseInfoTabSyllabusInteractorProtocol {
    weak var moduleOutput: CourseInfoTabSyllabusOutputProtocol?

    private let presenter: CourseInfoTabSyllabusPresenterProtocol
    private let provider: CourseInfoTabSyllabusProviderProtocol
    private let personalDeadlinesService: PersonalDeadlinesServiceProtocol
    private let nextLessonService: NextLessonServiceProtocol
    private let networkReachabilityService: NetworkReachabilityServiceProtocol
    private let tooltipStorageManager: TooltipStorageManagerProtocol
    private let useCellularDataForDownloadsStorageManager: UseCellularDataForDownloadsStorageManagerProtocol
    private let syllabusDownloadsService: SyllabusDownloadsServiceProtocol
    private let analytics: Analytics

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

    private var remoteFetchedSectionsUniqueIdentifiers: Set<UniqueIdentifierType> = []

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
    private var connectionType: NetworkReachabilityConnectionType { self.networkReachabilityService.connectionType }
    private var shouldCheckUseOfCellularDataForDownloads = true

    private var shouldOpenedAnalyticsEventSend = false

    private var reportedToAnalyticsVideoDownloadIDs = Set<Video.IdType>()

    // Fetch syllabus only after previous fetch completed
    private let fetchSemaphore = DispatchSemaphore(value: 1)
    // Online mode: fetch section only when offline fetching completed
    private let sectionFetchSemaphore = DispatchSemaphore(value: 0)

    private lazy var sectionsFetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.CourseInfoTabSyllabusInteractor.SectionsFetch"
    )
    private lazy var unitsFetchBackgroundQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.CourseInfoTabSyllabusInteractor.UnitsFetch"
    )

    init(
        presenter: CourseInfoTabSyllabusPresenterProtocol,
        provider: CourseInfoTabSyllabusProviderProtocol,
        analytics: Analytics,
        personalDeadlinesService: PersonalDeadlinesServiceProtocol,
        nextLessonService: NextLessonServiceProtocol,
        networkReachabilityService: NetworkReachabilityServiceProtocol,
        tooltipStorageManager: TooltipStorageManagerProtocol,
        useCellularDataForDownloadsStorageManager: UseCellularDataForDownloadsStorageManagerProtocol,
        syllabusDownloadsService: SyllabusDownloadsServiceProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
        self.analytics = analytics
        self.personalDeadlinesService = personalDeadlinesService
        self.nextLessonService = nextLessonService
        self.networkReachabilityService = networkReachabilityService
        self.tooltipStorageManager = tooltipStorageManager
        self.useCellularDataForDownloadsStorageManager = useCellularDataForDownloadsStorageManager

        self.syllabusDownloadsService = syllabusDownloadsService
        self.syllabusDownloadsService.delegate = self
    }

    // MARK: - Public API

    func doSectionsFetch(request: CourseInfoTabSyllabus.SyllabusLoad.Request) {
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

            strongSelf.fetchSyllabusInAppropriateMode(course: course, isOnline: isOnline).done { response in
                DispatchQueue.main.async {
                    print("course info tab syllabus interactor: finish fetching syllabus, isOnline = \(isOnline)")
                    strongSelf.presenter.presentCourseSyllabus(response: response)

                    if isOnline && !strongSelf.didLoadFromNetwork {
                        strongSelf.didLoadFromNetwork = true
                        strongSelf.updateSyllabusHeader()
                        strongSelf.sectionFetchSemaphore.signal()
                    }
                }
            }.catch { error in
                // TODO: handle error
                print("course info tab syllabus interactor: error while fetching syllabus, isOnline = \(isOnline), error = \(error)")
            }.finally {
                strongSelf.fetchSemaphore.signal()
            }
        }
    }

    func doSectionFetch(request: CourseInfoTabSyllabus.SyllabusSectionLoad.Request) {
        // Skip request if already fetched earlier
        if self.remoteFetchedSectionsUniqueIdentifiers.contains(request.uniqueIdentifier) {
            return
        }
        self.remoteFetchedSectionsUniqueIdentifiers.insert(request.uniqueIdentifier)

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
                strongSelf.remoteFetchedSectionsUniqueIdentifiers.remove(request.uniqueIdentifier)
            }
        }
    }

    func doDownloadButtonAction(request: CourseInfoTabSyllabus.DownloadButtonAction.Request) {
        let shouldConfirmUseOfCellularDataForDownloading = self.shouldCheckUseOfCellularDataForDownloads
            && self.connectionType == .wwan
            && !self.useCellularDataForDownloadsStorageManager.shouldUseCellularDataForDownloads

        func handleUnit(id: UniqueIdentifierType) {
            guard let unit = self.currentUnits[id] as? Unit else {
                return print("course info tab syllabus interactor: unit doesn't exists in current units, id = \(id)")
            }

            let currentState = self.getDownloadingStateForUnit(unit)
            switch currentState {
            case .cached:
                self.presenter.presentDeleteDownloadsConfirmationAlert(
                    response: .init(
                        type: .unit,
                        cancelActionHandler: { [weak self] in
                            self?.analytics.send(
                                .deleteDownloadConfirmationInteracted(content: .lesson, isConfirmed: false)
                            )
                        },
                        confirmedActionHandler: { [weak self] in
                            guard let strongSelf = self else {
                                return
                            }

                            strongSelf.analytics.send(
                                .deleteDownloadConfirmationInteracted(content: .lesson, isConfirmed: true)
                            )
                            strongSelf.removeCached(unit: unit)
                        }
                    )
                )
            case .notCached:
                if shouldConfirmUseOfCellularDataForDownloading {
                    self.presenter.presentDownloadOnCellularDataAlert(
                        response: .init(
                            useAlwaysActionHandler: { [weak self] in
                                guard let strongSelf = self else {
                                    return
                                }

                                strongSelf.useCellularDataForDownloadsStorageManager
                                    .shouldUseCellularDataForDownloads = true
                                strongSelf.startDownloading(unit: unit)
                            },
                            justOnceActionHandler: { [weak self] in
                                self?.startDownloading(unit: unit)
                            }
                        )
                    )
                } else {
                    self.startDownloading(unit: unit)
                }
            case .downloading:
                self.cancelDownloading(unit: unit)
            default:
                break
            }
        }

        func handleSection(id: UniqueIdentifierType) {
            guard let section = self.currentSections[id] else {
                return print("course info tab syllabus interactor: section doesn't exists in current sections, id = \(id)")
            }

            let currentState = self.getDownloadingStateForSection(section)
            switch currentState {
            case .cached:
                self.presenter.presentDeleteDownloadsConfirmationAlert(
                    response: .init(
                        type: .section,
                        cancelActionHandler: { [weak self] in
                            self?.analytics.send(
                                .deleteDownloadConfirmationInteracted(content: .section, isConfirmed: false)
                            )
                        },
                        confirmedActionHandler: { [weak self] in
                            guard let strongSelf = self else {
                                return
                            }

                            strongSelf.analytics.send(
                                .deleteDownloadConfirmationInteracted(content: .section, isConfirmed: true)
                            )
                            strongSelf.removeCached(section: section)
                        }
                    )
                )
            case .notCached:
                if shouldConfirmUseOfCellularDataForDownloading {
                    self.presenter.presentDownloadOnCellularDataAlert(
                        response: .init(
                            useAlwaysActionHandler: { [weak self] in
                                guard let strongSelf = self else {
                                    return
                                }

                                strongSelf.useCellularDataForDownloadsStorageManager
                                    .shouldUseCellularDataForDownloads = true
                                self?.startDownloading(section: section)
                            },
                            justOnceActionHandler: { [weak self] in
                                self?.startDownloading(section: section)
                            }
                        )
                    )
                } else {
                    self.startDownloading(section: section)
                }
            case .downloading:
                self.cancelDownloading(section: section)
            default:
                break
            }
        }

        func handleAll() {
            let currentState = self.getDownloadingStateForCourse()
            switch currentState {
            case .cached:
                self.presenter.presentDeleteDownloadsConfirmationAlert(
                    response: .init(
                        type: .course,
                        cancelActionHandler: { [weak self] in
                            self?.analytics.send(
                                .deleteDownloadConfirmationInteracted(content: .course, isConfirmed: false)
                            )
                        },
                        confirmedActionHandler: { [weak self] in
                            guard let strongSelf = self else {
                                return
                            }

                            strongSelf.analytics.send(
                                .deleteDownloadConfirmationInteracted(content: .course, isConfirmed: true)
                            )
                            strongSelf.removeCachedCourse()
                        }
                    )
                )
            case .notCached:
                if shouldConfirmUseOfCellularDataForDownloading {
                    self.presenter.presentDownloadOnCellularDataAlert(
                        response: .init(
                            useAlwaysActionHandler: { [weak self] in
                                guard let strongSelf = self else {
                                    return
                                }

                                strongSelf.useCellularDataForDownloadsStorageManager
                                    .shouldUseCellularDataForDownloads = true
                                self?.startDownloadingCourse()
                            },
                            justOnceActionHandler: { [weak self] in
                                self?.startDownloadingCourse()
                            }
                        )
                    )
                } else {
                    self.startDownloadingCourse()
                }
            default:
                return print("course info tab syllabus interactor: did receive invalid state when handle download all")
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

    func doUnitSelection(request: CourseInfoTabSyllabus.UnitSelection.Request) {
        guard let unit = self.currentUnits[request.uniqueIdentifier] as? Unit else {
            return
        }
        self.requestUnitPresentation(unit)
    }

    func doPersonalDeadlinesAction(request: CourseInfoTabSyllabus.PersonalDeadlinesButtonAction.Request) {
        guard let course = self.currentCourse else {
            return
        }

        if self.personalDeadlinesService.hasDeadlines(in: course) {
            self.moduleOutput?.presentPersonalDeadlinesSettings(for: course)
        } else {
            self.analytics.send(.personalDeadlinesScheduleButtonTapped)
            self.moduleOutput?.presentPersonalDeadlinesCreation(for: course)
        }
    }

    // MARK: - Private API

    private func forceLoadAllSectionsIfNeeded() -> Promise<Void> {
        let allSections = Array(self.currentSections.values)
        let allUnits = allSections.flatMap { $0.unitsArray }
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

        let isEnrolledOnCourse = course.enrolled

        let isPersonalDeadlinesAvailable = self.personalDeadlinesService.canAddDeadlines(in: course)
            || self.personalDeadlinesService.hasDeadlines(in: course)
        let isPersonalDeadlinesEnabled = isPersonalDeadlinesAvailable && isEnrolledOnCourse

        let isPersonalDeadlinesTooltipVisible = !self.tooltipStorageManager.didShowOnPersonalDeadlinesButton
            && isPersonalDeadlinesEnabled

        let courseDownloadState = self.getDownloadingStateForCourse()

        let isDownloadAllAvailable: Bool = {
            switch courseDownloadState {
            case .cached, .notCached:
                return true
            default:
                return false
            }
        }() && !shouldForceDisableDownloadAll

        self.presenter.presentCourseSyllabusHeader(
            response: .init(
                isPersonalDeadlinesAvailable: isPersonalDeadlinesAvailable,
                isPersonalDeadlinesEnabled: isPersonalDeadlinesEnabled,
                isDownloadAllAvailable: isDownloadAllAvailable,
                isPersonalDeadlinesTooltipVisible: isPersonalDeadlinesTooltipVisible,
                courseDownloadState: courseDownloadState
            )
        )

        if isPersonalDeadlinesTooltipVisible {
            self.tooltipStorageManager.didShowOnPersonalDeadlinesButton = true
        }
    }

    private func fetchSyllabusSection(
        section: Section
    ) -> Promise<CourseInfoTabSyllabus.SyllabusLoad.Response> {
        Promise { seal in
            self.provider.fetchUnitsWithLessons(
                for: section,
                shouldUseNetwork: true
            ).done { units in
                self.mergeWithCurrentData(sections: [], units: units, dataSourceType: .remote)

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
    ) -> Promise<CourseInfoTabSyllabus.SyllabusLoad.Response> {
        Promise { seal in
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

                self.mergeWithCurrentData(sections: sections, units: units, dataSourceType: isOnline ? .remote : .cache)

                let data = self.makeSyllabusDataFromCurrentData()
                seal.fulfill(.init(result: .success(data)))
            }.catch { error in
                print("course info tab syllabus interactor: unable to fetch syllabus, error = \(error)")
                seal.reject(Error.fetchFailed)
            }
        }
    }

    private func mergeWithCurrentData(sections: [Section], units: [Unit], dataSourceType: DataSourceType) {
        for section in sections {
            self.currentSections[self.getUniqueIdentifierBySectionID(section.id)] = section
        }

        for unit in units {
            self.currentUnits[self.getUniqueIdentifierByUnitID(unit.id)] = unit
        }

        // Merge cache state with remote
        if dataSourceType == .remote && !sections.isEmpty {
            self.currentSections = self.currentSections.filter { _, section in
                sections.contains(where: { $0.id == section.id })
            }

            let allUnitsIDs = sections.flatMap { $0.unitsArray }
            self.currentUnits = self.currentUnits.filter { _, unit in
                if let unitID = unit?.id {
                    return allUnitsIDs.contains(unitID)
                }
                return false
            }
        }
    }

    private func makeSyllabusDataFromCurrentData() -> CourseInfoTabSyllabus.SyllabusData {
        CourseInfoTabSyllabus.SyllabusData(
            sections: self.currentSections
                .map { uid, entity in
                    .init(
                        uniqueIdentifier: uid,
                        entity: entity,
                        downloadState: self.getDownloadingStateForSection(entity)
                    )
                }
                .sorted(by: { $0.entity.position < $1.entity.position }),
            units: self.currentUnits
                .map { uid, entity in
                    .init(
                        uniqueIdentifier: uid,
                        entity: entity,
                        downloadState: entity != nil ? self.getDownloadingStateForUnit(entity.require()) : .notAvailable
                    )
                }
                .sorted(by: { ($0.entity?.position ?? 0) < ($1.entity?.position ?? 0) }),
            sectionsDeadlines: self.currentCourse?.sectionDeadlines ?? [],
            course: self.currentCourse.require()
        )
    }

    private func getUniqueIdentifierBySectionID(_ sectionID: Section.IdType) -> UniqueIdentifierType { "\(sectionID)" }

    private func getUniqueIdentifierByUnitID(_ unitID: Unit.IdType) -> UniqueIdentifierType { "\(unitID)" }

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

// MARK: - CourseInfoTabSyllabusInteractor: CourseInfoTabSyllabusInputProtocol -

extension CourseInfoTabSyllabusInteractor: CourseInfoTabSyllabusInputProtocol {
    func handleControllerAppearance() {
        if let course = self.currentCourse {
            self.analytics.send(.sectionsScreenOpened(courseID: course.id, courseTitle: course.title))
            self.shouldOpenedAnalyticsEventSend = false
        } else {
            self.shouldOpenedAnalyticsEventSend = true
        }
    }

    func update(with course: Course, viewSource: AnalyticsEvent.CourseViewSource, isOnline: Bool) {
        print("course info tab syllabus interactor: updated from parent module, isOnline = \(isOnline)")

        self.currentCourse = course
        self.isOnline = isOnline
        self.doSectionsFetch(request: .init())

        if self.shouldOpenedAnalyticsEventSend {
            self.analytics.send(.sectionsScreenOpened(courseID: course.id, courseTitle: course.title))
            self.shouldOpenedAnalyticsEventSend = false
        }
    }
}

// MARK: - CourseInfoTabSyllabusInteractor: SectionNavigationDelegate -

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

// MARK: - CourseInfoTabSyllabusInteractor: SyllabusDownloadsServiceDelegate -

extension CourseInfoTabSyllabusInteractor: SyllabusDownloadsServiceDelegate {
    func syllabusDownloadsService(
        _ service: SyllabusDownloadsServiceProtocol,
        didReceiveProgress progress: Float,
        forVideoWithID videoID: Video.IdType
    ) {
        if !self.reportedToAnalyticsVideoDownloadIDs.contains(videoID) {
            self.reportedToAnalyticsVideoDownloadIDs.insert(videoID)
            self.analytics.send(.videoDownloadStarted)
        }
    }

    func syllabusDownloadsService(
        _ service: SyllabusDownloadsServiceProtocol,
        didReceiveProgress progress: Float,
        forUnitWithID unitID: Unit.IdType
    ) {
        guard let unit = self.currentUnits[self.getUniqueIdentifierByUnitID(unitID)] as? Unit else {
            return
        }

        self.presenter.presentDownloadButtonUpdate(
            response: .init(
                source: .unit(entity: unit),
                downloadState: .downloading(progress: progress)
            )
        )
    }

    func syllabusDownloadsService(
        _ service: SyllabusDownloadsServiceProtocol,
        didReceiveProgress progress: Float,
        forSectionWithID sectionID: Section.IdType
    ) {
        guard let section = self.currentSections[self.getUniqueIdentifierBySectionID(sectionID)] else {
            return
        }

        self.presenter.presentDownloadButtonUpdate(
            response: .init(
                source: .section(entity: section),
                downloadState: .downloading(progress: progress)
            )
        )
    }

    func syllabusDownloadsService(
        _ service: SyllabusDownloadsServiceProtocol,
        didReceiveCompletion isCompleted: Bool,
        forVideoWithID videoID: Video.IdType
    ) {
        self.reportedToAnalyticsVideoDownloadIDs.remove(videoID)
        self.analytics.send(isCompleted ? .videoDownloadSucceeded : .videoDownloadFailed)
    }

    func syllabusDownloadsService(
        _ service: SyllabusDownloadsServiceProtocol,
        didReceiveCompletion isCompleted: Bool,
        forUnitWithID unitID: Unit.IdType
    ) {
        guard let unit = self.currentUnits[self.getUniqueIdentifierByUnitID(unitID)] as? Unit else {
            return
        }

        self.updateUnitDownloadState(unit, forceSectionUpdate: true)
        self.updateSyllabusHeader()
    }

    func syllabusDownloadsService(
        _ service: SyllabusDownloadsServiceProtocol,
        didReceiveCompletion isCompleted: Bool,
        forSectionWithID sectionID: Section.IdType
    ) {
        guard let section = self.currentSections[self.getUniqueIdentifierBySectionID(sectionID)] else {
            return
        }

        self.updateSectionDownloadState(section)
        self.updateSyllabusHeader()
    }

    func syllabusDownloadsService(
        _ service: SyllabusDownloadsServiceProtocol,
        didFailLoadVideoWithError error: Swift.Error
    ) {
        func report(_ error: Swift.Error, reason: AnalyticsEvent.VideoDownloadFailReason) {
            let nsError = error as NSError
            self.analytics.send(
                .videoDownloadFailed(
                    description: nsError.localizedDescription,
                    name: String(describing: error),
                    code: nsError.code,
                    domain: nsError.domain,
                    reason: reason
                )
            )
        }

        if case VideoDownloadingService.Error.videoDownloadingStopped = error {
            report(error, reason: .cancelled)
        } else if case DownloaderError.clientSide(let nsError) = error {
            // No space left on device
            if nsError.domain == NSPOSIXErrorDomain && nsError.code == ENOSPC {
                report(nsError, reason: .noSpaceLeftOnDevice)
                self.presenter.presentFailedDownloadAlert(
                    response: .init(error: nsError, reason: .noSpaceLeftOnDevice, forcePresentation: true)
                )
            } else {
                self.presenter.presentFailedDownloadAlert(response: .init(error: error))
            }
        } else {
            let nsError = error as NSError
            if nsError.domain == NSPOSIXErrorDomain && nsError.code == 100 {
                report(error, reason: .protocolError)
            } else if !self.isOnline {
                report(error, reason: .offline)
            } else {
                report(error, reason: .other)
            }

            self.presenter.presentFailedDownloadAlert(response: .init(error: error))
        }
    }

    func syllabusDownloadsService(
        _ service: SyllabusDownloadsServiceProtocol,
        didFailLoadImageWithError error: Swift.Error,
        forUnitWithID unitID: Unit.IdType?
    ) {
        defer {
            self.presenter.presentFailedDownloadAlert(response: .init(error: error))
        }

        guard let unitID = unitID,
              let unit = self.currentUnits[self.getUniqueIdentifierByUnitID(unitID)] as? Unit else {
            return
        }

        self.updateUnitDownloadState(unit, forceSectionUpdate: true)
    }
}

// MARK: - Video managing & downloading -

extension CourseInfoTabSyllabusInteractor {
    private func startDownloading(unit: Unit) {
        self.analytics.send(.downloadStarted(content: .lesson))

        let unitID = unit.id
        print("course info tab syllabus interactor: start downloading unit = \(unitID)")

        self.presenter.presentDownloadButtonUpdate(
            response: .init(
                source: .unit(entity: unit),
                downloadState: .waiting
            )
        )

        self.syllabusDownloadsService.download(unit: unit).done {
            print("course info tab syllabus interactor: started downloading unit = \(unitID)")
        }.catch { error in
            print("course info tab syllabus interactor: error while starting download unit = \(unitID), error = \(error)")

            self.updateUnitDownloadState(unit, forceSectionUpdate: true)
            self.updateSyllabusHeader()

            self.presenter.presentFailedDownloadAlert(response: .init(error: error))
        }
    }

    private func startDownloading(section: Section) {
        self.analytics.send(.downloadStarted(content: .section))

        let sectionID = section.id
        print("course info tab syllabus interactor: start downloading section = \(sectionID)")

        self.presenter.presentDownloadButtonUpdate(
            response: .init(
                source: .section(entity: section),
                downloadState: .waiting
            )
        )

        // Present waiting state for units if not cached
        section.units.forEach { unit in
            if case .notCached = self.getDownloadingStateForUnit(unit) {
                self.presenter.presentDownloadButtonUpdate(
                    response: .init(
                        source: .unit(entity: unit),
                        downloadState: .waiting
                    )
                )
            }
        }

        self.syllabusDownloadsService.download(section: section).done {
            print("course info tab syllabus interactor: started downloading section = \(sectionID)")
        }.catch { error in
            print("course info tab syllabus interactor: error while starting download section = \(sectionID), error = \(error)")

            self.updateSectionDownloadState(section)
            self.updateSyllabusHeader()

            self.presenter.presentFailedDownloadAlert(response: .init(error: error))
        }
    }

    private func startDownloadingCourse() {
        self.analytics.send(.downloadStarted(content: .course))
        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        self.shouldCheckUseOfCellularDataForDownloads = false

        self.forceLoadAllSectionsIfNeeded().done {
            for (uid, section) in self.currentSections {
                let sectionState = self.getDownloadingStateForSection(section)
                if case .notCached = sectionState {
                    self.doDownloadButtonAction(request: .init(type: .section(uniqueIdentifier: uid)))
                }
            }
            self.updateSyllabusHeader(shouldForceDisableDownloadAll: true)
        }.ensure {
            self.shouldCheckUseOfCellularDataForDownloads = true
            self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
        }.catch { error in
            self.presenter.presentFailedDownloadAlert(response: .init(error: error))
        }
    }

    private func cancelDownloading(unit: Unit) {
        self.analytics.send(.downloadCancelled(content: .lesson))

        let unitID = unit.id
        print("course info tab syllabus interactor: start cancelling unit = \(unitID)")

        self.syllabusDownloadsService.cancel(unit: unit).done {
            print("course info tab syllabus interactor: finish cancelling unit = \(unitID)")
        }.ensure {
            self.updateUnitDownloadState(unit, forceSectionUpdate: true)
            self.updateSyllabusHeader()
        }.catch { error in
            print("course info tab syllabus interactor: error while cancelling unit = \(unitID), error = \(error)")
        }
    }

    private func cancelDownloading(section: Section) {
        self.analytics.send(.downloadCancelled(content: .section))

        let sectionID = section.id
        print("course info tab syllabus interactor: start cancelling section = \(sectionID)")

        self.syllabusDownloadsService.cancel(section: section).done {
            print("course info tab syllabus interactor: finish cancelling section = \(sectionID)")
        }.ensure {
            // FIXME: Better handle this case, w/o delay section downloading tasks may not be cancelled
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.updateSectionDownloadState(section)
                self.updateSyllabusHeader()
            }
        }.catch { error in
            print("course info tab syllabus interactor: error while cancelling section = \(sectionID), error = \(error)")
        }
    }

    private func removeCached(unit: Unit) {
        self.analytics.send(.downloadDeleted(content: .lesson, source: .syllabus))

        let unitID = unit.id
        print("course info tab syllabus interactor: start removing cached unit = \(unitID)")

        self.syllabusDownloadsService.remove(unit: unit).done {
            print("course info tab syllabus interactor: finish removing cached unit = \(unitID)")
        }.ensure {
            self.updateUnitDownloadState(unit, forceSectionUpdate: true)
            self.updateSyllabusHeader()
        }.catch { error in
            print("course info tab syllabus interactor: error while removing cached unit = \(unitID), error = \(error)")
        }
    }

    private func removeCached(section: Section) {
        self.analytics.send(.downloadDeleted(content: .section, source: .syllabus))

        let sectionID = section.id
        print("course info tab syllabus interactor: start removing cached section = \(sectionID)")

        self.syllabusDownloadsService.remove(section: section).done {
            print("course info tab syllabus interactor: finish removing cached section = \(sectionID)")
        }.ensure {
            self.updateSectionDownloadState(section)
            self.updateSyllabusHeader()
        }.catch { error in
            print("course info tab syllabus interactor: error while removing cached section = \(sectionID), error = \(error)")
        }
    }

    private func removeCachedCourse() {
        guard let course = self.currentCourse else {
            return
        }

        self.analytics.send(.downloadDeleted(content: .course, source: .syllabus))

        let courseID = course.id
        print("course info tab syllabus interactor: start removing cached course = \(courseID)")

        self.syllabusDownloadsService.remove(course: course).done {
            print("course info tab syllabus interactor: finish removing cached course = \(courseID)")
        }.ensure {
            self.updateSyllabusHeader()
            course.sections.forEach { self.updateSectionDownloadState($0) }
        }.catch { error in
            print("course info tab syllabus interactor: error while removing cached course = \(courseID), error = \(error)")
        }
    }

    private func updateUnitDownloadState(_ unit: Unit, forceSectionUpdate: Bool) {
        self.presenter.presentDownloadButtonUpdate(
            response: .init(
                source: .unit(entity: unit),
                downloadState: self.getDownloadingStateForUnit(unit)
            )
        )

        if forceSectionUpdate {
            guard let section = self.currentSections.first(where: { $1.unitsArray.contains(unit.id) })?.value else {
                return
            }

            self.presenter.presentDownloadButtonUpdate(
                response: .init(
                    source: .section(entity: section),
                    downloadState: self.getDownloadingStateForSection(section)
                )
            )
        }
    }

    private func updateSectionDownloadState(_ section: Section) {
        section.units.forEach { self.updateUnitDownloadState($0, forceSectionUpdate: false) }

        self.presenter.presentDownloadButtonUpdate(
            response: .init(
                source: .section(entity: section),
                downloadState: self.getDownloadingStateForSection(section)
            )
        )
    }

    private func getDownloadingStateForUnit(_ unit: Unit) -> CourseInfoTabSyllabus.DownloadState {
        if let section = self.currentSections[self.getUniqueIdentifierBySectionID(unit.sectionId)] {
            return self.syllabusDownloadsService.getUnitDownloadState(unit, in: section)
        }
        return .notAvailable
    }

    private func getDownloadingStateForSection(_ section: Section) -> CourseInfoTabSyllabus.DownloadState {
        self.syllabusDownloadsService.getSectionDownloadState(section)
    }

    private func getDownloadingStateForCourse() -> CourseInfoTabSyllabus.DownloadState {
        if let course = self.currentCourse {
            return self.syllabusDownloadsService.getCourseDownloadState(course)
        }
        return .notAvailable
    }
}
