//
//  HomeScreenPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 25.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol HomeScreenView: class {
    func presentBlocks(blocks: [CourseListBlock])
    func presentContinueLearningWidget(widget: ContinueLearningWidgetView)
    func hideCountinueLearningWidget()

    func getNavigation() -> UINavigationController?
    func updateCourseCount(to: Int, forBlockWithID: String)
    func show(vc: UIViewController)
}

class HomeScreenPresenter: LastStepWidgetDataSource, CourseListCountDelegate {
    weak var view: HomeScreenView?
    init(view: HomeScreenView) {
        self.view = view
    }

    func initBlocks() {
        let showController: (UIViewController) -> Void = {
            [weak self]
            vc in
            self?.view?.show(vc: vc)
        }

        let blocks = [
            CourseListBlock(listType: .enrolled, ID: "enrolled", horizontalLimit: 14, title: NSLocalizedString("Enrolled", comment: ""), colorMode: .light, shouldShowCount: true, showControllerBlock: showController, lastStepWidgetDataSource: self, courseListCountDelegate: self, onlyLocal: false),
            CourseListBlock(listType: .popular, ID: "popular", horizontalLimit: 14, title: NSLocalizedString("Popular", comment: ""), colorMode: .dark, shouldShowCount: false, showControllerBlock: showController, courseListCountDelegate: self, onlyLocal: false)
        ]

        view?.presentBlocks(blocks: blocks)
    }

    private let continueLearningWidget = ContinueLearningWidgetView(frame: CGRect.zero)
    private var isContinueLearningWidgetPresented: Bool = false

    private func presentLastStep(for course: Course) {
        guard let widgetData = ContinueLearningWidgetData(course: course, navigation: view?.getNavigation()) else {
            return
        }

        continueLearningWidget.setup(widgetData: widgetData)

        if !isContinueLearningWidgetPresented {
            view?.presentContinueLearningWidget(widget: continueLearningWidget)
            isContinueLearningWidgetPresented = true
        }
    }

    private func updateCourseForLastStep(courses: [Course]) {
        for course in courses {
            if checkIsGoodForLastStep(course: course) {
                presentLastStep(for: course)
                return
            }
        }
        if isContinueLearningWidgetPresented {
            hideContinueLearningWidget()
        }
    }

    private func hideContinueLearningWidget() {
        view?.hideCountinueLearningWidget()
        isContinueLearningWidgetPresented = false
    }

    private func checkIsGoodForLastStep(course: Course) -> Bool {
        return course.scheduleType != "ended" && course.scheduleType != "upcoming" && !course.sectionsArray.isEmpty
    }

    func didLoadWithProgresses(courses: [Course]) {
        if courses.isEmpty {
            if isContinueLearningWidgetPresented {
                hideContinueLearningWidget()
            }
        } else {
            updateCourseForLastStep(courses: courses)
        }
    }

    func updateCourseCount(to: Int, forListID: String) {
        view?.updateCourseCount(to: to, forBlockWithID: forListID)
    }
}

struct ContinueLearningWidgetData {
    let title: String
    let progress: Float?
    let imageURL: String
    let continueLearningAction: (() -> Void)?

    init?(course: Course, navigation: UINavigationController?) {
        title = course.title
        progress = course.progress?.percentPassed
        imageURL = course.coverURLString
        if let navigation = navigation {
            continueLearningAction = {
                LastStepRouter.continueLearning(for: course, using: navigation)
            }
        } else {
            return nil
        }
    }
}

struct CourseListBlock {
    let title: String
    let colorMode: CourseListColorMode
    var ID: String
    let horizontalController: CourseListHorizontalViewController
    let shouldShowCount: Bool
    let showVerticalBlock: () -> Void
    let onlyLocal: Bool

    init(listType: CourseListType, ID: String, horizontalLimit: Int?, title: String, colorMode: CourseListColorMode, shouldShowCount: Bool, showControllerBlock: @escaping (UIViewController) -> Void, lastStepWidgetDataSource: LastStepWidgetDataSource? = nil, courseListCountDelegate: CourseListCountDelegate? = nil, onlyLocal: Bool = false) {
        self.title = title
        self.colorMode = colorMode
        self.ID = ID
        self.shouldShowCount = shouldShowCount
        self.onlyLocal = onlyLocal
        self.horizontalController = ControllerHelper.instantiateViewController(identifier: "CourseListHorizontalViewController", storyboardName: "CourseLists") as! CourseListHorizontalViewController
        self.horizontalController.presenter = CourseListPresenter(view: horizontalController, ID: ID, limit: horizontalLimit, listType: listType, colorMode: colorMode, onlyLocal: onlyLocal, subscriptionManager: CourseSubscriptionManager(), coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI(), reviewSummariesAPI: CourseReviewSummariesAPI(), searchResultsAPI: SearchResultsAPI(), subscriber: CourseSubscriber())
        self.horizontalController.presenter?.lastStepDataSource = lastStepWidgetDataSource
        self.horizontalController.presenter?.couseListCountDelegate = courseListCountDelegate
        self.showVerticalBlock = {
            let verticalController = ControllerHelper.instantiateViewController(identifier: "CourseListVerticalViewController", storyboardName: "CourseLists") as! CourseListVerticalViewController
            verticalController.title = title
            verticalController.presenter = CourseListPresenter(view: verticalController, ID: ID, limit: nil, listType: listType, colorMode: colorMode, onlyLocal: onlyLocal, subscriptionManager: CourseSubscriptionManager(), coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI(), reviewSummariesAPI: CourseReviewSummariesAPI(), searchResultsAPI: SearchResultsAPI(), subscriber: CourseSubscriber())
            showControllerBlock(verticalController)
        }
    }
}
