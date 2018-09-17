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
    private static let lessonsLimit = 10

    private weak var view: TrainingView?
    private let router: TrainingRouterProtocol

    private let knowledgeGraph: KnowledgeGraph
    private var theoryLessons = [LessonPlainObject]()

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
        checkAuthStatus().then {
            self.fetchKnowledgeGraph()
        }.then {
            self.fetchTheoryLessons()
        }.then { lessons -> Promise<Void> in
            self.theoryLessons = lessons
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
                    title: NSLocalizedString("FakeUserFailedSignInTitle", comment: ""),
                    message: NSLocalizedString("FakeUserFailedSignInMessage", comment: "")
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
                seal.reject(TrainingPresenterError.failedFetchKnowledgeGraph)
            }
        }
    }

    private func fetchTheoryLessons() -> Promise<[LessonPlainObject]> {
        let ids = getKnowledgeGraphLessons(of: .theory)
            .prefix(TrainingPresenter.lessonsLimit)
            .map { $0.id }
        return lessonsService.fetchLessons(with: ids)
    }

    private func getKnowledgeGraphLessons(
        of type: KnowledgeGraphLesson.LessonType
    ) -> [KnowledgeGraphLesson] {
        var result = [KnowledgeGraphLesson]()
        knowledgeGraph.adjacencyLists.keys.forEach { topic in
            let filteredLessons = topic.lessons.filter {
                $0.type == type
            }
            result.append(contentsOf: filteredLessons)
        }

        return result
    }

    private func reloadViewData() {
        let theory = theoryLessons.map { toViewData($0, isPractice: false) }
        let practice = getKnowledgeGraphLessons(of: .practice)
            .prefix(TrainingPresenter.lessonsLimit)
            .map { LessonPlainObject(lesson: $0) }
            .map { toViewData($0, isPractice: true) }

        view?.setViewData(theory + practice)
    }

    private func toViewData(_ plainObject: LessonPlainObject, isPractice: Bool) -> TrainingViewData {
        return TrainingViewData(
            id: plainObject.id,
            title: plainObject.title,
            description: "Описание того, что можем изучить и обязательно изучим в этой теме.",
            countLessons: plainObject.steps.count,
            isPractice: isPractice
        )
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
