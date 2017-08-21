//
//  LessonPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 18.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

enum LessonViewState {
    case displayingSteps, placeholder, refreshing
}

typealias LessonInitObjects = (lesson: Lesson, startStepId: Int, context: StepsControllerPresentationContext)
typealias LessonInitIds = (stepId: Int?, unitId: Int?)

class LessonPresenter {
    weak var view: LessonView?

    weak var sectionNavigationDelegate: SectionNavigationDelegate?

    static let stepUpdatedNotification = "StepUpdatedNotification"
    fileprivate var tabViewsForStepId = [Int: UIView]()

    fileprivate var lesson: Lesson?
    fileprivate var startStepId: Int = 0
    fileprivate var stepId: Int?
    fileprivate var unitId: Int?
    fileprivate var context: StepsControllerPresentationContext = .unit

    var stepsAPI: StepsAPI
    var lessonsAPI: LessonsAPI

    var shouldNavigateToPrev: Bool = false
    var shouldNavigateToNext: Bool = false

    fileprivate var didInitSteps: Bool = false
    fileprivate var didSelectTab: Bool = false

    fileprivate var canSendViews: Bool = false

    init(objects: LessonInitObjects?, ids: LessonInitIds?, stepsAPI: StepsAPI, lessonsAPI: LessonsAPI) {
        if let objects = objects {
            self.lesson = objects.lesson
            self.startStepId = objects.startStepId
            self.context = objects.context
        }
        if let ids = ids {
            self.stepId = ids.stepId
            self.unitId = ids.unitId
            self.context = .unit
        }
        LastStepGlobalContext.context.unitId = unitId
        self.stepsAPI = stepsAPI
        self.lessonsAPI = lessonsAPI
    }

    var url: String {
        guard let lesson = lesson else { return "" }
        return "\(StepicApplicationsInfo.stepicURL)/lesson/\(lesson.slug)/step/1?from_mobile_app=true"
    }

    fileprivate func loadLesson() {
        guard let stepId = stepId else {
            print("ERROR: Load lesson without lesson and step id called")
            return
        }

        view?.setRefreshing(refreshing: true)

        var step: Step? = nil

        if let localStep = Step.getStepWithId(stepId, unitId: unitId) {
            step = localStep
            if let localLesson = localStep.lesson {
                self.lesson = localLesson
                refreshSteps()
                return
            }
        }

        _ = stepsAPI.retrieve(ids: [stepId], existing: (step != nil) ? [step!] : [], refreshMode: .update, success: {
            [weak self]
            steps in

            guard let step = steps.first else {
                return
            }

            var localLesson: Lesson? = nil
            localLesson = Lesson.getLesson(step.lessonId)

            _ = self?.lessonsAPI.retrieve(ids: [step.lessonId], existing: (localLesson != nil) ? [localLesson!] : [], refreshMode: .update, success: {
                [weak self]
                lessons in
                guard let lesson = lessons.first else {
                    return
                }

                self?.lesson = lesson
                step.lesson = lesson
                self?.refreshSteps()
                return

                }, error: {
                    _ in
                    print("Error while downloading lesson")
                    DispatchQueue.main.async {
                        [weak self] in
                        guard let s = self else { return }
                        s.view?.setRefreshing(refreshing: false)
                    }
            })
        }, error: {
            _ in
            print("Error while downloading step")
            DispatchQueue.main.async {
                [weak self] in
                guard let s = self else { return }
                s.view?.setRefreshing(refreshing: false)
            }
        })
    }

    func refreshSteps() {

        guard lesson != nil else {
            loadLesson()
            return
        }

        if let section = lesson?.unit?.section,
            let unitId = unitId {
            if let index = section.unitsArray.index(of: unitId) {
                shouldNavigateToPrev = index != 0
                shouldNavigateToNext = index < section.unitsArray.count - 1
            }
        }

        view?.updateTitle(title: lesson?.title ?? NSLocalizedString("Lesson", comment: ""))

        if let stepId = stepId {
            if let index = lesson?.stepsArray.index(of: stepId) {
                startStepId = index
                didSelectTab = false
            }
        }

        var prevStepsIds = [Int]()
        if lesson?.steps.count == 0 {
            self.view?.setRefreshing(refreshing: true)
        } else {
            if let l = lesson, l.stepsArray.count == l.steps.count {
                prevStepsIds = l.stepsArray
                view?.reload()
            } else {
                self.view?.setRefreshing(refreshing: true)
            }
        }

        let finishedInitBlock = {
            [weak self] in
            guard let s = self else { return }
            s.view?.setRefreshing(refreshing: false)

            if s.startStepId < s.lesson!.steps.count {
                if !s.didSelectTab {
                    s.view?.selectTab(index: s.startStepId, updatePage: true)
                    s.didSelectTab = true
                }
            }
            s.didInitSteps = true
        }

        lesson?.loadSteps(completion: {
            [weak self] in
            guard let s = self else {
                return
            }
            let newStepsSet = Set(s.lesson!.stepsArray)
            let prevStepsSet = Set(prevStepsIds)
            var reloadBlock : (() -> Void) = {
                [weak self] in
                self?.view?.reload()
            }

            if newStepsSet.symmetricDifference(prevStepsSet).count == 0 {
                //need to reload one by one
                reloadBlock = {
                    [weak self] in
                    guard let s = self else {
                        return
                    }
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: LessonPresenter.stepUpdatedNotification), object: nil)
                    print("did send step updated notification")
                    s.updateTabViews()
                }
            }

            DispatchQueue.main.async {
                reloadBlock()
                finishedInitBlock()
            }
        }, error: {
            [weak self]
            _ in
            guard self != nil else {
                return
            }
            print("error while loading steps in LessonPresenter")
            DispatchQueue.main.async {
                finishedInitBlock()
            }
        }, onlyLesson: context == .lesson)
    }

    func updateTabViews() {
        for index in 0 ..< pagesCount {
            let tabView = self.tabView(index: index) as? StepTabView
            if let progress = lesson!.steps[index].progress {
                tabView?.setTab(selected: progress.isPassed, animated: true)
            }
        }
    }

    var pagesCount: Int {
        return lesson?.steps.count ?? 0
    }

    func controller(index: Int) -> UIViewController? {
        guard let lesson = lesson else {
            return nil
        }

        //Just a try to fix a strange bug
        if index >= lesson.steps.count {
            return nil
        }

        if lesson.steps[index].block.name == "video" {
            let stepController = ControllerHelper.instantiateViewController(identifier: "VideoStepViewController") as! VideoStepViewController
            stepController.video = lesson.steps[index].block.video!
            stepController.step = lesson.steps[index]
            stepController.startStepId = startStepId
            stepController.stepId = index + 1
            stepController.lessonSlug = lesson.slug
            stepController.nItem = self.view?.nItem
            stepController.nController = self.view?.nController
            if let assignments = lesson.unit?.assignments {
                if index < assignments.count {
                    stepController.assignment = assignments[index]
                }
            }

            stepController.startStepBlock = {
                [weak self] in
                self?.canSendViews = true
                self?.didSelectTab = true
            }
            stepController.shouldSendViewsBlock = {
                [weak self] in
                return self?.canSendViews ?? false
            }

            if context == .unit {
                if index == 0 && shouldNavigateToPrev {
                    stepController.prevLessonHandler = {
                        [weak self] in
                        self?.sectionNavigationDelegate?.displayPrev()
                    }
                }

                if index == lesson.steps.count - 1 && shouldNavigateToNext {
                    stepController.nextLessonHandler = {
                        [weak self] in
                        self?.sectionNavigationDelegate?.displayNext()
                    }
                }
            }

            return stepController
        } else {
            let stepController = ControllerHelper.instantiateViewController(identifier: "WebStepViewController") as! WebStepViewController
            stepController.lessonView = self.view
            stepController.step = lesson.steps[index]
            stepController.lesson = lesson
            stepController.stepId = index + 1
            stepController.nItem = self.view?.nItem
            stepController.nController = self.view?.nController
            stepController.startStepId = startStepId

            if let assignments = lesson.unit?.assignments {
                if index < assignments.count {
                    stepController.assignment = assignments[index]
                }
            }

            stepController.startStepBlock = {
                [weak self] in
                self?.canSendViews = true
                self?.didSelectTab = true
            }
            stepController.shouldSendViewsBlock = {
                [weak self] in
                return self?.canSendViews ?? false
            }
            stepController.lessonSlug = lesson.slug
            if context == .unit {
                if index == 0 && shouldNavigateToPrev {
                    stepController.prevLessonHandler = {
                        [weak self] in
                        self?.sectionNavigationDelegate?.displayPrev()
                    }
                }

                if index == lesson.steps.count - 1 && shouldNavigateToNext {
                    stepController.nextLessonHandler = {
                        [weak self] in
                        self?.sectionNavigationDelegate?.displayNext()
                    }
                }
            }

            return stepController
        }
    }

    func tabView(index: Int) -> UIView {
        guard lesson != nil else {
            return UIView()
        }

        //Just a try to fix a strange bug
        if index >= lesson!.steps.count {
            return UIView()
        }

        if let step = lesson?.steps[index] {
            print("initializing tab view for step id \(step.id), progress is \(String(describing: step.progress)))")
            tabViewsForStepId[step.id] = StepTabView(frame: CGRect(x: 0, y: 0, width: 25, height: 25), image: step.block.image, stepId: step.id, passed: step.progress?.isPassed ?? false)

            return tabViewsForStepId[step.id]!
        } else {
            return UIView()
        }
    }
}
