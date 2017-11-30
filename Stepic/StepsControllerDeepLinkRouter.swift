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
        func fetchOrLoadUnit(lesson: Lesson) -> Promise<Unit> {
            return Promise { resolve, reject in
                if let unit = lesson.unit {
                    resolve(unit)
                    return
                }

                ApiDataDownloader.units.retrieve(lesson: lesson.id, success: { unit in
                    resolve(unit)
                }, error: { err in
                    reject(err)
                })
            }
        }

        func fetchOrLoadSection(_ id: Int) -> Promise<Section> {
            return Promise { resolve, reject in
                if let sections = try? Section.getSections(id),
                   let section = sections.first {
                    resolve(section)
                    return
                }

                ApiDataDownloader.sections.retrieve(ids: [id], existing: [], refreshMode: .update, success: { sections in
                    if let section = sections.first {
                        resolve(section)
                    } else {
                        reject(NSError()) // no ideas what we should throw here...
                    }
                }, error: { err in
                    reject(err)
                })
            }
        }

        func fetchOrLoadCourse(_ id: Int) -> Promise<Course> {
            return Promise { resolve, reject in
                if let course = Course.getCourses([id]).first {
                    resolve(course)
                    return
                }

                ApiDataDownloader.courses.retrieve(ids: [id], existing: [], refreshMode: .update, success: { courses in
                    if let course = courses.first {
                        resolve(course)
                    } else {
                        reject(NSError())
                    }
                }, error: { err in
                    reject(err)
                })
            }
        }

        checkToken().then { () -> Promise<Unit> in
            fetchOrLoadUnit(lesson: lesson)
        }.then { unit -> Promise<Section> in
            fetchOrLoadSection(unit.sectionId)
        }.then { section -> Promise<Course> in
            fetchOrLoadCourse(section.courseId)
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
