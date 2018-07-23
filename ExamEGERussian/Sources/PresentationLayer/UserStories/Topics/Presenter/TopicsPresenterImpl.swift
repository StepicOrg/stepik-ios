//
//  TopicsPresenterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class TopicsPresenterImpl: TopicsPresenter {

    private weak var view: TopicsView?
    private var graph: KnowledgeGraph
    private let userRegistrationService: UserRegistrationService
    private let graphService: GraphService

    init(view: TopicsView, model: KnowledgeGraph,
         userRegistrationService: UserRegistrationService, graphService: GraphService) {
        self.view = view
        self.graph = model
        self.userRegistrationService = userRegistrationService
        self.graphService = graphService
    }

    func refresh() {
        checkAuthStatus()
        fetchGraphData()
    }

    // MARK: - Private API

    private func checkAuthStatus() {
        if !AuthInfo.shared.isAuthorized {
            userRegistrationService.registerNewUser().done {
                print("Successfully register user with id: \($0.id)")
            }.catch { [weak self] error in
                self?.displayError(error)
            }
        }
    }

    private func fetchGraphData() {
        graphService.obtainGraph().done { [weak self] responseModel in
            guard let `self` = self else { return }
            let builder = KnowledgeGraphBuilder(graphPlainObject: responseModel)
            guard let graph = builder.build() as? KnowledgeGraph else { return }
            self.graph = graph

            let vertices = graph.vertices as! [KnowledgeGraphVertex<String>]
            self.view?.setTopics(self.viewTopicsFrom(vertices))
        }.catch { [weak self] error in
            self?.displayError(error)
        }
    }

    private func displayError(_ error: Swift.Error) {
        view?.displayError(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription)
    }

    private func showLessons<T>(_ vertex: KnowledgeGraphVertex<T>) {
        print("\(#function) for: \(vertex.title)")
    }

    private func viewTopicsFrom<T>(_ vertices: [KnowledgeGraphVertex<T>]) -> [TopicsViewData] {
        return vertices.map { viewTopicFromVertex($0) }
    }

    private func viewTopicFromVertex<T>(_ vertex: KnowledgeGraphVertex<T>) -> TopicsViewData {
        return TopicsViewData(
            title: vertex.title,
            onTap: { [weak self] in
                self?.showLessons(vertex)
            }
        )
    }
}
