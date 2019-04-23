import Foundation
import PromiseKit

protocol NewLessonInteractorProtocol {
    func doSomeAction(request: NewLesson.SomeAction.Request)
}

final class NewLessonInteractor: NewLessonInteractorProtocol {
    weak var moduleOutput: NewLessonOutputProtocol?

    private let presenter: NewLessonPresenterProtocol
    private let provider: NewLessonProviderProtocol

    private var currentLesson: Lesson?
    private var currentUnit: Unit?

    init(
        initialContext: NewLesson.Context,
        presenter: NewLessonPresenterProtocol,
        provider: NewLessonProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider

        self.loadData(context: initialContext)
    }

    // MARK: Public API

    func doSomeAction(request: NewLesson.SomeAction.Request) { }

    // MARK: Private API

    private func loadData(context: NewLesson.Context) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else {
                return
            }

            switch context {
            case .lesson(let lessonID):
                strongSelf.provider.fetchLesson(id: lessonID).done { result in
                    guard let lesson = result.value else {
                        // Unable to load lesson, should check source of result
                        throw PMKError.emptySequence
                    }
                    strongSelf.currentLesson = lesson

                    print(strongSelf.currentLesson?.title)
                }.catch { _ in
                    // Handle errors
                }
            case .unit(let unitID):
                strongSelf.provider.fetchLessonAndUnit(unitID: unitID).done { result in
                    strongSelf.currentUnit = result.0.value
                    strongSelf.currentLesson = result.1.value

                    print(strongSelf.currentUnit?.id, strongSelf.currentLesson?.title)
                }.catch { _ in
                    // Handle errors
                }
            }
        }
    }

    // MARK: Enums

    enum Error: Swift.Error {
        case something
    }
}

extension NewLessonInteractor: NewLessonInputProtocol { }
