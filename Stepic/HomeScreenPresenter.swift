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
    func getNavigation() -> UINavigationController?
}

class HomeScreenPresenter: LastStepWidgetDataSource {
    weak var view: HomeScreenView?
    init(view: HomeScreenView) {
        self.view = view
    }

    func initBlocks() {
        let blocks = [
            CourseListBlock(listType: .enrolled, horizontalLimit: 6, title: "Enrolled", colorMode: .light, lastStepWidgetDataSource: self),
            CourseListBlock(listType: .popular, horizontalLimit: 6, title: "Popular", colorMode: .dark)
        ]

        view?.presentBlocks(blocks: blocks)
    }

    private func initLastStep(for course: Course) {
        guard let widgetData = ContinueLearningWidgetData(course: course, navigation: view?.getNavigation()) else {
            return
        }
        let continueLearningWidget = ContinueLearningWidgetView(frame: CGRect.zero)
        continueLearningWidget.setup(widgetData: widgetData)
        view?.presentContinueLearningWidget(widget: continueLearningWidget)
    }

    private func checkIsGoodForLastStep(course: Course) -> Bool {
        return course.scheduleType != "ended" && course.scheduleType != "upcoming" && !course.sectionsArray.isEmpty
    }

    func didLoadWithProgresses(courses: [Course]) {
        for course in courses {
            if checkIsGoodForLastStep(course: course) {
                initLastStep(for: course)
                return
            }
        }
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

    let horizontalController: CourseListHorizontalViewController
    let verticalController: CourseListVerticalViewController

    init(listType: CourseListType, horizontalLimit: Int, title: String, colorMode: CourseListColorMode, lastStepWidgetDataSource: LastStepWidgetDataSource? = nil) {
        self.title = title
        self.colorMode = colorMode

        self.horizontalController = ControllerHelper.instantiateViewController(identifier: "CourseListHorizontalViewController", storyboardName: "CourseLists") as! CourseListHorizontalViewController
        self.horizontalController.presenter = CourseListPresenter(view: horizontalController, limit: horizontalLimit, listType: listType, colorMode: colorMode, coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI(), reviewSummariesAPI: CourseReviewSummariesAPI())
        self.horizontalController.presenter?.lastStepDataSource = lastStepWidgetDataSource
        self.verticalController = ControllerHelper.instantiateViewController(identifier: "CourseListVerticalViewController", storyboardName: "CourseLists") as! CourseListVerticalViewController
        self.verticalController.presenter = CourseListPresenter(view: verticalController, limit: nil, listType: listType, colorMode: colorMode, coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI(), reviewSummariesAPI: CourseReviewSummariesAPI())
    }
}
