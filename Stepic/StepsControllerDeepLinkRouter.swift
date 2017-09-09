//
//  StepsControllerDeepLinkRouter.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

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

    fileprivate func getVCForLesson(_ lesson: Lesson, stepId: Int, success successHandler: ((UIViewController) -> Void), error errorHandler: ((String) -> Void)) {
        let enrolled = lesson.unit?.section?.course?.enrolled ?? false
        if lesson.isPublic || enrolled {
            guard let lessonVC = ControllerHelper.instantiateViewController(identifier: "LessonViewController") as? LessonViewController else {
                errorHandler("Could not instantiate controller")
                return
            }
            lessonVC.initObjects = (lesson: lesson, startStepId: stepId - 1, context: .lesson)
            lessonVC.hidesBottomBarWhenPushed = true
//            let navigation : UINavigationController = StyledNavigationViewController(rootViewController: stepsVC)
//            navigation.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(image: Images.crossBarButtonItemImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(StepsControllerDeepLinkRouter.dismissPressed(_:)))
//            navigation.navigationBar.topItem?.leftBarButtonItem?.tintColor = UIColor.whiteColor()

            successHandler(lessonVC)
        } else {
            errorHandler("No access")
        }
    }

    var vc: UIViewController?

    func dismissPressed(_ item: UIBarButtonItem) {
        vc?.dismiss(animated: true, completion: nil)
    }
}
