//
//  LessonsPresenter.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 24/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class LessonsPresenter: LessonsPresenterProtocol {
    private weak var view: LessonsView?
    private let router: LessonsRouterProtocol

    private let topicId: String
    private let knowledgeGraph: KnowledgeGraph

    private var lessons = [LessonPlainObject]() {
        didSet {
            lessons = Array(Set(lessons))
            updateView()
        }
    }
    private var topic: KnowledgeGraphVertex<String> {
        return knowledgeGraph[topicId]!.key
    }
    private var lessonsIds: [Int] {
        return topic.lessons.map { $0.id }
    }
    private var coursesIds: [Int] {
        return topic.lessons.compactMap { Int($0.courseId) }
    }

    private let lessonsService: LessonsService
    private let courseService: CourseService

    init(view: LessonsView,
         router: LessonsRouterProtocol,
         topicId: String,
         knowledgeGraph: KnowledgeGraph,
         lessonsService: LessonsService,
         courseService: CourseService
    ) {
        self.view = view
        self.router = router
        self.topicId = topicId
        self.knowledgeGraph = knowledgeGraph
        self.lessonsService = lessonsService
        self.courseService = courseService
    }

    // MARK: LessonsPresenterProtocol

    func refresh() {
        getLessons()
        joinCoursesIfNeeded()
    }

    func selectLesson(with viewData: LessonsViewData) {
        guard let lesson = topic.lessons.first(where: { $0.id == viewData.id }) else {
            return
        }

        AmplitudeAnalyticsEvents.Lesson.opened(
            id: lesson.id,
            type: lesson.type.rawValue,
            courseId: lesson.courseId,
            topicId: getTopicForLessonWithId(lesson.id)
        ).send()

        switch lesson.type {
        case .theory:
            if let lesson = lessons.first(where: { $0.id == viewData.id }) {
                router.showTheory(lesson: lesson)
            } else {
                displayError()
            }
        case .practice:
            router.showPractice(courseId: lesson.courseId)
        }
    }
}

// MARK: - LessonsPresenterImpl (Business Logic) -

extension LessonsPresenter {
    private func joinCoursesIfNeeded() {
        guard !coursesIds.isEmpty else {
            return
        }

        courseService.joinCourses(with: coursesIds).done { courses in
            print("Successfully joined courses with ids: \(courses.map { $0.id })")
        }.catch { [weak self] _ in
            self?.displayError()
        }
    }

    private func getLessons() {
        obtainLessonsFromCache().done {
            self.fetchLessons()
        }
    }

    private func obtainLessonsFromCache() -> Guarantee<Void> {
        return Guarantee { seal in
            self.lessonsService.obtainLessons(with: self.lessonsIds).done { [weak self] lessons in
                self?.lessons = lessons
                seal(())
            }.catch { error in
                print("\(#function): \(error)")
                seal(())
            }
        }
    }

    private func fetchLessons() {
        guard lessonsIds.count > 0 else {
            return
        }

        lessonsService.fetchLessons(with: lessonsIds).done { [weak self] lessons in
            self?.lessons = lessons
        }.catch { [weak self] _ in
            self?.displayError()
        }
    }

    private func getTopicForLessonWithId(_ id: Int) -> String {
        for topic in knowledgeGraph.adjacencyLists.keys {
            if topic.lessons.contains(where: { $0.id == id }) {
                return topic.id
            }
        }

        return "UNKNOWN_TOPIC_ID_FOR_LESSON_ID_\(id)"
    }
}

// MARK: - LessonsPresenterImpl (Update View) -

extension LessonsPresenter {
    private func displayError(
        title: String = NSLocalizedString("Error", comment: ""),
        message: String = NSLocalizedString("ErrorMessage", comment: "")
    ) {
        view?.displayError(title: title, message: message)
    }

    private func updateView() {
        let theory = lessons.map {
            LessonsViewData(
                id: $0.id,
                title: $0.title,
                subtitle: pagesPluralized(count: $0.steps.count)
            )
        }
        let practice = topic.lessons.filter { $0.type == .practice }.map {
            LessonsViewData(
                id: $0.id,
                title: NSLocalizedString("PracticeLessonTitle", comment: ""),
                subtitle: NSLocalizedString("PracticeLessonDescription", comment: "")
            )
        }

        view?.setLessons(theory + practice)
        view?.updateHeader(
            title: topic.title,
            subtitle: lessonsPluralized(count: topic.lessons.count)
        )
    }

    private func lessonsPluralized(count: Int) -> String {
        let pluralizedString = StringHelper.pluralize(number: count, forms: [
            NSLocalizedString("LessonsCountText1", comment: ""),
            NSLocalizedString("LessonsCountText234", comment: ""),
            NSLocalizedString("LessonsCountText567890", comment: "")
        ])

        return String(format: pluralizedString, "\(count)")
    }

    private func pagesPluralized(count: Int) -> String {
        let pluralizedString = StringHelper.pluralize(number: count, forms: [
            NSLocalizedString("PagesCountText1", comment: ""),
            NSLocalizedString("PagesCountText234", comment: ""),
            NSLocalizedString("PagesCountText567890", comment: "")
        ])

        return String(format: pluralizedString, "\(count)")
    }
}
