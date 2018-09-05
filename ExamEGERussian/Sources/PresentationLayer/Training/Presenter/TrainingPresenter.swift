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
    private static let lessonsLimit = 20

    private weak var view: TrainingView?
    private let router: TrainingRouterProtocol

    private let knowledgeGraph: KnowledgeGraph
    private var lessons = [LessonPlainObject]()

    private let userRegistrationService: UserRegistrationService
    private let graphService: GraphServiceProtocol
    private let lessonsService: LessonsService

    init(view: TrainingView,
         knowledgeGraph: KnowledgeGraph,
         router: TrainingRouterProtocol,
         userRegistrationService: UserRegistrationService,
         graphService: GraphServiceProtocol,
         lessonsService: LessonsService
    ) {
        self.view = view
        self.knowledgeGraph = knowledgeGraph
        self.router = router
        self.userRegistrationService = userRegistrationService
        self.graphService = graphService
        self.lessonsService = lessonsService
    }

    func refresh() {
        checkAuthStatus().then { _ in
            self.fetchGraph()
        }.then { _ in
            self.fetchLessons()
        }.then { lessons -> Promise<Void> in
            self.lessons = lessons
            return .value(())
        }.done {
            self.reloadViewData()
        }.catch { [weak self] error in
            switch error {
            case TrainingPresenterError.failedFetchKnowledgeGraph:
                self?.displayError(
                    title: NSLocalizedString("FailedFetchKnowledgeGraphErrorTitle", comment: ""),
                    message: NSLocalizedString("FailedFetchKnowledgeGraphErrorMessage", comment: "")
                )
            case TrainingPresenterError.failedRegisterUser:
                self?.displayError(
                    title: "Unable to register",
                    message: "Please, try again later. Pull down to refresh screen."
                )
            default:
                self?.displayError()
            }
        }
    }

    func selectViewData(_ viewData: TrainingViewData) {
        if viewData.isPractice {
            router.showPractice(courseId: "courseId")
        } else {
            //router.showTheory(lesson: )
        }
    }

    func signIn() {
        router.showAuth()
    }

    func logout() {
        AuthInfo.shared.token = nil
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
                print("Failed register user: \(error)")
                seal.reject(TrainingPresenterError.failedRegisterUser)
            }
        }
    }

    private func fetchGraph() -> Promise<Void> {
        return Promise { seal in
            graphService.fetchGraph().done { [weak self] responseModel in
                guard let strongSelf = self,
                      let graph = KnowledgeGraphBuilder(graphPlainObject: responseModel).build() as? KnowledgeGraph else {
                    return
                }

                strongSelf.knowledgeGraph.adjacency = graph.adjacency
                strongSelf.reloadViewData()

                seal.fulfill(())
            }.catch { _ in
                seal.reject(TrainingPresenterError.failedFetchKnowledgeGraph)
            }
        }
    }

    private func fetchLessons() -> Promise<[LessonPlainObject]> {
        let lessonsIds = knowledgeGraph.adjacencyLists.keys.reduce([]) { (result, vertex) in
            result + vertex.lessons.map { $0.id }
        }
        let lessonsToFetch = Set(lessonsIds).prefix(TrainingPresenter.lessonsLimit)

        return lessonsService.fetchLessons(with: Array(lessonsToFetch))
    }

    private func reloadViewData() {
        let viewData = lessons.map { lesson in
            TrainingViewData(
                id: lesson.id,
                title: lesson.title,
                description: "Описание того, что можем изучить и обязательно изучим в этой теме.",
                countLessons: lesson.steps.count,
                isPractice: false
            )
        }

        view?.setViewData(viewData)
    }

    private func displayError(
        title: String = NSLocalizedString("Error", comment: ""),
        message: String = NSLocalizedString("ErrorMessage", comment: "")
    ) {
        view?.displayError(title: title, message: message)
    }

    private enum TrainingPresenterError: Error {
        case failedRegisterUser
        case failedFetchKnowledgeGraph
    }
}
