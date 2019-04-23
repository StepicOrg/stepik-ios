//
//  StepsControllerDeepLinkRouter.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

//Tip: Inherited from NSObject in order to be able to find a selector
class StepsControllerDeepLinkRouter: NSObject {
    func getStepsViewControllerFor(step stepId: Int, inLesson lessonId: Int, withUnit unitID: Int?, success successHandler : @escaping (([UIViewController]) -> Void), error errorHandler : @escaping ((String) -> Void)) {
        //Download lesson and pass stepId to StepsViewController

        if let lesson = Lesson.getLesson(lessonId) {
            ApiDataDownloader.lessons.retrieve(ids: [lessonId], existing: [lesson], refreshMode: .update, success: {
                    lessons in
                    if let lesson = lessons.first {
                        self.getVCForLesson(lesson, stepId: stepId, includeUnit: unitID != nil, success: successHandler, error: errorHandler)
                    } else {
                        errorHandler("Could not get lesson for deep link")
                    }

                }, error: {
                    error in
                    self.getVCForLesson(lesson, stepId: stepId, includeUnit: unitID != nil, success: successHandler, error: errorHandler)
                }
            )
        } else {
            ApiDataDownloader.lessons.retrieve(ids: [lessonId], existing: [], refreshMode: .update, success: {
                    lessons in
                    if let lesson = lessons.first {
                        self.getVCForLesson(lesson, stepId: stepId, includeUnit: unitID != nil, success: successHandler, error: errorHandler)
                    } else {
                        errorHandler("Could not get lesson for deep link")
                    }

                }, error: {
                    _ in
                    errorHandler("Could not get lesson for deep link")
                }
            )
        }
    }

    fileprivate func getVCForLesson(_ lesson: Lesson, stepId: Int, includeUnit: Bool = false, success successHandler: @escaping (([UIViewController]) -> Void), error errorHandler: @escaping ((String) -> Void)) {
        var currentUnit: Unit?

        func fetchOrLoadUnit(for lesson: Lesson) -> Promise<Unit> {
            return Promise { seal in
                if let unit = lesson.unit {
                    seal.fulfill(unit)
                    return
                }

                ApiDataDownloader.units.retrieve(lesson: lesson.id, success: { unit in
                    unit.lesson = lesson
                    CoreDataHelper.instance.save()

                    seal.fulfill(unit)
                }, error: { err in
                    seal.reject(err)
                })
            }
        }

        func fetchOrLoadSection(for unit: Unit) -> Promise<Section> {
            return Promise { seal in
                if let sections = try? Section.getSections(unit.sectionId),
                   let section = sections.first, section.courseId != 0 {
                    seal.fulfill(section)
                    return
                }

                ApiDataDownloader.sections.retrieve(ids: [unit.sectionId], existing: [], refreshMode: .update, success: { sections in
                    if let section = sections.first {
                        unit.section = section
                        CoreDataHelper.instance.save()

                        seal.fulfill(section)
                    } else {
                        seal.reject(NSError(domain: "", code: -1, userInfo: nil)) // no ideas what we should throw here...
                    }
                }, error: { err in
                    seal.reject(err)
                })
            }
        }

        func fetchOrLoadCourse(for section: Section) -> Promise<Course> {
            return Promise { seal in
                if let course = Course.getCourses([section.courseId]).first {
                    seal.fulfill(course)
                    return
                }

                ApiDataDownloader.courses.retrieve(ids: [section.courseId], existing: [], refreshMode: .update, success: { courses in
                    if let course = courses.first {
                        section.course = course
                        CoreDataHelper.instance.save()

                        seal.fulfill(course)
                    } else {
                        seal.reject(NSError(domain: "", code: -1, userInfo: nil))
                    }
                }, error: { err in
                    seal.reject(err)
                })
            }
        }

        fetchOrLoadUnit(for: lesson).then { unit -> Promise<Section> in
            currentUnit = unit
            return fetchOrLoadSection(for: unit)
        }.then { section -> Promise<Course> in
            fetchOrLoadCourse(for: section)
        }.done { course in
            if lesson.isPublic || course.enrolled {
                let lessonAssemblyWithoutUnit: Assembly = {
                    if RemoteConfig.shared.newLessonAvailable {
                        return NewLessonAssembly(initialContext: .lesson(id: lesson.id))
                    } else {
                        return LessonLegacyAssembly(
                            initObjects: (lesson: lesson, startStepId: stepId - 1, context: .lesson),
                            initIDs: nil
                        )
                    }
                }()

                var controllersStack: [UIViewController] = []
                if includeUnit {
                    controllersStack.append(CourseInfoAssembly(courseID: course.id, initialTab: .syllabus).makeModule())

                    if let unit = currentUnit {
                        let lessonAssembly: Assembly = {
                            if RemoteConfig.shared.newLessonAvailable {
                                // TODO: Pass step
                                return NewLessonAssembly(initialContext: .unit(id: unit.id))
                            } else {
                                return LessonLegacyAssembly(
                                    initObjects: nil,
                                    initIDs: (stepId: lesson.stepsArray[stepId - 1], unitId: unit.id)
                                )
                            }
                        }()

                        controllersStack.append(lessonAssembly.makeModule())
                    } else {
                        controllersStack.append(lessonAssemblyWithoutUnit.makeModule())
                    }
                } else {
                    controllersStack.append(lessonAssemblyWithoutUnit.makeModule())
                }

                successHandler(controllersStack)
            } else {
                errorHandler("No access")
            }
        }.catch { error in
            errorHandler(error.localizedDescription)
        }
    }

    var vc: UIViewController?

    func dismissPressed(_ item: UIBarButtonItem) {
        vc?.dismiss(animated: true, completion: nil)
    }
}
