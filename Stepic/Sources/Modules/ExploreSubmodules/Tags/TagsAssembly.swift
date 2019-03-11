import UIKit

final class TagsAssembly: Assembly {
    let contentLanguage: ContentLanguage

    private weak var moduleOutput: TagsOutputProtocol?

    init(
        contentLanguage: ContentLanguage,
        output: TagsOutputProtocol? = nil
    ) {
        self.contentLanguage = contentLanguage
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = TagsProvider()
        let presenter = TagsPresenter()
        let interactor = TagsInteractor(
            presenter: presenter,
            provider: provider,
            contentLanguage: self.contentLanguage
        )
        let viewController = TagsViewController(
            interactor: interactor
        )
        interactor.moduleOutput = self.moduleOutput

        presenter.viewController = viewController
        return viewController
    }
}
