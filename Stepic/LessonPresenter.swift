//
//  LessonPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 18.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

enum LessonViewState {
    case displayingSteps, placeholder, refreshing
}

enum StepsControllerPresentationContext {
    case lesson, unit
}

typealias LessonInitObjects = (lesson: Lesson, startStepId: Int, context: StepsControllerPresentationContext)
typealias LessonInitIds = (stepId: Int?, unitId: Int?)

class LessonPresenter {
    weak var view: LessonView?

    weak var sectionNavigationDelegate: SectionNavigationDelegate?

    static let stepUpdatedNotification = "StepUpdatedNotification"
    fileprivate var tabViewsForStepId = [Int: UIView]()

    private var controllerForIndex: [Int: UIViewController] = [:]

    fileprivate var lesson: Lesson?
    fileprivate var startStepId: Int = 0
    fileprivate var stepId: Int?
    fileprivate var unitId: Int?
    fileprivate var context: StepsControllerPresentationContext = .unit

    var stepsAPI: StepsAPI
    var lessonsAPI: LessonsAPI

    fileprivate var didInitSteps: Bool = false
    fileprivate var didSelectTab: Bool = false

    fileprivate var canSendViews: Bool = false

    private lazy var dataBackService: DataBackUpdateServiceProtocol = {
        let service = DataBackUpdateService(
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI())
        )
        return service
    }()

    private lazy var unitNavigationService: UnitNavigationServiceProtocol = {
        let service = UnitNavigationService(
            sectionsPersistenceService: SectionsPersistenceService(),
            sectionsNetworkService: SectionsNetworkService(sectionsAPI: SectionsAPI()),
            unitsPersistenceService: UnitsPersistenceService(),
            unitsNetworkService: UnitsNetworkService(unitsAPI: UnitsAPI()),
            coursesPersistenceService: CoursesPersistenceService(),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI())
        )
        return service
    }()

    private var didNextUnitLoad = false
    private var nextUnit: Unit?

    private var didPreviousUnitLoad = false
    private var previousUnit: Unit?

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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.stepDoneAction),
            name: .stepDone,
            object: nil
        )

        if let unitID = self.unitId {
            DispatchQueue.global().async { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.unitNavigationService.findUnitForNavigation(
                    from: unitID,
                    direction: .next
                ).done { unit in
                    print("next unit loaded, unit = \(unit?.id)")
                    if let unit = unit {
                        if let stepsCount = strongSelf.lesson?.stepsArray.count {
                            (strongSelf.controllerForIndex[stepsCount - 1] as? VideoStepViewController)?.nextLessonHandler = {
                                strongSelf.navigateToNextOrPreviousUnit(direction: .next)
                            }
                            (strongSelf.controllerForIndex[stepsCount - 1] as? WebStepViewController)?.nextLessonHandler = {
                                strongSelf.navigateToNextOrPreviousUnit(direction: .next)
                            }
                        }

                        strongSelf.didNextUnitLoad = true
                        strongSelf.nextUnit = unit
                    }
                }.cauterize()

                strongSelf.unitNavigationService.findUnitForNavigation(
                    from: unitID,
                    direction: .previous
                ).done { unit in
                    print("previous unit loaded, unit = \(unit?.id)")
                    if let unit = unit {
                        (strongSelf.controllerForIndex[0] as? VideoStepViewController)?.prevLessonHandler = {
                            strongSelf.navigateToNextOrPreviousUnit(direction: .previous)
                        }
                        (strongSelf.controllerForIndex[0] as? WebStepViewController)?.prevLessonHandler = {
                            strongSelf.navigateToNextOrPreviousUnit(direction: .previous)
                        }

                        strongSelf.didPreviousUnitLoad = true
                        strongSelf.previousUnit = unit
                    }
                }.cauterize()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func stepDoneAction() {
        guard let unitID = self.unitId else {
            return
        }

        self.dataBackService.triggerProgressUpdate(unit: unitID, triggerRecursive: true)
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

        var step: Step?

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

            var localLesson: Lesson?
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
                self?.canSendViews ?? false
            }

            if context == .unit && index == 0 && didPreviousUnitLoad {
                stepController.prevLessonHandler = { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.navigateToNextOrPreviousUnit(direction: .previous)
                }
            }

            if context == .unit && index == lesson.stepsArray.count - 1 && didNextUnitLoad {
                stepController.nextLessonHandler = { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.navigateToNextOrPreviousUnit(direction: .next)
                }
            }

            controllerForIndex[index] = stepController
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
                self?.canSendViews ?? false
            }
            stepController.lessonSlug = lesson.slug

            if context == .unit && index == 0 && didPreviousUnitLoad {
                stepController.prevLessonHandler = { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.navigateToNextOrPreviousUnit(direction: .previous)
                }
            }

            if context == .unit && index == lesson.stepsArray.count - 1 && didNextUnitLoad {
                stepController.nextLessonHandler = { [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.navigateToNextOrPreviousUnit(direction: .next)
                }
            }

            controllerForIndex[index] = stepController
            return stepController
        }
    }

    private func navigateToNextOrPreviousUnit(direction: UnitNavigationDirection) {
        guard let targetUnit = direction == .next ? self.nextUnit : self.previousUnit else {
            return
        }

        SVProgressHUD.show()
        let cachedLesson = Lesson.fetch([targetUnit.lessonId]).first
        if let lesson = cachedLesson {
            self.replaceByNewLesson(
                lesson: lesson,
                unit: targetUnit,
                stepArrayFunction: { direction == .next ? $0.first : $0.last }
            )
        } else {
            self.lessonsAPI.retrieve(ids: [targetUnit.lessonId]).done { lessons in
                guard let lesson = lessons.first else {
                    SVProgressHUD.showError(withStatus: nil)
                    return
                }

                self.replaceByNewLesson(
                    lesson: lesson,
                    unit: targetUnit,
                    stepArrayFunction: { direction == .next ? $0.first : $0.last }
                )
                SVProgressHUD.dismiss()
            }.catch { _ in
                print("error while fetching lesson for next/prev unit")
                SVProgressHUD.showError(withStatus: nil)
            }
        }
    }

    private func replaceByNewLesson(lesson: Lesson, unit: Unit, stepArrayFunction: ([Int]) -> Int?) {
        guard let viewControllers = self.view?.nController?.viewControllers,
              let presentingViewController = self.view?.nController?.viewControllers[safe: viewControllers.count - 2] else {
            return
        }

        guard let stepID = stepArrayFunction(lesson.stepsArray) else {
            SVProgressHUD.showError(withStatus: nil)
            return
        }

        let newLessonController = LessonLegacyAssembly(
            initObjects: nil,
            initIDs: (stepId: stepID, unitId: unit.id)
        ).makeModule()

        SVProgressHUD.dismiss()
        presentingViewController.replace(by: newLessonController)
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
