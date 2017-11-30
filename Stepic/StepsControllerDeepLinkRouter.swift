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
    func getStepsViewControllerFor(step stepId: Int, inLesson lessonId: Int, success successHandler : @escaping ((UIViewController) -> Void), error errorHandler : @escaping ((String) -> Void)) {
        //Download lesson and pass stepId to StepsViewController

        if let lesson = Lesson.getLesson(lessonId) {
            ApiDataDownloader.lessons.retrieve(ids: [lessonId], existing: [lesson], refreshMode: .update, success: {
                    lessons in
                    if let lesson = lessons.first {
                        self.getVCForLesson(lesson, stepId: stepId, success: successHandler, error: errorHandler)
                    } else {
                        errorHandler("Could not get lesson for deep link")
                    }

                }, error: {
                    error in
                    self.getVCForLesson(lesson, stepId: stepId, success: successHandler, error: errorHandler)
                }
            )
        } else {
            ApiDataDownloader.lessons.retrieve(ids: [lessonId], existing: [], refreshMode: .update, success: {
                    lessons in
                    if let lesson = lessons.first {
                        self.getVCForLesson(lesson, stepId: stepId, success: successHandler, error: errorHandler)
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

    fileprivate func getVCForLesson(_ lesson: Lesson, stepId: Int, success successHandler: @escaping ((UIViewController) -> Void), error errorHandler: @escaping ((String) -> Void)) {
        func fetchOrLoadUnit(for lesson: Lesson) -> Promise<Unit> {
            return Promise { fulfill, reject in
                if let unit = lesson.unit {
                    fulfill(unit)
                    return
                }

                ApiDataDownloader.units.retrieve(lesson: lesson.id, success: { unit in
                    unit.lesson = lesson
                    CoreDataHelper.instance.save()

                    fulfill(unit)
                }, error: { err in
                    reject(err)
                })
            }
        }

        func fetchOrLoadSection(for unit: Unit) -> Promise<Section> {
            return Promise { fulfill, reject in
                if let sections = try? Section.getSections(unit.sectionId),
                   let section = sections.first {
                    fulfill(section)
                    return
                }

                ApiDataDownloader.sections.retrieve(ids: [unit.sectionId], existing: [], refreshMode: .update, success: { sections in
                    if let section = sections.first {
                        unit.section = section
                        CoreDataHelper.instance.save()

                        fulfill(section)
                    } else {
                        reject(NSError()) // no ideas what we should throw here...
                    }
                }, error: { err in
                    reject(err)
                })
            }
        }

        func fetchOrLoadCourse(for section: Section) -> Promise<Course> {
            return Promise { fulfill, reject in
                if let course = Course.getCourses([section.courseId]).first {
                    fulfill(course)
                    return
                }

                ApiDataDownloader.courses.retrieve(ids: [section.courseId], existing: [], refreshMode: .update, success: { courses in
                    if let course = courses.first {
                        section.course = course
                        CoreDataHelper.instance.save()

                        fulfill(course)
                    } else {
                        reject(NSError())
                    }
                }, error: { err in
                    reject(err)
                })
            }
        }

        checkToken().then { _ -> Promise<Unit> in
            fetchOrLoadUnit(for: lesson)
        }.then { unit -> Promise<Section> in
            fetchOrLoadSection(for: unit)
        }.then { section -> Promise<Course> in
            fetchOrLoadCourse(for: section)
        }.then { course -> Void in
            if lesson.isPublic || course.enrolled {
                guard let lessonVC = ControllerHelper.instantiateViewController(identifier: "LessonViewController") as? LessonViewController else {
                    errorHandler("Could not instantiate controller")
                    return
                }
                lessonVC.initObjects = (lesson: lesson, startStepId: stepId - 1, context: .lesson)
                lessonVC.hidesBottomBarWhenPushed = true

                successHandler(lessonVC)
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
