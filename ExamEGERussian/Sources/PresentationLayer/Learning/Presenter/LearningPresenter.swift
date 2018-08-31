//
//  LearningPresenter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class LearningPresenter: LearningPresenterProtocol {
    private weak var view: LearningView?

    private let knowledgeGraph: KnowledgeGraph

    private let userRegistrationService: UserRegistrationService
    private let graphService: GraphServiceProtocol

    private var isFirstRefresh = true

    init(view: LearningView,
         knowledgeGraph: KnowledgeGraph,
         userRegistrationService: UserRegistrationService,
         graphService: GraphServiceProtocol
    ) {
        self.view = view
        self.knowledgeGraph = knowledgeGraph
        self.userRegistrationService = userRegistrationService
        self.graphService = graphService
    }

    func refresh() {
        checkAuthStatus()

        if isFirstRefresh && !knowledgeGraph.isEmpty {
            isFirstRefresh = false
            reloadViewData()
        } else {
            fetchGraph()
        }
    }

    func selectViewData(_ viewData: LearningViewData) {
        print(viewData)
    }

    // MARK: - Private API

    private func checkAuthStatus() {
        if !AuthInfo.shared.isAuthorized {
            let params = RandomCredentialsGenerator().userRegistrationParams
            userRegistrationService.registerAndSignIn(with: params).then { user in
                self.userRegistrationService.unregisterFromEmail(user: user)
            }.done { user in
                print("Successfully register fake user with id: \(user.id)")
            }.catch { [weak self] _ in
                self?.displayError()
            }
        }
    }

    private func fetchGraph() {
        graphService.fetchGraph().done { [weak self] responseModel in
            guard let strongSelf = self,
                let graph = KnowledgeGraphBuilder(graphPlainObject: responseModel).build() as? KnowledgeGraph else {
                    return
            }

            strongSelf.knowledgeGraph.adjacency = graph.adjacency
            strongSelf.reloadViewData()
        }.catch { [weak self] _ in
            self?.displayError(
                title: NSLocalizedString("FailedFetchKnowledgeGraphErrorTitle", comment: ""),
                message: NSLocalizedString("FailedFetchKnowledgeGraphErrorMessage", comment: "")
            )
        }
    }

    private func reloadViewData() {
        if let vertices = knowledgeGraph.vertices as? [KnowledgeGraphVertex<String>] {
            view?.setViewData(toViewData(vertices))
        } else {
            displayError()
        }
    }

    private func toViewData(_ vertices: [KnowledgeGraphVertex<String>]) -> [LearningViewData] {
        return vertices.map { vertex in
            LearningViewData(
                id: vertex.id,
                title: vertex.title,
                description: "Описание того, что можем изучить и обязательно изучим в этой теме.",
                timeToComplete: "40 минут на прохождение",
                progress: "60% пройдено"
            )
        }
    }

    private func displayError(
        title: String = NSLocalizedString("Error", comment: ""),
        message: String = NSLocalizedString("ErrorMessage", comment: "")
    ) {
        view?.displayError(title: title, message: message)
    }
}
