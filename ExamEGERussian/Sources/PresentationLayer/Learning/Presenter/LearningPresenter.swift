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
    private var progressMap = [KnowledgeGraph.Node: Double]()

    private let userRegistrationService: UserRegistrationService
    private let graphService: GraphServiceProtocol
    private let lessonsService: LessonsService
    private let stepsService: StepsService
    private let courseService: CourseService

    private var isFirstRefresh = true

    init(view: LearningView,
         router: LearningRouterProtocol,
         knowledgeGraph: KnowledgeGraph,
         userRegistrationService: UserRegistrationService,
         graphService: GraphServiceProtocol,
         lessonsService: LessonsService,
         stepsService: StepsService,
         courseService: CourseService
    ) {
        self.view = view
        self.router = router
        self.knowledgeGraph = knowledgeGraph
        self.userRegistrationService = userRegistrationService
        self.graphService = graphService
        self.lessonsService = lessonsService
        self.stepsService = stepsService
        self.courseService = courseService
    }

    func refresh() {
        view?.state = .fetching

        checkAuthStatus().then {
            self.refreshContent()
        }.then {
            self.joinCoursesIfNeeded()
        }.done {
            self.reloadViewData()
            self.fetchProgresses().done {
                self.reloadViewData()
            }
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

    private func joinCoursesIfNeeded() -> Promise<Void> {
        var coursesIds = Set<Int>()

        knowledgeGraph.adjacencyLists.keys.forEach { topic in
            topic.lessons.compactMap {
                Int($0.courseId)
            }.forEach {
                coursesIds.insert($0)
            }
        }

        return Promise { seal in
            courseService.joinCourses(with: Array(coursesIds)).done { courses in
                print("Successfully joined courses with ids: \(courses.map { $0.id })")
                seal.fulfill(())
            }.catch {
                seal.reject($0)
            }
        }
    }

    private func fetchProgresses() -> Guarantee<Void> {
        let topics = Array(knowledgeGraph.adjacencyLists.keys)
        let lessonsIds = topics.map { topic in
            topic.lessons.filter { $0.type == .theory }.map { $0.id }
        }
        let progressesToFetch = lessonsIds.map {
            lessonsService.fetchProgresses(ids: $0, stepsService: stepsService)
        }

        return Guarantee { seal in
            when(fulfilled: progressesToFetch).done { progresses in
                for (index, lessonsProgresses) in progresses.enumerated() {
                    self.progressMap[topics[index]] = self.computeTopicProgress(
                        lessonsProgresses: lessonsProgresses
                    )
                }

                print("Successfully fetched progresses for topics")
                seal(())
            }.catch { error in
                print("Failed fetch progresses for topics with error: \(error)")
                seal(())
            }
        }
    }

    private func computeTopicProgress(lessonsProgresses: [Double]) -> Double {
        let maxPercentForEachLesson = 100.0 / Double(lessonsProgresses.count)
        return lessonsProgresses.reduce(0.0) { (result, lessonProgress) in
            result + (maxPercentForEachLesson * lessonProgress)
        }
    }

    private func reloadViewData() {
        if let vertices = knowledgeGraph.vertices as? [KnowledgeGraph.Node] {
            view?.setViewData(verticesToViewData(vertices))
        } else {
            displayError()
        }
    }

    // TODO: Replace `timeToComplete` with real value.
    private func verticesToViewData(_ vertices: [KnowledgeGraph.Node]) -> [LearningViewData] {
        func getProgress(for vertex: KnowledgeGraph.Node) -> String {
            var progress = Int(progressMap[vertex, default: 0].rounded())
            progress = min(progress, 100)
            return "\(progress)% пройдено"
        }

        return vertices.map { vertex in
            LearningViewData(
                id: vertex.id,
                title: vertex.title,
                description: "Описание того, что можем изучить и обязательно изучим в этой теме.",
                timeToComplete: "40 минут на прохождение",
                progress: getProgress(for: vertex)
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
