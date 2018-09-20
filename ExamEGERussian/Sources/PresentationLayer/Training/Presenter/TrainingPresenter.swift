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

    private var isFirstRefresh = true

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

    // MARK: - Public API

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
        guard let graphLesson = knowledgeGraph.firstLesson(where: { $0.id == viewData.id }) else {
            return
        }

        if viewData.isPractice {
            router.showPractice(courseId: graphLesson.courseId)
        } else if let plainObject = theoryLessons.first(where: { $0.id == viewData.id }) {
            router.showTheory(lesson: plainObject)
        }

        AmplitudeAnalyticsEvents.Lesson.opened(
            id: graphLesson.id,
            type: graphLesson.type.rawValue,
            courseId: graphLesson.courseId,
            topicId: getTopicForLesson(graphLesson)?.id ?? "UNKNOWN_TOPIC_ID_FOR_LESSON_ID_\(graphLesson.id)"
        ).send()
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

    private func refreshContent() -> Promise<Void> {
        if isFirstRefresh {
            isFirstRefresh = false
            return knowledgeGraph.isEmpty ? fetchContent() : obtainContentFromCache()
        } else {
            return fetchContent()
        }
    }

    // MARK: Fetch Content

    private func fetchContent() -> Promise<Void> {
        return fetchKnowledgeGraph().then {
            self.fetchTheoryLessons()
        }.then { lessons -> Promise<Void> in
            self.theoryLessons = lessons
            return .value(())
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
        return lessonsService.fetchLessons(with: getTheoryLessonsIds())
    }

    // MARK: Obtain Content from Cache

    private func obtainContentFromCache() -> Promise<Void> {
        return obtainTheoryLessons().then { lessons -> Promise<Void> in
            self.theoryLessons = lessons
            return .value(())
        }
    }

    private func obtainTheoryLessons() -> Promise<[LessonPlainObject]> {
        let ids = getTheoryLessonsIds()
        return lessonsService.obtainLessons(with: ids).then { lessons -> Promise<[LessonPlainObject]> in
            lessons.isEmpty ? self.fetchTheoryLessons() : .value(lessons)
        }
    }

    // MARK: View Specific
    // TODO: Remove hardcoded lessons content.
    private func reloadViewData() {
        let theory = theoryLessons.map {
            TrainingViewData(
                id: $0.id,
                title: $0.title,
                description: "Описание того, что можем изучить и обязательно изучим в этой теме.",
                countLessons: $0.steps.count,
                isPractice: false
            )
        }
        let practice = getKnowledgeGraphLessons(of: .practice)
            .prefix(TrainingPresenter.lessonsLimit)
            .map {
                TrainingViewData(
                    id: $0.id,
                    title: getTopicForLesson($0)?.title ?? "",
                    description: "Краткое описание того, что происходит здесь",
                    countLessons: 1,
                    isPractice: true
                )
        }

        view?.setViewData(theory + practice)
    }

    private func displayError(
        title: String = NSLocalizedString("Error", comment: ""),
        message: String = NSLocalizedString("ErrorMessage", comment: "")
    ) {
        view?.displayError(title: title, message: message)
    }

    // MARK: Helpers

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

    private func getTopicForLesson(_ lesson: KnowledgeGraphLesson) -> KnowledgeGraph.Node? {
        for topic in knowledgeGraph.adjacencyLists.keys {
            if topic.lessons.contains(where: { $0.id == lesson.id }) {
                return topic
            }
        }

        return nil
    }

    private func getTheoryLessonsIds() -> [Int] {
        return getKnowledgeGraphLessons(of: .theory)
            .prefix(TrainingPresenter.lessonsLimit)
            .map { $0.id }
    }

    // MARK: - Types

    private enum TrainingPresenterError: Error {
        case failedRegisterUser
        case failedFetchKnowledgeGraph
    }
}
