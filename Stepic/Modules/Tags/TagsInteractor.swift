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

    private var currentTags: [Tags.Tag] = []

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
                    summary: tag.summaryForLanguage[self.contentLanguage] ?? ""
                )
            }
            self.currentTags = newTags
            self.presenter.presentTags(
                response: Tags.ShowTags.Response(result: .success(newTags))
            )
        }
    }

    func presentTagCollection(request: Tags.PresentCollection.Request) {
        guard let selectedIndex = Int(request.viewModelUniqueIdentifier),
              let tag = self.currentTags[safe: selectedIndex] else {
            return
        }

        self.moduleOutput?.presentCourseList(
            type: TagCourseListType(id: tag.id, language: self.contentLanguage)
        )
    }
}
