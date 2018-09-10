//
//  ReactionService.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 17/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class ReactionService: ReactionServiceProtocol {
    private let recommendationsAPI: RecommendationsAPI

    init(recommendationsAPI: RecommendationsAPI) {
        self.recommendationsAPI = recommendationsAPI
    }

    func sendReaction(_ reaction: Reaction, forLesson lessonId: Int, byUser userId: Int) -> Promise<Void> {
        return recommendationsAPI.sendReaction(user: userId, lesson: lessonId, reaction: reaction)
    }
}
