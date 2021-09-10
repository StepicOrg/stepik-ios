import Foundation
import PromiseKit

protocol CourseInfoTabNewsInteractorProtocol {
    func doSomeAction(request: CourseInfoTabNews.SomeAction.Request)
}

final class CourseInfoTabNewsInteractor: CourseInfoTabNewsInteractorProtocol {
    weak var moduleOutput: CourseInfoTabNewsOutputProtocol?

    private let presenter: CourseInfoTabNewsPresenterProtocol
    private let provider: CourseInfoTabNewsProviderProtocol

    init(
        presenter: CourseInfoTabNewsPresenterProtocol,
        provider: CourseInfoTabNewsProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: CourseInfoTabNews.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension CourseInfoTabNewsInteractor: CourseInfoTabNewsInputProtocol {}
