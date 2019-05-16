import Foundation
import PromiseKit

protocol NewLessonInteractorProtocol { }

final class NewLessonInteractor: NewLessonInteractorProtocol {
    weak var moduleOutput: NewLessonOutputProtocol?

    private let presenter: NewLessonPresenterProtocol
    private let provider: NewLessonProviderProtocol
    private let unitNavigationService: UnitNavigationServiceProtocol

    private var currentLesson: Lesson?

    private var previousUnit: Unit?
    private var currentUnit: Unit? {
        didSet {
            self.refreshAdjacentUnits()
        }
    }
    private var nextUnit: Unit?

    init(
        initialContext: NewLesson.Context,
        presenter: NewLessonPresenterProtocol,
        provider: NewLessonProviderProtocol,
        unitNavigationService: UnitNavigationServiceProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
        self.unitNavigationService = unitNavigationService

        self.refresh(context: initialContext)
    }

    // MARK: Public API

    private func refresh(context: NewLesson.Context) {
        self.loadData(context: context)
    }

    // MARK: Private API

    private func loadData(context: NewLesson.Context) {
        firstly { () -> Promise<(Lesson?, Unit?)> in
            switch context {
            case .lesson(let lessonID):
                return self.provider.fetchLesson(id: lessonID).map { ($0.value, nil) }
            case .unit(let unitID):
                return self.provider.fetchLessonAndUnit(unitID: unitID).map { ($0.1.value, $0.0.value) }
            }
        }.then(on: DispatchQueue.global(qos: .userInitiated)) { lesson, unit -> Promise<([Step]?, Lesson)> in
            self.currentUnit = unit
            self.currentLesson = lesson

            guard let lesson = lesson else {
                throw Error.fetchFailed
            }

            return self.provider.fetchSteps(ids: lesson.stepsArray).map { ($0.value, lesson) }
        }.done(on: DispatchQueue.global(qos: .userInitiated)) { steps, lesson in
            guard let steps = steps else {
                throw Error.fetchFailed
            }

            DispatchQueue.main.async {
                self.presenter.presentLesson(response: .init(data: .success((lesson, steps))))
            }
        }.cauterize()
    }

    private func refreshAdjacentUnits() {
        guard let unit = self.currentUnit else {
            return
        }

        self.unitNavigationService.findUnitForNavigation(
            from: unit.id,
            direction: .next
        ).done(on: DispatchQueue.global(qos: .userInitiated)) { [weak self] nextUnit in
            guard let nextUnit = nextUnit, let strongSelf = self else {
                return
            }

            if unit.id == strongSelf.currentUnit?.id {
                strongSelf.nextUnit = nextUnit
                print(nextUnit, "next")
            }
        }.cauterize()

        self.unitNavigationService.findUnitForNavigation(
            from: unit.id,
            direction: .previous
        ).done(on: DispatchQueue.global(qos: .userInitiated)) { [weak self] previousUnit in
            guard let previousUnit = previousUnit, let strongSelf = self else {
                return
            }

            if unit.id == strongSelf.currentUnit?.id {
                strongSelf.previousUnit = previousUnit
                print(previousUnit, "previous")
            }
        }.cauterize()
    }

    // MARK: Enums

    enum Error: Swift.Error {
        case fetchFailed
    }
}

extension NewLessonInteractor: NewLessonInputProtocol { }
