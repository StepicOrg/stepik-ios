import Foundation
import PromiseKit

// swiftlint:disable file_length
protocol LessonInteractorProtocol {
    func doLessonLoad(request: LessonDataFlow.LessonLoad.Request)
    func doEditStepPresentation(request: LessonDataFlow.EditStepPresentation.Request)
    func doSubmissionsPresentation(request: LessonDataFlow.SubmissionsPresentation.Request)
    func doBuyCourse(request: LessonDataFlow.BuyCourseAction.Request)
    func doLeaveReviewPresentation(request: LessonDataFlow.LeaveReviewPresentation.Request)
    func doCatalogPresentation(request: LessonDataFlow.CatalogPresentation.Request)
    func doLessonFinishedDemoModuleAddedCourseToWishlist(
        request: LessonDataFlow.LessonFinishedDemoModuleAddedCourseToWishlist.Request
    )
}

final class LessonInteractor: LessonInteractorProtocol {
    weak var moduleOutput: LessonOutputProtocol?

    private let presenter: LessonPresenterProtocol
    private let provider: LessonProviderProtocol
    private let unitNavigationService: UnitNavigationServiceProtocol
    private let persistenceQueuesService: PersistenceQueuesServiceProtocol
    private let dataBackUpdateService: DataBackUpdateServiceProtocol

    private var currentLesson: Lesson?
    private var currentData: LessonDataFlow.LessonLoad.Data?

    private var previousUnit: Unit?
    private var currentUnit: Unit? {
        didSet {
            self.refreshAdjacentUnits()
        }
    }
    private var nextUnit: Unit?
    private var assignmentsForCurrentSteps: [Step.IdType: Assignment.IdType] = [:]

    private var lastLoadState: (context: LessonDataFlow.Context, startStep: LessonDataFlow.StartStep?)

    private let promoCodeName: String?

    private var didLoadFromCache = false

    init(
        initialContext: LessonDataFlow.Context,
        startStep: LessonDataFlow.StartStep?,
        promoCodeName: String?,
        presenter: LessonPresenterProtocol,
        provider: LessonProviderProtocol,
        unitNavigationService: UnitNavigationServiceProtocol,
        persistenceQueuesService: PersistenceQueuesServiceProtocol,
        dataBackUpdateService: DataBackUpdateServiceProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
        self.unitNavigationService = unitNavigationService
        self.persistenceQueuesService = persistenceQueuesService
        self.dataBackUpdateService = dataBackUpdateService
        self.lastLoadState = (initialContext, startStep)
        self.promoCodeName = promoCodeName
    }

    // MARK: Public API

    func doLessonLoad(request: LessonDataFlow.LessonLoad.Request) {
        self.refreshLesson(
            context: self.lastLoadState.context,
            startStep: self.lastLoadState.startStep
        ).cauterize()
    }

    func doEditStepPresentation(request: LessonDataFlow.EditStepPresentation.Request) {
        guard let lesson = self.currentLesson,
              let stepID = lesson.stepsArray[safe: request.index] else {
            return
        }

        self.presenter.presentEditStep(response: .init(stepID: stepID))
    }

    func doSubmissionsPresentation(request: LessonDataFlow.SubmissionsPresentation.Request) {
        guard let lesson = self.currentLesson,
              let stepID = lesson.stepsArray[safe: request.index] else {
            return
        }

        self.presenter.presentSubmissions(response: .init(stepID: stepID, isTeacher: lesson.canEdit))
    }

    func doBuyCourse(request: LessonDataFlow.BuyCourseAction.Request) {
        self.moduleOutput?.handleLessonDidRequestBuyCourse()
    }

    func doLeaveReviewPresentation(request: LessonDataFlow.LeaveReviewPresentation.Request) {
        self.moduleOutput?.handleLessonDidRequestLeaveReview()
    }

    func doCatalogPresentation(request: LessonDataFlow.CatalogPresentation.Request) {
        self.moduleOutput?.handleLessonDidRequestPresentCatalog()
    }

    func doLessonFinishedDemoModuleAddedCourseToWishlist(
        request: LessonDataFlow.LessonFinishedDemoModuleAddedCourseToWishlist.Request
    ) {
        self.moduleOutput?.handleLessonDidAddCourseToWishlist(courseID: request.courseID)
    }

    // MARK: Private API

    private func refreshLesson(
        context: LessonDataFlow.Context,
        startStep: LessonDataFlow.StartStep? = nil
    ) -> Promise<Void> {
        Promise { seal in
            self.previousUnit = nil
            self.nextUnit = nil
            self.currentLesson = nil
            self.currentUnit = nil
            self.currentData = nil
            self.assignmentsForCurrentSteps.removeAll()

            // FIXME: singleton
            if case .unit(let unitID) = context {
                LastStepGlobalContext.context.unitID = unitID
            }

            let startStep = startStep ?? .first
            self.lastLoadState = (context, startStep)

            if self.didLoadFromCache {
                self.loadData(context: context, startStep: startStep, dataSourceType: .remote).done {
                    seal.fulfill(())
                }.catch { error in
                    print("new lesson interactor: error while loading remote lesson = \(error)")
                    if let currentLesson = self.currentLesson, !currentLesson.steps.isEmpty {
                        seal.fulfill(())
                    } else {
                        self.presenter.presentLesson(response: .init(state: .failure(error)))
                        seal.reject(error)
                    }
                }
            } else {
                self.loadData(context: context, startStep: startStep, dataSourceType: .cache).done {
                    self.didLoadFromCache = true

                    attempt(retryLimit: 2) { [weak self] () -> Promise<Void> in
                        guard let strongSelf = self else {
                            return Promise(error: Error.fetchFailed)
                        }

                        return strongSelf.loadData(context: context, startStep: startStep, dataSourceType: .remote)
                    }.cauterize()

                    seal.fulfill(())
                }.catch { _ in
                    self.didLoadFromCache = true

                    self.loadData(context: context, startStep: startStep, dataSourceType: .remote).done {
                        seal.fulfill(())
                    }.catch { error in
                        print("new lesson interactor: error while loading remote lesson = \(error)")
                        self.presenter.presentLesson(response: .init(state: .failure(error)))
                        seal.reject(error)
                    }
                }
            }
        }
    }

    private func loadData(
        context: LessonDataFlow.Context,
        startStep: LessonDataFlow.StartStep,
        dataSourceType: DataSourceType
    ) -> Promise<Void> {
        firstly { () -> Promise<(Lesson?, Unit?)> in
            switch context {
            case .lesson(let lessonID):
                return self.provider
                    .fetchLesson(id: lessonID, dataSourceType: dataSourceType)
                    .map { ($0, nil) }
            case .unit(let unitID):
                return self.provider
                    .fetchLessonAndUnit(unitID: unitID, dataSourceType: dataSourceType)
                    .map { ($0.1, $0.0) }
            }
        }.then { lesson, unit -> Promise<([Assignment], Lesson)> in
            self.currentUnit = unit
            self.currentLesson = lesson

            guard let lesson = lesson else {
                throw Error.fetchFailed
            }

            // If unit exists then load assignments
            let assignmentsPromise: Promise<[Assignment]>
            if let unit = unit {
                unit.lesson = lesson
                assignmentsPromise = self.provider.fetchAssignments(
                    ids: unit.assignmentsArray,
                    dataSourceType: dataSourceType
                )
            } else {
                assignmentsPromise = .value([])
            }

            return assignmentsPromise.map { ($0, lesson) }
        }.then { assignments, lesson -> Promise<([Step]?, Lesson)> in
            let assignments = assignments.reordered(order: lesson.stepsArray, transform: { $0.stepId })

            for (index, stepID) in lesson.stepsArray.enumerated() where index < assignments.count {
                self.assignmentsForCurrentSteps[stepID] = assignments[index].id
            }

            return self.provider.fetchSteps(ids: lesson.stepsArray, dataSourceType: dataSourceType).map { ($0, lesson) }
        }.then { steps, lesson -> Promise<([Step], Lesson, [Progress])> in
            guard let steps = steps, !steps.isEmpty else {
                throw Error.fetchFailed
            }

            return self.provider
                .fetchProgresses(ids: steps.compactMap(\.progressID), dataSourceType: dataSourceType)
                .map { (steps, lesson, $0) }
        }.done { steps, lesson, progresses in
            let startStepIndex: Int = {
                switch startStep {
                case .index(let value):
                    return value
                case .id(let value):
                    return lesson.stepsArray.firstIndex(of: value) ?? 0
                case .last:
                    return max(0, lesson.stepsArray.count - 1)
                }
            }()

            steps.forEach { step in
                step.lesson = lesson

                if let progress = progresses.first(where: { $0.id == step.progressID }) {
                    step.progress = progress
                }
            }

            CoreDataHelper.shared.save()

            let data = LessonDataFlow.LessonLoad.Data(
                lesson: lesson,
                steps: steps,
                progresses: progresses,
                startStepIndex: startStepIndex,
                canEdit: lesson.canEdit
            )

            if self.didLoadFromCache {
                if self.currentData != data {
                    self.presenter.presentLesson(response: .init(state: .success(data)))
                }
            } else if lesson.stepsArray.count == steps.count && (0..<steps.count ~= startStepIndex) {
                self.presenter.presentLesson(response: .init(state: .success(data)))
            } else {
                throw Error.cacheMiss
            }

            self.currentData = data

            self.presenter.presentLessonTooltipInfo(
                response: .init(lesson: lesson, steps: steps, progresses: progresses)
            )
        }.ensure {
            self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
        }
    }

    private func refreshAdjacentUnits() {
        guard let unitID = self.currentUnit?.id else {
            return
        }

        let previousUnitPromise = self.unitNavigationService.findUnitForNavigation(from: unitID, direction: .previous)
        let nextUnitPromise = self.unitNavigationService.findUnitForNavigation(from: unitID, direction: .next)

        DispatchQueue.global(qos: .userInitiated).promise {
            when(fulfilled: previousUnitPromise, nextUnitPromise)
        }.done { [weak self] previousUnit, nextUnit in
            guard let strongSelf = self else {
                return
            }

            guard strongSelf.currentUnit?.id == unitID else {
                return
            }

            strongSelf.nextUnit = nextUnit
            strongSelf.previousUnit = previousUnit

            print("new lesson interactor: next & previous units did load")

            let hasNextUnit = nextUnit != nil || strongSelf.isCurrentUnitLastInCourse

            strongSelf.presenter.presentLessonNavigation(
                response: .init(hasPreviousUnit: previousUnit != nil, hasNextUnit: hasNextUnit)
            )
        }.cauterize()
    }

    private func refreshTooltipInfo(stepID: Step.IdType) {
        guard let lesson = self.currentLesson else {
            return
        }

        self.provider.fetchSteps(ids: [stepID]).map {
            $0.value
        }.then { steps -> Promise<(Step, Progress.IdType)> in
            if let step = steps?.first, let progressID = step.progressID {
                return .value((step, progressID))
            }
            throw Error.fetchFailed
        }.then { step, progressID -> Promise<([Progress]?, Step)> in
            self.provider.fetchProgresses(ids: [progressID]).map { ($0.value, step) }
        }.done { progresses, step in
            if let progress = progresses?.first {
                self.presenter.presentStepTooltipInfoUpdate(
                    response: .init(lesson: lesson, step: step, progress: progress)
                )
            } else {
                throw Error.fetchFailed
            }
        }.cauterize()
    }

    // MARK: Enums

    enum Error: Swift.Error {
        case fetchFailed
        case cacheMiss
    }
}

// MARK: - LessonInteractor: StepOutputProtocol -

extension LessonInteractor: StepOutputProtocol {
    private static let autoplayDelay: TimeInterval = 0.33
    private static let unitNavigationDelay: TimeInterval = 0.5

    private var isCurrentUnitLastInCourse: Bool {
        self.nextUnit == nil
            && self.currentUnit?.position == self.currentUnit?.section?.unitsArray.count
            && self.currentUnit?.section?.position == self.currentUnit?.section?.course?.sectionsArray.count
    }

    func handleStepView(id: Step.IdType) {
        let assignmentID = self.assignmentsForCurrentSteps[id]

        guard self.currentLesson?.stepsArray.contains(id) ?? false else {
            return
        }

        self.provider.createView(stepID: id, assignmentID: assignmentID).done {
            print("new lesson interactor: view for step \(id) & assignment = \(assignmentID ?? -1) did sent")
        }.catch { _ in
            self.persistenceQueuesService.addSendViewTask(stepID: id, assignmentID: assignmentID)
        }
    }

    func handleStepDone(id: Step.IdType) {
        self.presenter.presentStepPassedStatusUpdate(response: .init(stepID: id))

        if let unit = self.currentUnit {
            self.dataBackUpdateService.triggerProgressUpdate(unit: unit.id, triggerRecursive: true)
        }

        self.refreshTooltipInfo(stepID: id)
    }

    func handlePreviousUnitNavigation() {
        self.navigateToPreviousUnit(shouldAutoplayStep: false)
    }

    func handleNextUnitNavigation() {
        self.navigateToNextUnit(shouldAutoplayStep: false)
    }

    func handleLessonNavigation(lessonID: Int, stepIndex: Int, unitID: Int?) {
        guard let currentLesson = self.currentLesson else {
            return
        }

        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        self.provider
            .fetchLesson(id: lessonID, dataSourceType: .remote)
            .compactMap { $0 }
            .then { requestedLesson -> Promise<Void> in
                if currentLesson.coursesArray == requestedLesson.coursesArray {
                    let initialContext: LessonDataFlow.Context = {
                        if let unitID = unitID {
                            return .unit(id: unitID)
                        }
                        return .lesson(id: lessonID)
                    }()

                    self.didLoadFromCache = false

                    return self.refreshLesson(context: initialContext, startStep: .index(stepIndex - 1))
                } else {
                    self.presenter.presentLessonModule(response: .init(lessonID: lessonID, stepIndex: stepIndex))
                    return .value(())
                }
            }.ensure {
                self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
            }.cauterize()
    }

    func handleStepNavigation(to index: Int) {
        self.navigateToStep(at: index, shouldAutoplayStep: false)
    }

    func handleAutoplayNavigation(from index: Int, direction: AutoplayNavigationDirection) {
        guard let lesson = self.currentLesson else {
            return
        }

        switch direction {
        case .forward:
            let isCurrentIndexLast = index == max(0, (lesson.stepsArray.count - 1))

            if isCurrentIndexLast {
                self.navigateToNextUnit(shouldAutoplayStep: true)
            } else {
                self.navigateToStep(at: index + 1, shouldAutoplayStep: true)
            }
        case .backward:
            if index == 0 {
                self.navigateToPreviousUnit(shouldAutoplayStep: true)
            } else {
                self.navigateToStep(at: index - 1, shouldAutoplayStep: true)
            }
        }
    }

    // MARK: Private helpers

    private func navigateToPreviousUnit(shouldAutoplayStep: Bool) {
        guard let unit = self.previousUnit else {
            return
        }

        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        firstly {
            after(seconds: Self.unitNavigationDelay)
        }.then {
            self.presentUnreachableUnitNavigationState(targetUnit: unit, direction: .previous)
        }.done { didPresentUnreachableState in
            if didPresentUnreachableState {
                self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
            } else {
                self.didLoadFromCache = false
                self.refreshLesson(context: .unit(id: unit.id), startStep: .last).done {
                    if shouldAutoplayStep {
                        self.autoplayCurrentStep()
                    }
                }.cauterize()
            }
        }
    }

    private func navigateToNextUnit(shouldAutoplayStep: Bool) {
        guard let unit = self.nextUnit else {
            if self.isCurrentUnitLastInCourse {
                self.presentLessonFinishedSteps()
            }
            return
        }

        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        firstly {
            after(seconds: Self.unitNavigationDelay)
        }.then {
            self.presentUnreachableUnitNavigationState(targetUnit: unit, direction: .next)
        }.done { didPresentUnreachableState in
            if didPresentUnreachableState {
                self.presenter.presentWaitingState(response: .init(shouldDismiss: true))
            } else {
                self.didLoadFromCache = false
                self.refreshLesson(context: .unit(id: unit.id), startStep: .first).done {
                    if shouldAutoplayStep {
                        self.autoplayCurrentStep()
                    }
                }.cauterize()
            }
        }
    }

    private func navigateToStep(at index: Int, shouldAutoplayStep: Bool) {
        guard let lesson = self.currentLesson else {
            return
        }

        let stepsRange = lesson.stepsArray.startIndex..<lesson.stepsArray.endIndex

        if stepsRange.contains(index) {
            self.presenter.presentCurrentStepUpdate(response: .init(index: index))

            if shouldAutoplayStep {
                self.autoplayCurrentStep()
            }
        }
    }

    private func autoplayCurrentStep() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.autoplayDelay) {
            self.presenter.presentCurrentStepAutoplay(response: .init())
        }
    }

    private func presentUnreachableUnitNavigationState(
        targetUnit: Unit,
        direction: UnitNavigationDirection
    ) -> Guarantee<Bool> {
        guard let currentLesson = self.currentLesson,
              let currentSection = self.currentUnit?.section,
              let targetSection = targetUnit.section else {
            return .value(false)
        }

        if targetSection.testSectionAction != nil {
            return .value(false)
        }
        if targetSection.isReachable() && !targetSection.isExam {
            return .value(false)
        }

        if !targetSection.isRequirementSatisfied, let requiredSectionID = targetSection.requiredSectionID {
            return Guarantee { seal in
                self.presentRequirementNotSatisfiedUnitNavigationState(
                    currentSection: currentSection,
                    targetSection: targetSection,
                    requiredSectionID: requiredSectionID,
                    unitNavigationDirection: direction
                ).done { _ in
                    seal(true)
                }.catch { _ in
                    self.presenter.presentUnitNavigationUnreachableState(response: .init(targetSection: targetSection))
                    seal(true)
                }
            }
        }

        if let beginDate = targetSection.beginDate, Date() < beginDate {
            self.presenter.presentUnitNavigationClosedByDateState(
                response: .init(
                    currentSection: currentSection,
                    targetSection: targetSection,
                    dateSource: .beginDate,
                    unitNavigationDirection: direction
                )
            )
            return .value(true)
        }

        if let endDate = targetSection.endDate, Date() > endDate {
            self.presenter.presentUnitNavigationClosedByDateState(
                response: .init(
                    currentSection: currentSection,
                    targetSection: targetSection,
                    dateSource: .endDate,
                    unitNavigationDirection: direction
                )
            )
            return .value(true)
        }

        if targetSection.isExam {
            self.presenter.presentUnitNavigationExamState(
                response: .init(
                    currentSection: currentSection,
                    targetSection: targetSection,
                    unitNavigationDirection: direction
                )
            )
            return .value(true)
        }

        return self.presentUnitNavigationFinishedDemoAccessState(
            currentLesson: currentLesson,
            currentSection: currentSection,
            targetUnit: targetUnit
        )
    }

    private func presentRequirementNotSatisfiedUnitNavigationState(
        currentSection: Section,
        targetSection: Section,
        requiredSectionID: Section.IdType,
        unitNavigationDirection: UnitNavigationDirection
    ) -> Promise<Void> {
        self.provider
            .fetchSectionFromCacheOrNetwork(id: requiredSectionID)
            .compactMap { $0 }
            .then { section -> Promise<Section> in
                if section.progress == nil,
                   let progressID = section.progressId {
                    return self.provider.fetchProgresses(
                        ids: [progressID],
                        dataSourceType: .remote
                    ).then { progresses -> Promise<Section> in
                        section.progress = progresses.first
                        CoreDataHelper.shared.save()
                        return .value(section)
                    }
                } else {
                    return .value(section)
                }
            }
            .done { requiredSection in
                self.presenter.presentUnitNavigationRequirementNotSatisfiedState(
                    response: .init(
                        currentSection: currentSection,
                        targetSection: targetSection,
                        requiredSection: requiredSection,
                        unitNavigationDirection: unitNavigationDirection
                    )
                )
            }
    }

    private func presentUnitNavigationFinishedDemoAccessState(
        currentLesson: Lesson,
        currentSection: Section,
        targetUnit: Unit
    ) -> Guarantee<Bool> {
        guard currentLesson.canLearnLesson else {
            return .value(false)
        }

        return Guarantee { seal in
            firstly { () -> Promise<Course> in
                if let course = currentSection.course {
                    return .value(course)
                } else {
                    return self.provider.fetchCourseFromCacheOrNetwork(id: currentSection.courseId).compactMap { $0 }
                }
            }.then { course -> Promise<Lesson> in
                guard !course.enrolled && course.isPaid else {
                    throw Error.fetchFailed
                }

                if let lesson = targetUnit.lesson {
                    return .value(lesson)
                } else {
                    return self.provider.fetchLessonFromCacheOrNetwork(id: targetUnit.lessonId).compactMap { $0 }
                }
            }.done { targetLesson in
                if !targetLesson.canLearnLesson {
                    self.presenter.presentUnitNavigationFinishedDemoAccessState(
                        response: .init(section: currentSection, promoCodeName: self.promoCodeName)
                    )
                    seal(true)
                } else {
                    seal(false)
                }
            }.catch { _ in
                seal(false)
            }
        }
    }

    private func presentLessonFinishedSteps() {
        guard let currentSection = self.currentUnit?.section else {
            return
        }

        firstly { () -> Promise<Course> in
            if let course = currentSection.course {
                return .value(course)
            } else {
                return self.provider.fetchCourseFromCacheOrNetwork(id: currentSection.courseId).compactMap { $0 }
            }
        }.done { course in
            self.presenter.presentLessonFinishedSteps(response: .init(courseID: course.id))
        }.cauterize()
    }
}

// MARK: - LessonInteractor: EditStepOutputProtocol -

extension LessonInteractor: EditStepOutputProtocol {
    func handleStepSourceUpdated(_ stepSource: StepSource) {
        guard let lesson = self.currentLesson,
              let stepIndex = lesson.stepsArray.firstIndex(where: { $0 == stepSource.id }) else {
            return
        }

        self.presenter.presentStepTextUpdate(response: .init(index: stepIndex, stepSource: stepSource))
    }
}
