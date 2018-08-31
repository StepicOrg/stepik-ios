//
//  TrainingPresenter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class TrainingPresenter: TrainingPresenterProtocol {
    private weak var view: TrainingView?
    private let router: TrainingRouterProtocol

    private let knowledgeGraph: KnowledgeGraph

    private let userRegistrationService: UserRegistrationService
    private let graphService: GraphServiceProtocol

    private var isFirstRefresh = true

    init(view: TrainingView,
         knowledgeGraph: KnowledgeGraph,
         router: TrainingRouterProtocol,
         userRegistrationService: UserRegistrationService,
         graphService: GraphServiceProtocol
    ) {
        self.view = view
        self.knowledgeGraph = knowledgeGraph
        self.router = router
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

    func selectTopic(_ topic: TopicPlainObject) {
        switch topic.type {
        case .theory:
            router.showLessonsForTopicWithId(topic.id)
        case .practice:
            router.showAdaptiveForTopicWithId(topic.id)
        }
    }

    func signIn() {
        router.showAuth()
    }

    func logout() {
        AuthInfo.shared.token = nil
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

            // TODO: Write changes to cache.
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
            view?.setTopics(toPlainObjects(vertices))
        } else {
            displayError()
        }
    }

    private func toPlainObjects(_ vertices: [KnowledgeGraphVertex<String>]) -> [TopicPlainObject] {
        return vertices.map {
            TopicPlainObject(
                id: $0.id,
                title: $0.title,
                description: "Описание того, что можем изучить и обязательно изучим в этой теме.",
                progress: 60.0,
                type: $0.containsPractice ? .practice : .theory,
                timeToComplete: 40,
                lessons: $0.lessons.map { LessonPlainObject(lesson: $0) }
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
