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
        guard let lesson = knowledgeGraph.firstLesson(where: { $0.id == viewData.id }) else {
            return
        }

        if viewData.isPractice {
            router.showPractice(courseId: lesson.courseId)
        } else if let plainObject = theoryLessons.first(where: { $0.id == viewData.id }) {
            router.showTheory(lesson: plainObject)
        }

        AmplitudeAnalyticsEvents.Lesson.opened(
            id: lesson.id,
            type: lesson.type.rawValue,
            courseId: lesson.courseId,
            topicId: getTopicForLessonId(lesson.id)?.id ?? "UNKNOWN_TOPIC_ID_FOR_LESSON_ID_\(lesson.id)"
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

    // MARK: - Types

    private enum TrainingPresenterError: Error {
        case failedRegisterUser
        case failedFetchKnowledgeGraph
    }
}

// MARK: - TrainingPresenter (Content) -

extension TrainingPresenter {
    private func refreshContent() -> Promise<Void> {
        if isFirstRefresh {
            isFirstRefresh = false
            return knowledgeGraph.isEmpty ? fetchContent() : obtainContentFromCache()
        } else {
            return fetchContent()
        }
    }

    // MARK: Fetch

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

    // MARK: Cache

    private func obtainContentFromCache() -> Promise<Void> {
        return obtainTheoryLessons().then { lessons -> Promise<Void> in
            self.theoryLessons = lessons
            return .value(())
        }
    }

    private func obtainTheoryLessons() -> Promise<[LessonPlainObject]> {
        let ids = getTheoryLessonsIds()
        return lessonsService.obtainLessons(with: ids).then { lessons in
            lessons.isEmpty ? self.fetchTheoryLessons() : .value(lessons)
        }
    }

    // MARK: Helpers

    private func getTopicForLessonId(_ id: Int) -> KnowledgeGraph.Node? {
        return knowledgeGraph.firstVertex { vertex in
            vertex.lessons.contains(where: { $0.id == id })
        }
    }

    private func getTheoryLessonsIds() -> [Int] {
        return knowledgeGraph
            .filterLessons({ $0.type == .theory })
            .prefix(TrainingPresenter.lessonsLimit)
            .map { $0.id }
    }
}

// MARK: - TrainingPresenter (View) -

extension TrainingPresenter {
    private func reloadViewData() {
        func resolveColorsForLessonId(_ id: Int) -> [UIColor] {
            guard let topic = getTopicForLessonId(id) else {
                return GradientColorsResolver.resolve(id)
            }

            return GradientColorsResolver.resolve(topic.id)
        }

        let theory = theoryLessons
            .sorted(by: { $0.id < $1.id })
            .map({
                TrainingViewData(
                    id: $0.id,
                    title: $0.title,
                    // TODO: Remove hardcoded lessons content.
                    description: "Описание того, что можем изучить и обязательно изучим в этой теме.",
                    countLessons: $0.steps.count,
                    isPractice: false,
                    colors: resolveColorsForLessonId($0.id)
                )
            })

        let practice = knowledgeGraph
            .filterLessons({ $0.type == .practice })
            .prefix(TrainingPresenter.lessonsLimit)
            .sorted(by: { (lhs: KnowledgeGraphLesson, rhs: KnowledgeGraphLesson) in
                lhs.id < rhs.id
            })
            .map({
                TrainingViewData(
                    id: $0.id,
                    title: getTopicForLessonId($0.id)?.title ?? "",
                    // TODO: Remove hardcoded lessons content.
                    description: "Краткое описание того, что происходит здесь",
                    countLessons: 1,
                    isPractice: true,
                    colors: resolveColorsForLessonId($0.id)
                )
            })

        view?.setViewData(theory + practice)
    }

    private func displayError(
        title: String = NSLocalizedString("Error", comment: ""),
        message: String = NSLocalizedString("ErrorMessage", comment: "")
    ) {
        view?.displayError(title: title, message: message)
    }
}
