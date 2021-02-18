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
    private static let maxConcurrentOperations = 3

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
    private var didLoadFromCache = false
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
    private lazy var downloadUpdatesQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.CourseInfoTabSyllabusInteractor.DownloadUpdate"
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

            let shouldUseNetwork = strongSelf.isOnline && strongSelf.didLoadFromCache
            print("CourseInfoTabSyllabusInteractor :: start fetching syllabus, isOnline = \(shouldUseNetwork)")

            strongSelf.fetchSyllabusInAppropriateMode(course: course, isOnline: shouldUseNetwork).done { response in
                DispatchQueue.main.async {
                    print("CourseInfoTabSyllabusInteractor :: finish fetching syllabus, isOnline = \(shouldUseNetwork)")
                    strongSelf.presenter.presentCourseSyllabus(response: response)

                    if !strongSelf.didLoadFromCache {
                        strongSelf.didLoadFromCache = true
                    }

                    if shouldUseNetwork && !strongSelf.didLoadFromNetwork {
                        strongSelf.didLoadFromNetwork = true
                        strongSelf.updateSyllabusHeader()
                        strongSelf.sectionFetchSemaphore.signal()
                    }
                }
            }.catch { error in
                // TODO: handle error
                print("CourseInfoTabSyllabusInteractor :: error while fetching syllabus, isOnline = \(shouldUseNetwork), error = \(error)")
            }.finally {
                strongSelf.fetchSemaphore.signal()
            }
        }
    }

    func doSectionFetch(request: CourseInfoTabSyllabus.SyllabusSectionLoad.Request) {
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

            print("CourseInfoTabSyllabusInteractor :: start fetching section from network, id = \(section.id)")

            strongSelf.fetchSyllabusSection(section: section).done { response in
                DispatchQueue.main.async {
                    print("CourseInfoTabSyllabusInteractor :: finish fetching section from network, id = \(section.id)")

                    strongSelf.presenter.presentCourseSyllabus(response: response)
                    strongSelf.updateSyllabusHeader()
                }
            }.catch { error in
                print("CourseInfoTabSyllabusInteractor :: error while fetching section from network, error = \(error)")
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
                return print("CourseInfoTabSyllabusInteractor :: unit doesn't exists in current units, id = \(id)")
            }

            self.getDownloadingStateForUnit(unit).done { currentState in
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
        }

        func handleSection(id: UniqueIdentifierType) {
            guard let section = self.currentSections[id] else {
                return print("CourseInfoTabSyllabusInteractor :: section doesn't exists in current sections, id = \(id)")
            }

            self.getDownloadingStateForSection(section).done { currentState in
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
        }

        func handleAll() {
            self.getDownloadingStateForCourse().done { currentState in
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
                    print("CourseInfoTabSyllabusInteractor :: did receive invalid state when handle download all")
                }
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
                var iterator = self.currentSections.values.makeIterator()

                let generator = AnyIterator<Promise<CourseInfoTabSyllabus.SyllabusLoad.Response>> {
                    guard let section = iterator.next() else {
                        return nil
                    }

                    return self.fetchSyllabusSection(section: section)
                }

                // Load all units in each section
                when(fulfilled: generator, concurrently: Self.maxConcurrentOperations).done { _ in
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

        let plainCourse = CoursePlainObject(course: course)

        let isPersonalDeadlinesAvailable = self.personalDeadlinesService.canAddDeadlines(in: course)
            || self.personalDeadlinesService.hasDeadlines(in: course)

        self.downloadUpdatesQueue.async {
            let isPersonalDeadlinesEnabled = isPersonalDeadlinesAvailable && plainCourse.isEnrolled

            let isPersonalDeadlinesTooltipVisible = !self.tooltipStorageManager.didShowOnPersonalDeadlinesButton
                && isPersonalDeadlinesEnabled

            self.getDownloadingStateForCourse(plainCourse).done { courseDownloadState in
                let isDownloadAllAvailable: Bool = {
                    switch courseDownloadState {
                    case .cached, .notCached:
                        return true
                    default:
                        return false
                    }
                }() && !shouldForceDisableDownloadAll

                DispatchQueue.main.async {
                    self.presenter.presentCourseSyllabusHeader(
                        response: .init(
                            isPersonalDeadlinesAvailable: isPersonalDeadlinesAvailable,
                            isPersonalDeadlinesEnabled: isPersonalDeadlinesEnabled,
                            isDownloadAllAvailable: isDownloadAllAvailable,
                            isPersonalDeadlinesTooltipVisible: isPersonalDeadlinesTooltipVisible,
                            courseDownloadState: courseDownloadState
                        )
                    )
                }

                if isPersonalDeadlinesTooltipVisible {
                    self.tooltipStorageManager.didShowOnPersonalDeadlinesButton = true
                }
            }
        }
    }

    private func fetchSyllabusSection(
        section: Section
    ) -> Promise<CourseInfoTabSyllabus.SyllabusLoad.Response> {
        Promise { seal in
            self.provider.fetchUnitsWithLessons(
                for: section,
                shouldUseNetwork: true
            ).then { units -> Guarantee<CourseInfoTabSyllabus.SyllabusData> in
                self.mergeWithCurrentData(sections: [], units: units, dataSourceType: .remote)
                return self.makeSyllabusDataFromCurrentData()
            }.done { data in
                seal.fulfill(.init(result: .success(data)))
            }.catch { error in
                print("CourseInfoTabSyllabusInteractor :: unable to fetch section, error = \(error)")
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
            self.provider.fetchSections(
                for: course,
                shouldUseNetwork: isOnline
            ).then { sections -> Promise<([Section], [[Unit]])> in
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
            }.then { result -> Guarantee<CourseInfoTabSyllabus.SyllabusData> in
                let sections = result.0
                let units = Array(result.1.joined())

                self.mergeWithCurrentData(sections: sections, units: units, dataSourceType: isOnline ? .remote : .cache)

                return self.makeSyllabusDataFromCurrentData()
            }.done { data in
                seal.fulfill(.init(result: .success(data)))
            }.catch { error in
                print("CourseInfoTabSyllabusInteractor :: unable to fetch syllabus, error = \(error)")
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

    private func makeSyllabusDataFromCurrentData() -> Guarantee<CourseInfoTabSyllabus.SyllabusData> {
        let plainSections = self.currentSections.mapValues(SectionPlainObject.init)
        let plainUnits = self.currentUnits.mapValues { unitOrNil -> UnitPlainObject? in
            if let unit = unitOrNil {
                return UnitPlainObject(unit: unit)
            }
            return nil
        }
        let plainCourse = CoursePlainObject(course: self.currentCourse.require())

        return Guarantee { seal in
            self.downloadUpdatesQueue.async {
                let sectionsArray = Array(plainSections.values)
                let sectionsIDs: [UniqueIdentifierType] = Array(plainSections.keys)

                let unitsArray = Array(plainUnits.values)
                let unitsIDs: [UniqueIdentifierType] = Array(plainUnits.keys)

                firstly {
                    self.getDownloadingStatesForSections(sectionsArray)
                        .map { zip(sectionsIDs, $0) }
                }.then { sectionsResult in
                    self.getDownloadingStatesForUnits(unitsArray, in: sectionsArray)
                        .map { (sectionsResult, zip(unitsIDs, $0)) }
                }.map { sectionsResult, unitsResult in
                    (Dictionary(uniqueKeysWithValues: sectionsResult), Dictionary(uniqueKeysWithValues: unitsResult))
                }.done { sectionsDownloadStates, unitsDownloadStates in
                    let data = CourseInfoTabSyllabus.SyllabusData(
                        sections: plainSections
                            .map { uid, entity in
                                .init(
                                    uniqueIdentifier: uid,
                                    entity: entity,
                                    downloadState: sectionsDownloadStates[uid] ?? .notAvailable
                                )
                            }
                            .sorted(by: { $0.entity.position < $1.entity.position }),
                        units: plainUnits
                            .map { uid, entity in
                                .init(
                                    uniqueIdentifier: uid,
                                    entity: entity,
                                    downloadState: unitsDownloadStates[uid] ?? .notAvailable
                                )
                            }
                            .sorted(by: { ($0.entity?.position ?? 0) < ($1.entity?.position ?? 0) }),
                        sectionsDeadlines: self.currentCourse?.sectionDeadlines ?? [],
                        course: plainCourse
                    )

                    DispatchQueue.main.async {
                        seal(data)
                    }
                }
            }
        }
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
        print("CourseInfoTabSyllabusInteractor :: updated from parent module, isOnline = \(isOnline)")

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

        self.downloadUpdatesQueue.async {
            let plainUnit = UnitPlainObject(unit: unit)

            DispatchQueue.main.async {
                self.presenter.presentDownloadButtonUpdate(
                    response: .init(
                        source: .unit(entity: plainUnit),
                        downloadState: .downloading(progress: progress)
                    )
                )
            }
        }
    }

    func syllabusDownloadsService(
        _ service: SyllabusDownloadsServiceProtocol,
        didReceiveProgress progress: Float,
        forSectionWithID sectionID: Section.IdType
    ) {
        guard let section = self.currentSections[self.getUniqueIdentifierBySectionID(sectionID)] else {
            return
        }

        self.downloadUpdatesQueue.async {
            let plainSection = SectionPlainObject(section: section)

            DispatchQueue.main.async {
                self.presenter.presentDownloadButtonUpdate(
                    response: .init(
                        source: .section(entity: plainSection),
                        downloadState: .downloading(progress: progress)
                    )
                )
            }
        }
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
        print("CourseInfoTabSyllabusInteractor :: start downloading unit = \(unitID)")

        self.presenter.presentDownloadButtonUpdate(
            response: .init(
                source: .unit(entity: .init(unit: unit)),
                downloadState: .waiting
            )
        )

        self.syllabusDownloadsService.download(unit: unit).done {
            print("CourseInfoTabSyllabusInteractor :: started downloading unit = \(unitID)")
        }.catch { error in
            print("CourseInfoTabSyllabusInteractor :: error while starting download unit = \(unitID), error = \(error)")

            self.updateUnitDownloadState(unit, forceSectionUpdate: true)
            self.updateSyllabusHeader()

            self.presenter.presentFailedDownloadAlert(response: .init(error: error))
        }
    }

    private func startDownloading(section: Section) {
        self.analytics.send(.downloadStarted(content: .section))

        let plainSection = SectionPlainObject(section: section)
        let sectionID = plainSection.id
        print("CourseInfoTabSyllabusInteractor :: start downloading section = \(sectionID)")

        self.presenter.presentDownloadButtonUpdate(
            response: .init(
                source: .section(entity: plainSection),
                downloadState: .waiting
            )
        )

        self.downloadUpdatesQueue.promise {
            self.getDownloadingStatesForUnits(plainSection.units, in: [plainSection])
        }.then(on: self.downloadUpdatesQueue) { unitsDownloadStates -> Promise<Void> in
            // Present waiting state for units if not cached
            for (unit, downloadState) in zip(plainSection.units, unitsDownloadStates) {
                if case .notCached = downloadState {
                    DispatchQueue.main.async {
                        self.presenter.presentDownloadButtonUpdate(
                            response: .init(
                                source: .unit(entity: unit),
                                downloadState: .waiting
                            )
                        )
                    }
                }
            }

            return .value(())
        }.then { () -> Promise<Void> in
            self.syllabusDownloadsService.download(section: section)
        }.done {
            print("CourseInfoTabSyllabusInteractor :: started downloading section = \(sectionID)")
        }.catch { error in
            print("CourseInfoTabSyllabusInteractor :: error while starting download section = \(sectionID), error = \(error)")

            self.updateSectionDownloadState(section)
            self.updateSyllabusHeader()

            self.presenter.presentFailedDownloadAlert(response: .init(error: error))
        }
    }

    private func startDownloadingCourse() {
        self.analytics.send(.downloadStarted(content: .course))
        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        self.shouldCheckUseOfCellularDataForDownloads = false

        let plainSections = self.currentSections.values.map(SectionPlainObject.init)

        firstly {
            after(seconds: 1)
        }.then {
            self.forceLoadAllSectionsIfNeeded()
        }.then(on: self.downloadUpdatesQueue) {
            self.getDownloadingStatesForSections(plainSections)
        }.done(on: self.downloadUpdatesQueue) { sectionsDownloadStates in
            zip(plainSections, sectionsDownloadStates).forEach { section, downloadState in
                if case .notCached = downloadState {
                    let uid = self.getUniqueIdentifierBySectionID(section.id)

                    DispatchQueue.main.async {
                        self.doDownloadButtonAction(request: .init(type: .section(uniqueIdentifier: uid)))
                    }
                }
            }

            DispatchQueue.main.async {
                self.updateSyllabusHeader(shouldForceDisableDownloadAll: true)
            }
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
        print("CourseInfoTabSyllabusInteractor :: start cancelling unit = \(unitID)")

        self.syllabusDownloadsService.cancel(unit: unit).done {
            print("CourseInfoTabSyllabusInteractor :: finish cancelling unit = \(unitID)")
        }.ensure {
            self.updateUnitDownloadState(unit, forceSectionUpdate: true)
            self.updateSyllabusHeader()
        }.catch { error in
            print("CourseInfoTabSyllabusInteractor :: error while cancelling unit = \(unitID), error = \(error)")
        }
    }

    private func cancelDownloading(section: Section) {
        self.analytics.send(.downloadCancelled(content: .section))

        let sectionID = section.id
        print("CourseInfoTabSyllabusInteractor :: start cancelling section = \(sectionID)")

        self.syllabusDownloadsService.cancel(section: section).done {
            print("CourseInfoTabSyllabusInteractor :: finish cancelling section = \(sectionID)")
        }.ensure {
            // FIXME: Better handle this case, w/o delay section downloading tasks may not be cancelled
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                self.updateSectionDownloadState(section)
                self.updateSyllabusHeader()
            }
        }.catch { error in
            print("CourseInfoTabSyllabusInteractor :: error while cancelling section = \(sectionID), error = \(error)")
        }
    }

    private func removeCached(unit: Unit) {
        self.analytics.send(.downloadDeleted(content: .lesson, source: .syllabus))

        let unitID = unit.id
        print("CourseInfoTabSyllabusInteractor :: start removing cached unit = \(unitID)")

        self.syllabusDownloadsService.remove(unit: unit).done {
            print("CourseInfoTabSyllabusInteractor :: finish removing cached unit = \(unitID)")
        }.ensure {
            self.updateUnitDownloadState(unit, forceSectionUpdate: true)
            self.updateSyllabusHeader()
        }.catch { error in
            print("CourseInfoTabSyllabusInteractor :: error while removing cached unit = \(unitID), error = \(error)")
        }
    }

    private func removeCached(section: Section) {
        self.analytics.send(.downloadDeleted(content: .section, source: .syllabus))

        let sectionID = section.id
        print("CourseInfoTabSyllabusInteractor :: start removing cached section = \(sectionID)")

        self.syllabusDownloadsService.remove(section: section).done {
            print("CourseInfoTabSyllabusInteractor :: finish removing cached section = \(sectionID)")
        }.ensure {
            self.updateSectionDownloadState(section)
            self.updateSyllabusHeader()
        }.catch { error in
            print("CourseInfoTabSyllabusInteractor :: error while removing cached section = \(sectionID), error = \(error)")
        }
    }

    private func removeCachedCourse() {
        guard let course = self.currentCourse else {
            return
        }

        self.analytics.send(.downloadDeleted(content: .course, source: .syllabus))

        let courseID = course.id
        print("CourseInfoTabSyllabusInteractor :: start removing cached course = \(courseID)")

        self.syllabusDownloadsService.remove(course: course).done {
            print("CourseInfoTabSyllabusInteractor :: finish removing cached course = \(courseID)")
        }.ensure {
            self.updateSyllabusHeader()
            course.sections.forEach { self.updateSectionDownloadState($0) }
        }.catch { error in
            print("CourseInfoTabSyllabusInteractor :: error while removing cached course = \(courseID), error = \(error)")
        }
    }

    private func updateUnitDownloadState(_ unit: Unit, forceSectionUpdate: Bool) {
        self.updateUnitDownloadState(
            UnitPlainObject(unit: unit),
            in: unit.section.flatMap(SectionPlainObject.init),
            forceSectionUpdate: forceSectionUpdate
        )
    }

    private func updateUnitDownloadState(
        _ unit: UnitPlainObject,
        in section: SectionPlainObject?,
        forceSectionUpdate: Bool
    ) {
        let section: SectionPlainObject? = {
            if let section = section {
                return section
            }

            return self.currentSections
                .first(where: { $1.unitsArray.contains(unit.id) })
                .flatMap { SectionPlainObject(section: $1) }
        }()

        guard let targetSection = section else {
            return
        }

        self.downloadUpdatesQueue.async {
            self.getDownloadingStateForUnit(unit, in: targetSection).done(on: .main) { downloadState in
                self.presenter.presentDownloadButtonUpdate(
                    response: .init(
                        source: .unit(entity: unit),
                        downloadState: downloadState
                    )
                )
            }

            if forceSectionUpdate {
                self.getDownloadingStateForSection(targetSection).done(on: .main) { downloadState in
                    self.presenter.presentDownloadButtonUpdate(
                        response: .init(
                            source: .section(entity: targetSection),
                            downloadState: downloadState
                        )
                    )
                }
            }
        }
    }

    private func updateSectionDownloadState(_ section: Section) {
        let plainSection = SectionPlainObject(section: section)

        self.downloadUpdatesQueue.async {
            plainSection.units.forEach {
                self.updateUnitDownloadState($0, in: plainSection, forceSectionUpdate: false)
            }

            self.getDownloadingStateForSection(plainSection).done(on: .main) { downloadState in
                self.presenter.presentDownloadButtonUpdate(
                    response: .init(
                        source: .section(entity: plainSection),
                        downloadState: downloadState
                    )
                )
            }
        }
    }

    private func getDownloadingStateForUnit(_ unit: Unit) -> Guarantee<CourseInfoTabSyllabus.DownloadState> {
        if let section = self.currentSections[self.getUniqueIdentifierBySectionID(unit.sectionId)] {
            return self.syllabusDownloadsService.getUnitDownloadState(unit, in: section)
        }
        return .value(.notAvailable)
    }

    private func getDownloadingStateForUnit(
        _ unit: UnitPlainObject,
        in section: SectionPlainObject
    ) -> Guarantee<CourseInfoTabSyllabus.DownloadState> {
        self.syllabusDownloadsService.getUnitDownloadState(unit, in: section)
    }

    private func getDownloadingStatesForUnits(
        _ units: [UnitPlainObject?],
        in sections: [SectionPlainObject]
    ) -> Guarantee<[CourseInfoTabSyllabus.DownloadState]> {
        Guarantee { seal in
            var unitsIterator = units.makeIterator()

            let generator = AnyIterator<Guarantee<CourseInfoTabSyllabus.DownloadState>> {
                guard let unitOrNil = unitsIterator.next() else {
                    return nil
                }

                guard let unit = unitOrNil,
                      let section = sections.first(where: { $0.id == unit.sectionID }) else {
                    return .value(.notAvailable)
                }

                return self.syllabusDownloadsService.getUnitDownloadState(unit, in: section)
            }

            when(fulfilled: generator, concurrently: Self.maxConcurrentOperations).done { downloadStates in
                seal(downloadStates)
            }.catch { _ in
                seal([])
            }
        }
    }

    private func getDownloadingStateForSection(_ section: Section) -> Guarantee<CourseInfoTabSyllabus.DownloadState> {
        self.syllabusDownloadsService.getSectionDownloadState(section)
    }

    private func getDownloadingStateForSection(
        _ section: SectionPlainObject
    ) -> Guarantee<CourseInfoTabSyllabus.DownloadState> {
        self.syllabusDownloadsService.getSectionDownloadState(section)
    }

    private func getDownloadingStatesForSections(
        _ sections: [SectionPlainObject]
    ) -> Guarantee<[CourseInfoTabSyllabus.DownloadState]> {
        Guarantee { seal in
            var sectionsIterator = sections.makeIterator()

            let generator = AnyIterator<Guarantee<CourseInfoTabSyllabus.DownloadState>> {
                guard let section = sectionsIterator.next() else {
                    return nil
                }

                return self.syllabusDownloadsService.getSectionDownloadState(section)
            }

            when(fulfilled: generator, concurrently: Self.maxConcurrentOperations).done { downloadStates in
                seal(downloadStates)
            }.catch { _ in
                seal([])
            }
        }
    }

    private func getDownloadingStateForCourse(
        _ course: Course? = nil
    ) -> Guarantee<CourseInfoTabSyllabus.DownloadState> {
        if let course = self.currentCourse {
            return self.syllabusDownloadsService.getCourseDownloadState(course)
        }
        return .value(.notAvailable)
    }

    private func getDownloadingStateForCourse(
        _ course: CoursePlainObject
    ) -> Guarantee<CourseInfoTabSyllabus.DownloadState> {
        self.syllabusDownloadsService.getCourseDownloadState(course)
    }
}
