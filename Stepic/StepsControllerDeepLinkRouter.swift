//
//  StepsControllerDeepLinkRouter.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation


//Tip: Inherited from NSObject in order to be able to find a selector
class StepsControllerDeepLinkRouter : NSObject {
    func getStepsViewControllerFor(step stepId: Int, inLesson lessonId: Int, success successHandler : @escaping ((UIViewController) -> Void), error errorHandler : @escaping ((String) -> Void)) {
        //Download lesson and pass stepId to StepsViewController
        
        if let lesson = Lesson.getLesson(lessonId) {        
            ApiDataDownloader.sharedDownloader.getLessonsByIds([lessonId], deleteLessons: [lesson], refreshMode: .update, success: 
                {
                    lessons in
                    if let lesson = lessons.first {
                        self.getVCForLesson(lesson, stepId: stepId, success: successHandler, error: errorHandler)
                    } else {
                        errorHandler("Could not get lesson for deep link")
                    }
                
                }, failure: 
                {
                    error in 
                    self.getVCForLesson(lesson, stepId: stepId, success: successHandler, error: errorHandler)
                }
            )
        } else {
            ApiDataDownloader.sharedDownloader.getLessonsByIds([lessonId], deleteLessons: [], refreshMode: .update, success: 
                {
                    lessons in
                    if let lesson = lessons.first {
                        self.getVCForLesson(lesson, stepId: stepId, success: successHandler, error: errorHandler)
                    } else {
                        errorHandler("Could not get lesson for deep link")
                    }
                    
                }, failure: 
                {
                    error in 
                    errorHandler("Could not get lesson for deep link")
                }
            )
        }
    }
    
    fileprivate func getVCForLesson(_ lesson: Lesson, stepId: Int, success successHandler : ((UIViewController) -> Void), error errorHandler : ((String) -> Void)) {
        let enrolled = lesson.unit?.section.course?.enrolled ?? false
        if lesson.isPublic || enrolled {
            guard let stepsVC = ControllerHelper.instantiateViewController(identifier: "StepsViewController") as? StepsViewController else {
                errorHandler("Could not instantiate controller")
                return
            }
            stepsVC.startStepId = stepId - 1
            stepsVC.lesson = lesson
            stepsVC.context = .lesson
            stepsVC.hidesBottomBarWhenPushed = true
//            let navigation : UINavigationController = GreenNavigationViewController(rootViewController: stepsVC)
//            navigation.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(image: Images.crossBarButtonItemImage, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(StepsControllerDeepLinkRouter.dismissPressed(_:)))
//            navigation.navigationBar.topItem?.leftBarButtonItem?.tintColor = UIColor.whiteColor()

            successHandler(stepsVC)
        } else {
            errorHandler("No access")
        }
    }
    
    var vc : UIViewController?
    
    func dismissPressed(_ item: UIBarButtonItem) {
        vc?.dismiss(animated: true, completion: nil)
    }
}
