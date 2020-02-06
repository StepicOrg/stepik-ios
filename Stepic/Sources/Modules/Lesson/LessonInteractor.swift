import Foundation
import PromiseKit

protocol LessonInteractorProtocol {
    func doLessonLoad(request: LessonDataFlow.LessonLoad.Request)
    func doEditStepPresentation(request: LessonDataFlow.EditStepPresentation.Request)
}

final class LessonInteractor: LessonInteractorProtocol {
    private let presenter: LessonPresenterProtocol
    private let provider: LessonProviderProtocol
    private let unitNavigationService: UnitNavigationServiceProtocol
    private let persistenceQueuesService: PersistenceQueuesServiceProtocol
    private let dataBackUpdateService: DataBackUpdateServiceProtocol

    private var currentLesson: Lesson?

    private var previousUnit: Unit?
    private var currentUnit: Unit? {
        didSet {
            self.refreshAdjacentUnits()
        }
    }
    private var nextUnit: Unit?
    private var assignmentsForCurrentSteps: [Step.IdType: Assignment.IdType] = [:]

    private var lastLoadState: (context: LessonDataFlow.Context, startStep: LessonDataFlow.StartStep?)

    init(
        initialContext: LessonDataFlow.Context,
        startStep: LessonDataFlow.StartStep?,
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
            self.assignmentsForCurrentSteps.removeAll()

            // FIXME: singleton
            if case .unit(let unitID) = context {
                LastStepGlobalContext.context.unitId = unitID
            }

            let startStep = startStep ?? .index(0)
            self.lastLoadState = (context, startStep)

            self.loadData(context: context, startStep: startStep).done {
                seal.fulfill(())
            }.catch { error in
                print("new lesson interactor: error while loading lesson = \(error)")
                self.presenter.presentLesson(response: .init(state: .failure(error)))
                seal.reject(error)
            }
        }
    }

    private func loadData(context: LessonDataFlow.Context, startStep: LessonDataFlow.StartStep) -> Promise<Void> {
        firstly { () -> Promise<(Lesson?, Unit?)> in
            switch context {
            case .lesson(let lessonID):
                return self.provider.fetchLesson(id: lessonID).map { ($0.value, nil) }
            case .unit(let unitID):
                return self.provider.fetchLessonAndUnit(unitID: unitID).map { ($0.1.value, $0.0.value) }
            }
        }.then(on: .global(qos: .userInitiated)) { lesson, unit -> Promise<([Assignment], Lesson)> in
            self.currentUnit = unit
            self.currentLesson = lesson

            guard let lesson = lesson else {
                throw Error.fetchFailed
            }

            // If unit exists then load assignments
            let assignmentsPromise: Promise<[Assignment]>
            if let unit = unit {
                unit.lesson = lesson
                assignmentsPromise = self.provider.fetchAssignments(ids: unit.assignmentsArray).map { $0.value ?? [] }
            } else {
                assignmentsPromise = .value([])
            }

            return assignmentsPromise.map { ($0, lesson) }
        }.then(on: .global(qos: .userInitiated)) { assignments, lesson -> Promise<([Step]?, Lesson)> in
            let assignments = assignments.reordered(order: lesson.stepsArray, transform: { $0.stepId })

            for (index, stepID) in lesson.stepsArray.enumerated() where index < assignments.count {
                self.assignmentsForCurrentSteps[stepID] = assignments[index].id
            }

            return self.provider.fetchSteps(ids: lesson.stepsArray).map { ($0.value, lesson) }
        }.then(on: .global(qos: .userInitiated)) { steps, lesson -> Promise<([Step], Lesson, [Progress])> in
            guard let steps = steps, !steps.isEmpty else {
                throw Error.fetchFailed
            }

            return self.provider.fetchProgresses(ids: steps.compactMap { $0.progressID })
                .map { (steps, lesson, $0.value ?? []) }
        }.done { steps, lesson, progresses in
            let startStepIndex: Int = {
                switch startStep {
                case .index(let value):
                    return value
                case .id(let value):
                    return lesson.stepsArray.firstIndex(of: value) ?? 0
                }
            }()

            steps.forEach { $0.lesson = lesson }

            let data = LessonDataFlow.LessonLoad.Data(
                lesson: lesson,
                steps: steps,
                progresses: progresses,
                startStepIndex: startStepIndex,
                canEdit: lesson.canEdit
            )

            self.presenter.presentLesson(response: .init(state: .success(data)))
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

            if strongSelf.currentUnit?.id == unitID {
                strongSelf.nextUnit = nextUnit
                strongSelf.previousUnit = previousUnit

                print("new lesson interactor: next & previous units did load")

                strongSelf.presenter.presentLessonNavigation(
                    response: .init(hasPreviousUnit: previousUnit != nil, hasNextUnit: nextUnit != nil)
                )
            }
        }.cauterize()
    }

    private func refreshTooltipInfo(stepID: Step.IdType) {
        guard let lesson = self.currentLesson else {
            return
        }

        self.provider.fetchSteps(ids: [stepID]).map {
            $0.value
        }.then { steps -> Promise<(Step, Progress.IdType)> in
            guard let step = steps?.first,
                  let progressID = step.progressID else {
                throw Error.fetchFailed
            }
            return .value((step, progressID))
        }.then { step, progressID -> Promise<([Progress]?, Step)> in
            self.provider.fetchProgresses(ids: [progressID]).map { ($0.value, step) }
        }.done { progresses, step in
            guard let progress = progresses?.first else {
                throw Error.fetchFailed
            }
            self.presenter.presentStepTooltipInfoUpdate(response: .init(lesson: lesson, step: step, progress: progress))
        }.cauterize()
    }

    // MARK: Enums

    enum Error: Swift.Error {
        case fetchFailed
    }
}

// MARK: - LessonInteractor: StepOutputProtocol -

extension LessonInteractor: StepOutputProtocol {
    private static let autoplayDelay: TimeInterval = 0.33

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
        guard let unit = self.previousUnit else {
            return
        }

        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))
        self.refreshLesson(context: .unit(id: unit.id)).cauterize()
    }

    func handleNextUnitNavigation() {
        self.navigateToNextUnit(autoplayNext: false)
    }

    func handleStepNavigation(to index: Int) {
        self.navigateToStep(at: index, autoplayNext: false)
    }

    func handleAutoplayNavigation(from index: Int) {
        guard let lesson = self.currentLesson else {
            return
        }

        let isCurrentIndexLast = index == max(0, (lesson.stepsArray.count - 1))

        if isCurrentIndexLast {
            self.navigateToNextUnit(autoplayNext: true)
        } else {
            self.navigateToStep(at: index + 1, autoplayNext: true)
        }
    }

    // MARK: Private helpers

    private func navigateToNextUnit(autoplayNext: Bool) {
        guard let unit = self.nextUnit else {
            return
        }

        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))
        self.refreshLesson(context: .unit(id: unit.id)).done {
            if autoplayNext {
                self.autoplayCurrentStep()
            }
        }.cauterize()
    }

    private func navigateToStep(at index: Int, autoplayNext: Bool) {
        guard let lesson = self.currentLesson else {
            return
        }

        let stepsRange = lesson.stepsArray.startIndex..<lesson.stepsArray.endIndex
        if stepsRange.contains(index) {
            self.presenter.presentCurrentStepUpdate(response: .init(index: index))
            self.autoplayCurrentStep()
        }
    }

    private func autoplayCurrentStep() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.autoplayDelay) {
            self.presenter.presentCurrentStepAutoplay(response: .init())
        }
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
