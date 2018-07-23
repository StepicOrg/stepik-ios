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

    private let userRegistrationService: UserRegistrationService
    private let graphService: GraphService

    private var graph: KnowledgeGraph {
        didSet {
            self.view?.refreshTopicsView()
        }
    }

    var numberOfTopics: Int {
        return graph.count
    }

    init(view: TopicsView, model: KnowledgeGraph,
         userRegistrationService: UserRegistrationService, graphService: GraphService) {
        self.view = view
        self.graph = model
        self.userRegistrationService = userRegistrationService
        self.graphService = graphService
    }

    func viewDidLoad() {
        checkAuthStatus()
        fetchGraphData()
    }

    func configure(cell: TopicCellView, forRow row: Int) {
        cell.display(title: graph[row].key.title)
    }

    func didSelect(row: Int) {
        print("\(#function) row: \(row)")
    }

    func didPullToRefresh() {
        fetchGraphData()
    }

    func titleForScene() -> String {
        return "Topics".localized
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
        graphService.obtainGraph { [weak self] result in
            switch result {
            case .success(let responseModel):
                let builder = KnowledgeGraphBuilder(graphPlainObject: responseModel)
                guard let graph = builder.build() as? KnowledgeGraph else { return }
                self?.graph = graph
            case .failure(let error):
                self?.displayError(error)
            }
        }
    }

    private func displayError(_ error: Swift.Error) {
        view?.displayError(title: "Error".localized, message: error.localizedDescription)
    }
}
