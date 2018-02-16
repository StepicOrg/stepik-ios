//
//  AdaptiveCourseSelectPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol AdaptiveCourseSelectView: class {
    var state: AdaptiveCourseSelectViewState { get set }

    func set(data: [AdaptiveCourseSelectViewData])
    func presentCourse(viewController: UIViewController)
}

struct AdaptiveCourseSelectViewData {
    var id: Int
    var name: String
    var cover: URL?
    var description: String

    var points: Int
    var learners: Int
    var level: Int

    var firstColor: UIColor
    var secondColor: UIColor
    var mainColor: UIColor
}

class AdaptiveCourseSelectPresenter {
    weak var view: AdaptiveCourseSelectView?

    var defaultsStorageManager: DefaultsStorageManager

    var initialActions: Promise<([Course], [AdaptiveCourseInfo])>?
    private var courses: [Course] = []

    // Save actions to prevent deallocation
    var actions: AdaptiveUserActions?
    var lastDisplayedData: [AdaptiveCourseSelectViewData]?

    init(defaultsStorageManager: DefaultsStorageManager, view: AdaptiveCourseSelectView) {
        self.view = view
        self.defaultsStorageManager = defaultsStorageManager

        actions = AdaptiveUserActions(coursesAPI: CoursesAPI(), authAPI: AuthAPI(), stepicsAPI: StepicsAPI(), profilesAPI: ProfilesAPI(), enrollmentsAPI: EnrollmentsAPI(), adaptiveCoursesInfoAPI: AdaptiveCoursesInfoAPI(), defaultsStorageManager: DefaultsStorageManager())
    }

    func refresh() {
        view?.state = .loading

        DispatchQueue.global().async { [weak self] in
            if let actions = self?.initialActions {
                actions.then { courses, adaptiveCoursesInfo -> Void in
                    self?.courses = courses
                    self?.reloadData(courses: courses, adaptiveCoursesInfo: adaptiveCoursesInfo)
                    self?.view?.state = .normal
                }.catch { error in
                    if let error = error as? AdaptiveCardsStepsError {
                        switch error {
                        case .noProfile, .userNotUnregisteredFromEmails:
                            break
                        default:
                            self?.view?.state = .error
                        }
                    }
                }
            }
        }
    }

    func refreshProgresses() {
        guard let lastData = lastDisplayedData else {
            // First loading, no displayed data yet -> skip progress refreshing
            return
        }

        var newData = [AdaptiveCourseSelectViewData]()
        for item in lastData {
            var newItem = item
            newItem.points = AdaptiveRatingManager(courseId: item.id).rating
            newItem.level = AdaptiveRatingHelper.getLevel(for: newItem.points)
            newData.append(newItem)
        }

        view?.set(data: newData)
        lastDisplayedData = newData
    }

    func resetLastCourse() {
        defaultsStorageManager.lastCourseId = nil
    }

    private func reloadData(courses: [Course], adaptiveCoursesInfo: [AdaptiveCourseInfo]) {
        var viewData: [AdaptiveCourseSelectViewData] = []
        for course in courses {
            let rating = AdaptiveRatingManager(courseId: course.id).rating
            let level = AdaptiveRatingHelper.getLevel(for: rating)

            let filteredCoursesInfo = adaptiveCoursesInfo.filter { $0.id == course.id }
            if let courseInfo = filteredCoursesInfo.first {
                viewData.append(AdaptiveCourseSelectViewData(id: course.id,
                                                             name: courseInfo.title,
                                                             cover: URL(string: courseInfo.coverURL),
                                                             description: courseInfo.description,
                                                             points: rating,
                                                             learners: course.learnersCount ?? 0,
                                                             level: level,
                                                             firstColor: courseInfo.firstColor,
                                                             secondColor: courseInfo.secondColor,
                                                             mainColor: courseInfo.mainColor))
            } else {
                viewData.append(AdaptiveCourseSelectViewData(id: course.id,
                                                             name: course.title,
                                                             cover: URL(string: course.coverURLString),
                                                             description: "",
                                                             points: rating,
                                                             learners: course.learnersCount ?? 0,
                                                             level: level,
                                                             firstColor: StepicApplicationsInfo.adaptiveMainColor,
                                                             secondColor: StepicApplicationsInfo.adaptiveMainColor,
                                                             mainColor: StepicApplicationsInfo.adaptiveMainColor))
            }
        }
        view?.set(data: viewData)
        lastDisplayedData = viewData

        // If last course saved, open it
        if let lastCourseId = defaultsStorageManager.lastCourseId {
            openCourse(id: lastCourseId)
            return
        }
    }

    func tryAgain() {
        refresh()
    }

    func openCourse(id: Int) {
        guard let actions = actions else {
            return
        }

        guard let vc = ControllerHelper.instantiateViewController(identifier: "AdaptiveCardsSteps", storyboardName: "AdaptiveMain") as? AdaptiveCardsStepsViewController else {
            return
        }

        let rating = AdaptiveRatingManager(courseId: id).rating
        let streak = AdaptiveRatingManager(courseId: id).streak

        let isOnboardingPassed = AdaptiveStorageManager.shared.isAdaptiveOnboardingPassed || DefaultsStorageManager.shared.isRatingOnboardingFinished
        let achievementsManager = AchievementManager.createAndRegisterAchievements(currentRating: rating, currentStreak: streak, currentLevel: AdaptiveRatingHelper.getLevel(for: rating), isOnboardingPassed: isOnboardingPassed)
        AchievementManager.shared = achievementsManager

        // Init course controller
        let presenter = AdaptiveCardsStepsPresenter(stepsAPI: StepsAPI(), lessonsAPI: LessonsAPI(), recommendationsAPI: RecommendationsAPI(), unitsAPI: UnitsAPI(), viewsAPI: ViewsAPI(), ratingsAPI: AdaptiveRatingsAPI(), ratingManager: AdaptiveRatingManager(courseId: id), statsManager: AdaptiveStatsManager(courseId: id), storageManager: AdaptiveStorageManager(), achievementsManager: achievementsManager, defaultsStorageManager: DefaultsStorageManager(), view: vc)
        presenter.initialActions = Promise { fulfill, reject in
            checkToken().then { _ -> Promise<Course> in
                actions.loadCourseAndJoin(courseId: id)
            }.then { course in
                fulfill(course)
            }.catch { error in
                reject(error)
            }
        }
        vc.presenter = presenter
        view?.presentCourse(viewController: vc)

        // Save last course
        defaultsStorageManager.lastCourseId = id
    }
}
