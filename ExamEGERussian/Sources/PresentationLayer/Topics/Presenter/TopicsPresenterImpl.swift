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
    private var graph: KnowledgeGraph

    private let userRegistrationService: UserRegistrationService
    private let graphService: GraphService

    init(view: TopicsView, model: KnowledgeGraph, router: TopicsRouter,
         userRegistrationService: UserRegistrationService, graphService: GraphService) {
        self.view = view
        self.graph = model
        self.router = router
        self.userRegistrationService = userRegistrationService
        self.graphService = graphService
    }

    func refresh() {
        checkAuthStatus()
        fetchGraphData()
    }

    func selectTopic(with viewData: TopicsViewData) {
        guard let topic = graph[viewData.id]?.key else {
            return
        }
        showLessons(for: topic)
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
            userRegistrationService.registerAndSignIn(with: params).then { [unowned self] user in
                self.userRegistrationService.unregisterFromEmail(user: user)
            }.done { user in
                print("Successfully register fake user with id: \(user.id)")
            }.catch { [weak self] error in
                self?.displayError(error)
            }
        }
    }

    private func fetchGraphData() {
        graphService.obtainGraph().done { [weak self] responseModel in
            guard let `self` = self else { return }
            let builder = KnowledgeGraphBuilder(graphPlainObject: responseModel)
            guard let graph = builder.build() as? KnowledgeGraph,
                  let vertices = graph.vertices as? [KnowledgeGraphVertex<String>] else {
                return
            }

            self.graph = graph
            self.view?.setTopics(self.viewTopicsFrom(vertices))
        }.catch { [weak self] error in
            self?.displayError(error)
        }
    }

    private func displayError(_ error: Swift.Error) {
        view?.displayError(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription)
    }

    private func showLessons<T>(for vertex: KnowledgeGraphVertex<T>) {
        print("\(#function) \(vertex.title)")
    }

    private func viewTopicsFrom(_ vertices: [KnowledgeGraphVertex<String>]) -> [TopicsViewData] {
        return vertices.map { viewTopicFromVertex($0) }
    }

    private func viewTopicFromVertex(_ vertex: KnowledgeGraphVertex<String>) -> TopicsViewData {
        return TopicsViewData(id: vertex.id, title: vertex.title)
    }
}
