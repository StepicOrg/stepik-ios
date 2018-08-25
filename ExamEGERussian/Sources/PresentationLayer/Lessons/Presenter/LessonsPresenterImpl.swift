//
//  LessonsPresenterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 24/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class LessonsPresenterImpl: LessonsPresenter {
    private weak var view: LessonsView?
    private let router: LessonsRouter

    private let topicId: String
    private let knowledgeGraph: KnowledgeGraph

    private var lessons = [LessonPlainObject]() {
        didSet {
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
         router: LessonsRouter,
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

    func refresh() {
        getLessons()
        joinCoursesIfNeeded()
    }

    func selectLesson(with viewData: LessonsViewData) {
        guard let lesson = topic.lessons.first(where: { $0.id == viewData.id }) else {
            return
        }

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

    // MARK: - Private API

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

    private func displayError(
        title: String = NSLocalizedString("Error", comment: ""),
        message: String = NSLocalizedString("ErrorMessage", comment: "")
    ) {
        view?.displayError(title: title, message: message)
    }
}

// MARK: - LessonsPresenterImpl (View Data) -

extension LessonsPresenterImpl {
    private func updateView() {
        let theory = lessons.map {
            LessonsViewData(
                id: $0.id,
                title: $0.title,
                subtitle: pagesCountLocalized(count: UInt($0.steps.count)),
                headerTitle: topic.title,
                headerSubtitle: "\(lessons.count) lessons"
            )
        }
        let practice = topic.lessons.filter { $0.type == .practice }.map {
            LessonsViewData(
                id: $0.id,
                title: NSLocalizedString("PracticeLessonTitle", comment: ""),
                subtitle: NSLocalizedString("PracticeLessonDescription", comment: ""),
                headerTitle: topic.title,
                headerSubtitle: "\(lessons.count) lessons"
            )
        }

        self.view?.setLessons(theory + practice)
    }

    private func pagesCountLocalized(count: UInt) -> String {
        let formatString = NSLocalizedString(
            "lesson pages count",
            comment: "Lessons pages count string format to be found in Localized.stringsdict"
        )
        let resultString = String.localizedStringWithFormat(formatString, count)

        return resultString
    }
}
