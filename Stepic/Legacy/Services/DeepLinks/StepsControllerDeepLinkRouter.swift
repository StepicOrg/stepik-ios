//
//  StepsControllerDeepLinkRouter.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

// Tip: Inherited from NSObject in order to be able to find a selector
final class StepsControllerDeepLinkRouter: NSObject {
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let courseViewSource: AnalyticsEvent.CourseViewSource

    init(
        coursesPersistenceService: CoursesPersistenceServiceProtocol = CoursesPersistenceService(),
        courseViewSource: AnalyticsEvent.CourseViewSource
    ) {
        self.coursesPersistenceService = coursesPersistenceService
        self.courseViewSource = courseViewSource
        super.init()
    }

    func getStepsViewControllerFor(
        step stepId: Int,
        inLesson lessonId: Int,
        withUnit unitID: Int?,
        success successHandler: @escaping ([UIViewController]) -> Void,
        error errorHandler: @escaping (String) -> Void
    ) {
        // Download lesson and pass stepId to StepsViewController
        if let lesson = Lesson.getLesson(lessonId) {
            ApiDataDownloader.lessons.retrieve(
                ids: [lessonId],
                existing: [lesson],
                refreshMode: .update,
                success: { lessons in
                    if let lesson = lessons.first {
                        self.getViewControllerForLesson(
                            lesson,
                            stepId: stepId,
                            includeUnit: unitID != nil,
                            success: successHandler,
                            error: errorHandler
                        )
                    } else {
                        errorHandler("Could not get lesson for deep link")
                    }
                },
                error: { error in
                    self.getViewControllerForLesson(
                        lesson,
                        stepId: stepId,
                        includeUnit: unitID != nil,
                        success: successHandler,
                        error: errorHandler
                    )
                }
            )
        } else {
            ApiDataDownloader.lessons.retrieve(
                ids: [lessonId],
                existing: [],
                refreshMode: .update,
                success: { lessons in
                    if let lesson = lessons.first {
                        self.getViewControllerForLesson(
                            lesson,
                            stepId: stepId,
                            includeUnit: unitID != nil,
                            success: successHandler,
                            error: errorHandler
                        )
                    } else {
                        errorHandler("Could not get lesson for deep link")
                    }
                },
                error: { _ in
                    errorHandler("Could not get lesson for deep link")
                }
            )
        }
    }

    private func getViewControllerForLesson(
        _ lesson: Lesson,
        stepId: Int,
        includeUnit: Bool = false,
        success successHandler: @escaping ([UIViewController]) -> Void,
        error errorHandler: @escaping (String) -> Void
    ) {
        var currentUnit: Unit?

        func fetchOrLoadUnit(for lesson: Lesson) -> Promise<Unit> {
            Promise { seal in
                if let unit = lesson.unit {
                    seal.fulfill(unit)
                    return
                }

                ApiDataDownloader.units.retrieve(
                    lesson: lesson.id,
                    success: { unit in
                        unit.lesson = lesson
                        CoreDataHelper.shared.save()

                        seal.fulfill(unit)
                    },
                    error: { err in
                        seal.reject(err)
                    }
                )
            }
        }

        func fetchOrLoadSection(for unit: Unit) -> Promise<Section> {
            Promise { seal in
                if let sections = try? Section.getSections(unit.sectionId),
                   let section = sections.first, section.courseId != 0 {
                    seal.fulfill(section)
                    return
                }

                ApiDataDownloader.sections.retrieve(
                    ids: [unit.sectionId],
                    existing: [],
                    refreshMode: .update,
                    success: { sections in
                        if let section = sections.first {
                            unit.section = section
                            CoreDataHelper.shared.save()

                            seal.fulfill(section)
                        } else {
                            seal.reject(NSError(domain: "", code: -1, userInfo: nil)) // no ideas what we should throw here...
                        }
                    },
                    error: { err in
                        seal.reject(err)
                    }
                )
            }
        }

        func fetchOrLoadCourse(for section: Section) -> Promise<Course> {
            Promise { seal in
                self.coursesPersistenceService.fetch(
                    id: section.courseId
                ).then { cachedCourseOrNil -> Promise<Course> in
                    if let course = cachedCourseOrNil {
                        return Promise.value(course)
                    }
                    return Promise { seal in
                        ApiDataDownloader.courses.retrieve(
                            ids: [section.courseId],
                            existing: [],
                            refreshMode: .update,
                            success: { courses in
                                if let course = courses.first {
                                    section.course = course
                                    CoreDataHelper.shared.save()
                                    seal.fulfill(course)
                                } else {
                                    seal.reject(NSError(domain: "", code: -1, userInfo: nil))
                                }
                            },
                            error: { error in
                                seal.reject(error)
                            }
                        )
                    }
                }.done { course in
                    seal.fulfill(course)
                }.catch { error in
                    seal.reject(error)
                }
            }
        }

        fetchOrLoadUnit(for: lesson).then { unit -> Promise<Section> in
            currentUnit = unit
            return fetchOrLoadSection(for: unit)
        }.then { section -> Promise<(Section, Course)> in
            fetchOrLoadCourse(for: section).map { (section, $0) }
        }.done { section, course in
            let hasAccess = lesson.isPublic || course.enrolled
            guard hasAccess else {
                return errorHandler("No access")
            }

            let courseInfoAssembly = CourseInfoAssembly(
                courseID: course.id,
                initialTab: .syllabus,
                courseViewSource: self.courseViewSource
            )
            let lessonAssemblyWithoutUnit = LessonAssembly(
                initialContext: .lesson(id: lesson.id),
                startStep: .index(stepId - 1)
            )

            var controllersStack: [UIViewController] = []

            if section.isExam {
                controllersStack.append(courseInfoAssembly.makeModule())
            } else if includeUnit {
                controllersStack.append(courseInfoAssembly.makeModule())

                if let unit = currentUnit {
                    let lessonAssembly = LessonAssembly(
                        initialContext: .unit(id: unit.id),
                        startStep: .index(stepId - 1)
                    )
                    controllersStack.append(lessonAssembly.makeModule())
                } else {
                    controllersStack.append(lessonAssemblyWithoutUnit.makeModule())
                }
            } else {
                controllersStack.append(lessonAssemblyWithoutUnit.makeModule())
            }

            successHandler(controllersStack)
        }.catch { error in
            errorHandler(error.localizedDescription)
        }
    }
}
