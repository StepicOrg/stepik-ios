//
//  StepsControllerRouter.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class StepsControllerRouter {
    
    //Getting step here
    static func getStepsController(forStepId id: Int, success successHandler: @escaping ((StepsViewController) -> Void), error errorHandler: @escaping ((String) -> Void)) {
        
        let getForStepBlock : ((Step) -> Void) = {
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
        
        ApiDataDownloader.steps.retrieve(ids: [id], existing: [], refreshMode: .update, success: 
            { 
                steps in
                if let step = steps.first {
                    getForStepBlock(step)
                } else {
                    errorHandler("No step with id \(id)")
                }
            }, error: 
            {
                error in
                errorHandler("failed to get steps with id \(id)")
            }
        )
        
    }
    
    //Getting lesson here
    static func getStepsController(forStep step: Step, success successHandler: @escaping ((StepsViewController) -> Void), error errorHandler: @escaping ((String) -> Void)) {
        let getForLessonBlock : ((Lesson) -> Void) = {
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
        
        ApiDataDownloader.lessons.retrieve(ids: [step.lessonId], existing: [], refreshMode: .update, success: 
            {
                lessons in
                if let lesson = lessons.first {
                    step.lesson = lesson //Maybe it's a bad thing
                    getForLessonBlock(lesson)
                } else {
                    errorHandler("No lesson with id \(step.lessonId)")
                }
                
            }, error: 
            {
                error in 
                errorHandler("failed to get lesson with id \(step.lessonId)") 
            }
        )
        
    }
    
    //Getting unit here. 
    fileprivate static func getStepsController(forStep step: Step, lesson: Lesson, success successHandler: @escaping ((StepsViewController) -> Void), error errorHandler: @escaping ((String) -> Void)) {
        
        let getForUnitBlock : ((Unit) -> Void) = {
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
                case .noUnits:
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
    fileprivate static func getStepsController(forStep step: Step, lesson: Lesson, unit: Unit, success successHandler: @escaping ((StepsViewController) -> Void), error errorHandler: @escaping ((String) -> Void)) {
        
        //Check, if cached assignments contain nil progresses
//        unit.assignments.contains({$0.})
        
        ApiDataDownloader.assignments.retrieve(ids: unit.assignmentsArray, existing: unit.assignments, refreshMode: .update, success: {
            newAssignments in 
            
            if newAssignments.count == 0 {
                getStepsControllerForLessonContext(step, lesson: lesson, success: successHandler, error: errorHandler)
                return
            }
            unit.assignments = Sorter.sort(newAssignments, byIds: unit.assignmentsArray)
            
            getStepsControllerForUnitContext(step, lesson: lesson, unit: unit, success: successHandler, error: errorHandler) 
            return
            
            }, error: {
                error in
                errorHandler("Error while downloading assignments")
        })

        
    }
    
    //Define this method's signature later
    fileprivate static func getStepsControllerForLessonContext(_ step: Step, lesson: Lesson, success successHandler: ((StepsViewController) -> Void), error errorHandler: ((String) -> Void)) {
        
        guard let vc = ControllerHelper.instantiateViewController(identifier: "StepsViewController") as? StepsViewController else {
            errorHandler("Could not instantiate controller")
            return
        }
        
        vc.hidesBottomBarWhenPushed = true
        let step = step
        vc.context = .lesson
        vc.lesson = lesson
        
        //TODO: Check if it is better to do it using stepsArray
        vc.startStepId = step.lesson?.steps.index(of: step) ?? 0
        successHandler(vc)
    }
    
    //Define this method's signature later
    fileprivate static func getStepsControllerForUnitContext(_ step: Step, lesson: Lesson, unit: Unit, success successHandler: ((StepsViewController) -> Void), error errorHandler: ((String) -> Void)) {
        guard let vc = ControllerHelper.instantiateViewController(identifier: "StepsViewController") as? StepsViewController else {
            errorHandler("Could not instantiate controller")
            return
        }
        
        vc.hidesBottomBarWhenPushed = true
        let step = step
        vc.context = .unit
        vc.lesson = lesson
//        unit.assignments
        //TODO: Add assignment here
        //TODO: Check if it is better to do it using stepsArray
        vc.startStepId = step.lesson?.steps.index(of: step) ?? 0
        successHandler(vc)
    }

}
