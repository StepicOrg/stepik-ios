import Foundation
import PromiseKit

protocol NewProfileCreatedCoursesInteractorProtocol {
    func doSomeAction(request: NewProfileCreatedCourses.SomeAction.Request)
}

final class NewProfileCreatedCoursesInteractor: NewProfileCreatedCoursesInteractorProtocol {
    weak var moduleOutput: NewProfileCreatedCoursesOutputProtocol?

    private let presenter: NewProfileCreatedCoursesPresenterProtocol
    private let provider: NewProfileCreatedCoursesProviderProtocol

    init(
        presenter: NewProfileCreatedCoursesPresenterProtocol,
        provider: NewProfileCreatedCoursesProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: NewProfileCreatedCourses.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension NewProfileCreatedCoursesInteractor: NewProfileSubmoduleProtocol {
    func update(with user: User, isCurrentUserProfile: Bool, isOnline: Bool) {}
}
