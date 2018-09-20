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
    private let router: LearningRouterProtocol

    private let knowledgeGraph: KnowledgeGraph

    private let userRegistrationService: UserRegistrationService
    private let graphService: GraphServiceProtocol

    private var isFirstRefresh = true

    init(view: LearningView,
         router: LearningRouterProtocol,
         knowledgeGraph: KnowledgeGraph,
         userRegistrationService: UserRegistrationService,
         graphService: GraphServiceProtocol
    ) {
        self.view = view
        self.router = router
        self.knowledgeGraph = knowledgeGraph
        self.userRegistrationService = userRegistrationService
        self.graphService = graphService
    }

    func refresh() {
        view?.state = .fetching

        checkAuthStatus().then {
            self.refreshContent()
        }.done {
            self.reloadViewData()
        }.ensure {
            self.view?.state = .idle
        }.catch { [weak self] error in
            switch error {
            case is NetworkError:
                self?.displayError(
                    title: NSLocalizedString("ConnectionErrorTitle", comment: ""),
                    message: NSLocalizedString("ConnectionErrorSubtitle", comment: "")
                )
            case LearningPresenterError.failedFetchKnowledgeGraph:
                self?.displayError(
                    title: NSLocalizedString("FailedFetchKnowledgeGraphErrorTitle", comment: ""),
                    message: NSLocalizedString("FailedFetchKnowledgeGraphErrorMessage", comment: "")
                )
            case LearningPresenterError.failedRegisterUser:
                self?.displayError(
                    title: NSLocalizedString("FakeUserFailedSignInTitle", comment: ""),
                    message: NSLocalizedString("FakeUserFailedSignInMessage", comment: "")
                )
            default:
                self?.displayError()
            }
        }
    }

    func selectViewData(_ viewData: LearningViewData) {
        AmplitudeAnalyticsEvents.Topic.opened(
            id: viewData.id,
            title: viewData.title
        ).send()

        router.showLessons(topicId: viewData.id)
    }

    // MARK: - Private API

    private func checkAuthStatus() -> Promise<Void> {
        if AuthInfo.shared.isAuthorized {
            return .value(())
        }

        return Promise { seal in
            let params = RandomCredentialsGenerator().userRegistrationParams
            userRegistrationService.registerAndSignIn(with: params).then { user in
                self.userRegistrationService.unregisterFromEmail(user: user)
            }.done { user in
                print("Successfully register fake user with id: \(user.id)")
                seal.fulfill(())
            }.catch { error in
                print("Failed to register user: \(error)")
                seal.reject(LearningPresenterError.failedRegisterUser)
            }
        }
    }

    private func refreshContent() -> Promise<Void> {
        if isFirstRefresh {
            isFirstRefresh = false
            return knowledgeGraph.isEmpty ? fetchKnowledgeGraph() : .value(())
        } else {
            return fetchKnowledgeGraph()
        }
    }

    private func fetchKnowledgeGraph() -> Promise<Void> {
        return Promise { seal in
            graphService.fetchGraph().done { [weak self] responseModel in
                guard let strongSelf = self,
                      let graph = KnowledgeGraphBuilder(graphPlainObject: responseModel).build() as? KnowledgeGraph else {
                    return
                }

                strongSelf.knowledgeGraph.adjacency = graph.adjacency
                seal.fulfill(())
            }.catch { error in
                print("Failed fetch knowledge graph: \(error)")
                seal.reject(LearningPresenterError.failedFetchKnowledgeGraph)
            }
        }
    }

    private func reloadViewData() {
        if let vertices = knowledgeGraph.vertices as? [KnowledgeGraphVertex<String>] {
            view?.setViewData(verticesToViewData(vertices))
        } else {
            displayError()
        }
    }

    // TODO: Replace with real topic content.
    private func verticesToViewData(_ vertices: [KnowledgeGraphVertex<String>]) -> [LearningViewData] {
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

    // MARK: - Types

    private enum LearningPresenterError: Error {
        case failedRegisterUser
        case failedFetchKnowledgeGraph
    }
}
