import Foundation
import PromiseKit

protocol NewLessonInteractorProtocol {
    func doLessonLoad(request: NewLesson.LessonLoad.Request)
}

final class NewLessonInteractor: NewLessonInteractorProtocol {
    private let presenter: NewLessonPresenterProtocol
    private let provider: NewLessonProviderProtocol
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

    private var lastLoadState: (context: NewLesson.Context, startStep: NewLesson.StartStep?)

    init(
        initialContext: NewLesson.Context,
        startStep: NewLesson.StartStep?,
        presenter: NewLessonPresenterProtocol,
        provider: NewLessonProviderProtocol,
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

    func doLessonLoad(request: NewLesson.LessonLoad.Request) {
        self.refresh(context: self.lastLoadState.context, startStep: self.lastLoadState.startStep)
    }

    // MARK: Private API

    private func refresh(context: NewLesson.Context, startStep: NewLesson.StartStep? = nil) {
        self.previousUnit = nil
        self.nextUnit = nil
        self.currentLesson = nil
        self.currentUnit = nil
        self.assignmentsForCurrentSteps.removeAll()

        self.presenter.presentLesson(response: .init(state: .loading))

        // FIXME: singleton
        if case .unit(let unitID) = context {
            LastStepGlobalContext.context.unitId = unitID
        }

        let startStep = startStep ?? .index(0)

        self.lastLoadState = (context, startStep)
        self.loadData(context: context, startStep: startStep)
    }

    private func loadData(context: NewLesson.Context, startStep: NewLesson.StartStep) {
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
            guard let steps = steps else {
                throw Error.fetchFailed
            }

            return self.provider.fetchProgresses(ids: steps.compactMap { $0.progressId })
                .map { (steps, lesson, $0.value ?? []) }
        }.done(on: .global(qos: .userInitiated)) { steps, lesson, progresses in
            let startStepIndex: Int = {
                switch startStep {
                case .index(let value):
                    return value
                case .id(let value):
                    return lesson.stepsArray.index(of: value) ?? 0
                }
            }()

            DispatchQueue.main.async {
                let data = NewLesson.LessonLoad.ResponseData(
                    lesson: lesson,
                    steps: steps,
                    progresses: progresses,
                    startStepIndex: startStepIndex
                )

                self.presenter.presentLesson(response: .init(state: .success(result: data)))
            }
        }.catch { error in
            print("new lesson interactor: error while loading lesson = \(error)")
            self.presenter.presentLesson(response: .init(state: .error))
        }
    }

    private func refreshAdjacentUnits() {
        guard let unitID = self.currentUnit?.id else {
            return
        }

        let previousUnitPromise = self.unitNavigationService.findUnitForNavigation(from: unitID, direction: .previous)
        let nextUnitPromise = self.unitNavigationService.findUnitForNavigation(from: unitID, direction: .next)

        when(
            fulfilled: previousUnitPromise, nextUnitPromise
        ).done(on: .global(qos: .userInitiated)) { [weak self] previousUnit, nextUnit in
            guard let strongSelf = self else {
                return
            }

            if strongSelf.currentUnit?.id == unitID {
                strongSelf.nextUnit = nextUnit
                strongSelf.previousUnit = previousUnit

                print("new lesson interactor: next & previous units did load")

                DispatchQueue.main.async {
                    strongSelf.presenter.presentLessonNavigation(
                        response: .init(hasPreviousUnit: previousUnit != nil, hasNextUnit: nextUnit != nil)
                    )
                }
            }
        }.cauterize()
    }

    // MARK: Enums

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension NewLessonInteractor: NewStepOutputProtocol {
    func handlePreviousUnitNavigation() {
        guard let unit = self.previousUnit else {
            return
        }

        self.refresh(context: .unit(id: unit.id))
    }

    func handleNextUnitNavigation() {
        guard let unit = self.nextUnit else {
            return
        }

        self.refresh(context: .unit(id: unit.id))
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
    }

    func handleStepNavigation(to index: Int) {
        guard let lesson = self.currentLesson, index > 0 && index < lesson.stepsArray.count else {
            return
        }

        self.presenter.presentCurrentStepUpdate(response: .init(index: index))
    }
}
