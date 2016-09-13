//
//  StepDeepLinkRouter.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class StepDeepLinkRouter {
    static func getStepsController(forStepId id: Int, success successHandler: (StepsViewController -> Void), error errorHandler: (String -> Void)) {
        
        let getForStepBlock : (Step -> Void) = {
            step in
            getStepsController(forStep: step, success: successHandler, error: errorHandler)
        }
        
        if let step = Step.getStepWithId(id) {
            if step.lesson != nil && step.lessonId == -1 {
                step.lessonId = step.lesson!.id
            }
            
            if step.lessonId != -1 {
                getForStepBlock(step)
                return
            }
        } 
        
        ApiDataDownloader.sharedDownloader.getStepsByIds([id], deleteSteps: [], refreshMode: .Update, success: 
            { 
                steps in
                if let step = steps.first {
                    getForStepBlock(step)
                } else {
                    errorHandler("No step with id \(id)")
                }
            }, failure: 
            {
                error in
                errorHandler("failed to get steps with id \(id)")
            }
        )
        
    }
    
    static func getStepsController(forStep step: Step, success successHandler: (StepsViewController -> Void), error errorHandler: (String -> Void)) {
        let getForLessonBlock : (Lesson -> Void) = {
            lesson in 
            getStepsController(forStep: step, lesson: lesson, success: successHandler, error: errorHandler)
        }
        if let lesson = step.lesson {
            getForLessonBlock(lesson)
            return
        }
        
        
        //TODO: Test this case. Check if additional downloads for other lesson's steps is needed.
        //Possibly, this should really be done.
        if let lesson = Lesson.getLesson(step.lessonId) {
            step.lesson = lesson
            getForLessonBlock(lesson)
            return
        }
        
        ApiDataDownloader.sharedDownloader.getLessonsByIds([step.lessonId], deleteLessons: [], refreshMode: .Update, success: 
            {
                lessons in
                if let lesson = lessons.first {
                    getForLessonBlock(lesson)
                } else {
                    errorHandler("No lesson with id \(step.lessonId)")
                }
                
            }, failure: 
            {
                error in 
                errorHandler("failed to get lesson with id \(step.lessonId)") 
            }
        )
        
    }
    
    private static func getStepsController(forStep step: Step, lesson: Lesson, success successHandler: (StepsViewController -> Void), error errorHandler: (String -> Void)) {
        
    }
}
