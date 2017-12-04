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

    func presentContinueLearningWidget(widgetData: ContinueLearningWidgetData)
    func hideCountinueLearningWidget()

    func presentStreaksInfo(streakCount: Int, shouldSolveToday: Bool)
    func hideStreaksInfo()

    func getNavigation() -> UINavigationController?
    func updateCourseCount(to: Int, forBlockWithID: String)
    func show(vc: UIViewController)
}

class HomeScreenPresenter: LastStepWidgetDataSource, CourseListCountDelegate {
    weak var view: HomeScreenView?
    var userActivitiesAPI: UserActivitiesAPI

    init(view: HomeScreenView, userActivitiesAPI: UserActivitiesAPI) {
        self.view = view
        self.userActivitiesAPI = userActivitiesAPI
    }

    func checkStreaks() {
        guard AuthInfo.shared.isAuthorized, let userId = AuthInfo.shared.userId else {
            self.view?.hideStreaksInfo()
            return
        }

        userActivitiesAPI.retrieve(user: userId).then {
            [weak self]
            userActivity -> Void in
            if userActivity.currentStreak > 0 {
                self?.view?.presentStreaksInfo(streakCount: userActivity.currentStreak, shouldSolveToday: userActivity.needsToSolveToday)
            }
        }.catch {
            _ in
        }
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

    private func presentLastStep(for course: Course) {
        guard let widgetData = ContinueLearningWidgetData(course: course, navigation: view?.getNavigation()) else {
            return
        }

        view?.presentContinueLearningWidget(widgetData: widgetData)
    }

    private func updateCourseForLastStep(courses: [Course]) {
        for course in courses {
            if checkIsGoodForLastStep(course: course) {
                presentLastStep(for: course)
                return
            }
        }
        hideContinueLearningWidget()
    }

    private func hideContinueLearningWidget() {
        view?.hideCountinueLearningWidget()
    }

    private func checkIsGoodForLastStep(course: Course) -> Bool {
        return course.scheduleType != "ended" && course.scheduleType != "upcoming" && !course.sectionsArray.isEmpty
    }

    func didLoadWithProgresses(courses: [Course]) {
        if courses.isEmpty {
            hideContinueLearningWidget()
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
    let description: String?
    let colorMode: CourseListColorMode
    var ID: String
    let horizontalController: CourseListHorizontalViewController
    let shouldShowCount: Bool
    let showVerticalBlock: (Int?) -> Void
    let onlyLocal: Bool
    let colorStyle: CourseListEmptyPlaceholder.ColorStyle

    init(listType: CourseListType, ID: String, horizontalLimit: Int?, title: String, description: String? = nil, colorMode: CourseListColorMode, shouldShowCount: Bool, showControllerBlock: @escaping (UIViewController) -> Void, lastStepWidgetDataSource: LastStepWidgetDataSource? = nil, courseListCountDelegate: CourseListCountDelegate? = nil, onlyLocal: Bool = false, descriptionColorStyle: CourseListEmptyPlaceholder.ColorStyle? = nil) {
        let style: CourseListEmptyPlaceholder.ColorStyle = descriptionColorStyle ?? CourseListEmptyPlaceholder.ColorStyle.randomPositiveStyle
        self.colorStyle = style
        self.title = title
        self.description = description
        self.colorMode = colorMode
        self.ID = ID
        self.shouldShowCount = shouldShowCount
        self.onlyLocal = onlyLocal
        self.horizontalController = ControllerHelper.instantiateViewController(identifier: "CourseListHorizontalViewController", storyboardName: "CourseLists") as! CourseListHorizontalViewController
        self.horizontalController.presenter = CourseListPresenter(view: horizontalController, ID: ID, limit: horizontalLimit, listType: listType, colorMode: colorMode, onlyLocal: onlyLocal, subscriptionManager: CourseSubscriptionManager(), coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI(), reviewSummariesAPI: CourseReviewSummariesAPI(), searchResultsAPI: SearchResultsAPI(), subscriber: CourseSubscriber())
        self.horizontalController.presenter?.lastStepDataSource = lastStepWidgetDataSource
        self.horizontalController.presenter?.couseListCountDelegate = courseListCountDelegate
        self.showVerticalBlock = {
            count in
            let verticalController = ControllerHelper.instantiateViewController(identifier: "CourseListVerticalViewController", storyboardName: "CourseLists") as! CourseListVerticalViewController
            verticalController.title = title
            verticalController.descriptionView.colorStyle = style
            verticalController.courseCount = count
            verticalController.listDescription = description
            verticalController.presenter = CourseListPresenter(view: verticalController, ID: ID, limit: nil, listType: listType, colorMode: colorMode, onlyLocal: onlyLocal, subscriptionManager: CourseSubscriptionManager(), coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI(), reviewSummariesAPI: CourseReviewSummariesAPI(), searchResultsAPI: SearchResultsAPI(), subscriber: CourseSubscriber())
            verticalController.presenter?.couseListCountDelegate = verticalController
            showControllerBlock(verticalController)
        }
    }
}
