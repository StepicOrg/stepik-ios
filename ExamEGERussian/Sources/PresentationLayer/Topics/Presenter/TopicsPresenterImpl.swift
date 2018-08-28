//
//  TopicsPresenterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class TopicsPresenterImpl: TopicsPresenter {
    private weak var view: TopicsView?
    private let router: TopicsRouter

    private let knowledgeGraph: KnowledgeGraph

    private let userRegistrationService: UserRegistrationService
    private let graphService: GraphServiceProtocol

    private var isFirstRefresh = true

    init(view: TopicsView,
         knowledgeGraph: KnowledgeGraph,
         router: TopicsRouter,
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

    func selectTopic(with viewData: TopicsViewData) {
        guard let topic = knowledgeGraph[viewData.id]?.key else {
            return
        }

        router.showLessonsForTopicWithId(topic.id)
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
            self?.displayError()
        }
    }

    private func reloadViewData() {
        if let vertices = knowledgeGraph.vertices as? [KnowledgeGraphVertex<String>] {
            view?.setTopics(viewTopicsFrom(vertices))
        } else {
            displayError()
        }
    }

    private func displayError(
        title: String = NSLocalizedString("Error", comment: ""),
        message: String = NSLocalizedString("ErrorMessage", comment: "")
    ) {
        view?.displayError(title: title, message: message)
    }

    private func viewTopicsFrom(_ vertices: [KnowledgeGraphVertex<String>]) -> [TopicsViewData] {
        return vertices.map { viewTopicFromVertex($0) }
    }

    private func viewTopicFromVertex(_ vertex: KnowledgeGraphVertex<String>) -> TopicsViewData {
        return TopicsViewData(id: vertex.id, title: vertex.title)
    }
}
