import Foundation
import PromiseKit

protocol TagsInteractorProtocol {
    func doTagsFetch(request: Tags.TagsLoad.Request)
    func doTagCollectionPresentation(request: Tags.TagCollectionPresentation.Request)
}

final class TagsInteractor: TagsInteractorProtocol {
    weak var moduleOutput: TagsOutputProtocol?

    private let presenter: TagsPresenterProtocol
    private let provider: TagsProviderProtocol
    private let contentLanguage: ContentLanguage
    private let analytics: Analytics

    private var currentTags: [(UniqueIdentifierType, Tags.Tag)] = []

    init(
        presenter: TagsPresenterProtocol,
        provider: TagsProviderProtocol,
        contentLanguage: ContentLanguage,
        analytics: Analytics
    ) {
        self.presenter = presenter
        self.provider = provider
        self.contentLanguage = contentLanguage
        self.analytics = analytics
    }

    // MARK: Actions

    func doTagsFetch(request: Tags.TagsLoad.Request) {
        self.provider.fetchTags().done { tags in
            let newTags = tags.map { tag in
                Tags.Tag(
                    id: tag.uniqueIdentifier,
                    title: tag.titleForLanguage[self.contentLanguage] ?? "",
                    summary: tag.summaryForLanguage[self.contentLanguage] ?? "",
                    analyticsTitle: tag.titleForLanguage[.english] ?? ""
                )
            }
            self.currentTags = newTags.map { ("\($0.id)", $0) }
            self.presenter.presentTags(
                response: Tags.TagsLoad.Response(result: .success(self.currentTags))
            )
        }
    }

    func doTagCollectionPresentation(request: Tags.TagCollectionPresentation.Request) {
        guard let tag = self.currentTags.first(where: { $0.0 == request.viewModelUniqueIdentifier })?.1 else {
            return
        }

        self.analytics.send(.catalogCategoryOpened(categoryID: tag.id, categoryNameEn: tag.analyticsTitle))

        self.moduleOutput?.presentCourseList(
            type: TagCourseListType(id: tag.id, language: self.contentLanguage)
        )
    }
}
