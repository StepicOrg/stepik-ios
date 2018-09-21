//
//  TagsTagsInteractor.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import Foundation
import PromiseKit

protocol TagsInteractorProtocol {
    func fetchTags(request: Tags.ShowTags.Request)
}

final class TagsInteractor: TagsInteractorProtocol {
    let presenter: TagsPresenterProtocol
    let provider: TagsProviderProtocol
    let contentLanguage: ContentLanguage

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
            self.presenter.presentTags(
                response: Tags.ShowTags.Response(result: .success(newTags))
            )
        }
    }
}
