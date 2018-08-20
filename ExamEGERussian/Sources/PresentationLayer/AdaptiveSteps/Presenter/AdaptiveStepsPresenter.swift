//
//  AdaptiveStepsPresenter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AdaptiveStepsPresenter: AdaptiveStepsPresenterProtocol {
    private weak var view: AdaptiveStepsView?

    private let courseId: String
    private var stepViewController: StepViewController?

    private let recommendationsService: RecommendationsServiceProtocol
    private let reactionService: ReactionServiceProtocol

    init(view: AdaptiveStepsView,
         courseId: String,
         recommendationsService: RecommendationsServiceProtocol,
         reactionService: ReactionServiceProtocol
    ) {
        self.view = view
        self.courseId = courseId
        self.recommendationsService = recommendationsService
        self.reactionService = reactionService
    }
}
