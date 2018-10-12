//
//  TagsTagsInterac?tor.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol TagsInteractorProtocol {
    func fetchTags(request: Tags.ShowTags.Request)
    func presentTagCollection(request: Tags.PresentCollection.Request)
}

final class TagsInteractor: TagsInteractorProtocol {
    weak var moduleOutput: TagsOutputProtocol?

    let presenter: TagsPresenterProtocol
    let provider: TagsProviderProtocol
    let contentLanguage: ContentLanguage

    private var currentTags: [(UniqueIdentifierType, Tags.Tag)] = []

    init(
        presenter: TagsPresenterProtocol,
        provider: TagsProviderProtocol,
        contentLanguage: ContentLanguage
    ) {
        self.presenter = presenter
        self.provider = provider
        self.contentLanguage = contentLanguage
    }

    // MARK: Actions

    func fetchTags(request: Tags.ShowTags.Request) {
        self.provider.fetchTags().done { tags in
            let newTags = tags.map { tag in
                Tags.Tag(
                    id: tag.ID,
                    title: tag.titleForLanguage[self.contentLanguage] ?? "",
                    summary: tag.summaryForLanguage[self.contentLanguage] ?? "",
                    analyticsTitle: tag.titleForLanguage[.english] ?? ""
                )
            }
            self.currentTags = newTags.map { ("\($0.id)", $0) }
            self.presenter.presentTags(
                response: Tags.ShowTags.Response(result: .success(self.currentTags))
            )
        }
    }

    func presentTagCollection(request: Tags.PresentCollection.Request) {
        guard let tag = self.currentTags
            .first(where: { $0.0 == request.viewModelUniqueIdentifier})?.1 else {
            return
        }

        // FIXME: analytics dependency
        AmplitudeAnalyticsEvents.Catalog.Category.opened(
            categoryID: tag.id,
            categoryNameEn: tag.analyticsTitle
        ).send()

        self.moduleOutput?.presentCourseList(
            type: TagCourseListType(id: tag.id, language: self.contentLanguage)
        )
    }
}
