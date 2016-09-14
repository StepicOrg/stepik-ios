//
//  StepDeepLinkRouter.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class StepDeepLinkRouter {
    
    //Getting step here
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
    
    //Getting lesson here
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
            step.lesson = lesson //Maybe it's a bad thing
            getForLessonBlock(lesson)
            return
        }
        
        ApiDataDownloader.sharedDownloader.getLessonsByIds([step.lessonId], deleteLessons: [], refreshMode: .Update, success: 
            {
                lessons in
                if let lesson = lessons.first {
                    step.lesson = lesson //Maybe it's a bad thing
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
    
    //Getting unit here. 
    private static func getStepsController(forStep step: Step, lesson: Lesson, success successHandler: (StepsViewController -> Void), error errorHandler: (String -> Void)) {
        
        let getForUnitBlock : (Unit -> Void) = {
            unit in 
        }
        
        
        //Lesson has unit, everything is OK
        if let unit = lesson.unit {
            getForUnitBlock(unit)
            return
        }
        
        //Check, if there is a unit for this lesson
        ApiDataDownloader.units.retrieve(lesson: lesson.id, success: 
            {
                unit in
                // there is a unit for lesson
                unit.lesson = lesson
                getForUnitBlock(unit)
                return
            }, error: 
            {
                error in
                switch error {
                case .NoUnits:
                    //Handle the case, when there are no units
                    getStepsControllerForLessonContext(step, lesson: lesson, success: successHandler, error: errorHandler)
                    break
                default:
                    errorHandler("Could not retrieve unit")
                }
            }
        )
    }
    
    //Looking for assignments
    private static func getStepsController(forStep step: Step, lesson: Lesson, unit: Unit, success successHandler: (StepsViewController -> Void), error errorHandler: (String -> Void)) {
        
        //Check, if cached assignments contain nil progresses
//        unit.assignments.contains({$0.})
        
        ApiDataDownloader.sharedDownloader.getAssignmentsByIds(unit.assignmentsArray, deleteAssignments: unit.assignments, refreshMode: .Update, success: {
            newAssignments in 
            
            if newAssignments.count == 0 {
                getStepsControllerForLessonContext(step, lesson: lesson, success: successHandler, error: errorHandler)
                return
            }
            unit.assignments = Sorter.sort(newAssignments, byIds: unit.assignmentsArray)
            
            getStepsControllerForUnitContext() 
            return
            
            }, failure: {
                error in
                errorHandler("Error while downloading assignments")
        })

        
    }
    
    //Define this method's signature later
    private static func getStepsControllerForLessonContext(step: Step, lesson: Lesson, success successHandler: (StepsViewController -> Void), error errorHandler: (String -> Void)) {
        
        guard let vc = ControllerHelper.instantiateViewController(identifier: "StepsViewController") as? StepsViewController else {
            errorHandler("Could not instantiate controller")
            return
        }
        
        vc.hidesBottomBarWhenPushed = true
        let step = step
        vc.context = .Lesson
        vc.lesson = lesson
        
        //TODO: Check if it is better to do it using stepsArray
        vc.startStepId = step.lesson?.steps.indexOf(step)
        successHandler(vc)
    }
    
    //Define this method's signature later
    private static func getStepsControllerForUnitContext(step: Step, lesson: Lesson, unit: Unit, success successHandler: (StepsViewController -> Void), error errorHandler: (String -> Void)) {
        guard let vc = ControllerHelper.instantiateViewController(identifier: "StepsViewController") as? StepsViewController else {
            errorHandler("Could not instantiate controller")
            return
        }
        
        vc.hidesBottomBarWhenPushed = true
        let step = step
        vc.context = .Lesson
        vc.lesson = lesson
        //TODO: Add assignment here
        //TODO: Check if it is better to do it using stepsArray
        vc.startStepId = step.lesson?.steps.indexOf(step)
        successHandler(vc)
    }

}
