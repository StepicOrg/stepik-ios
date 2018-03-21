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

    var initialActions: ((((([Course], [AdaptiveCourseInfo])) -> Void)?, ((Error) -> Void)?) -> Void)?
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
                actions({ courses, adaptiveCoursesInfo -> Void in
                    self?.courses = courses
                    self?.reloadData(courses: courses, adaptiveCoursesInfo: adaptiveCoursesInfo)
                    self?.view?.state = .normal
                }, { error in
                    switch error {
                    case AdaptiveCardsStepsError.noProfile, AdaptiveCardsStepsError.userNotUnregisteredFromEmails:
                        break
                    case PerformRequestError.noAccessToRefreshToken:
                        self?.logout()
                    default:
                        self?.view?.state = .error
                    }
                })
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
                                                             firstColor: StepicApplicationsInfo.Colors.mainDark,
                                                             secondColor: StepicApplicationsInfo.Colors.mainDark,
                                                             mainColor: StepicApplicationsInfo.Colors.mainDark))
            }
        }
        view?.set(data: viewData)
        lastDisplayedData = viewData

        // If last course saved, open it
        if let lastCourseId = defaultsStorageManager.lastCourseId {
            openCourse(id: lastCourseId, uiColor: adaptiveCoursesInfo.filter({ $0.id == lastCourseId }).first?.mainColor)
            return
        }
    }

    func tryAgain() {
        refresh()
    }

    private func logout() {
        AuthInfo.shared.token = nil
        AuthInfo.shared.user = nil

        refresh()
    }

    func openCourse(id: Int, uiColor: UIColor? = StepicApplicationsInfo.Colors.mainDark) {
        guard let actions = actions else {
            return
        }

        // Override system color
        if let uiColor = uiColor {
            StepicApplicationsInfo.Colors.mainDark = uiColor
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
        let presenter = AdaptiveCardsStepsPresenter(stepsAPI: StepsAPI(), lessonsAPI: LessonsAPI(), recommendationsAPI: RecommendationsAPI(), unitsAPI: UnitsAPI(), viewsAPI: ViewsAPI(), ratingsAPI: AdaptiveRatingsAPI(), ratingManager: AdaptiveRatingManager(courseId: id), statsManager: AdaptiveStatsManager(courseId: id), storageManager: AdaptiveStorageManager(), achievementsManager: achievementsManager, defaultsStorageManager: DefaultsStorageManager(), lastViewedUpdater: LocalProgressLastViewedUpdater(), view: vc)
        presenter.initialActions = { completion, failure in
            checkToken().then { () -> Promise<Void> in
                if !AuthInfo.shared.isAuthorized {
                    return actions.registerNewUser()
                } else {
                    return Promise(value: ())
                }
            }.then { _ -> Promise<Course> in
                actions.loadCourseAndJoin(courseId: id)
            }.then { course in
                completion?(course)
            }.catch { error in
                failure?(error)
            }
        }
        vc.presenter = presenter
        view?.presentCourse(viewController: vc)

        // Save last course
        defaultsStorageManager.lastCourseId = id
    }
}
