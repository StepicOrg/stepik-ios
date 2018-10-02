//
//  HomeHomeViewController.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 17/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol HomeViewControllerProtocol: BaseExploreViewControllerProtocol {
    func displayStreakInfo(viewModel: Home.LoadStreak.ViewModel)
}

final class HomeViewController: BaseExploreViewController {
    private static let submodulesOrder: [HomeSubmoduleType] = [
        .streakActivity,
        .continueCourse,
        .enrolledCourses,
        .popularCourses
    ]

    private lazy var streakView = StreakActivityView(frame: .zero)
    lazy var homeInteractor = self.interactor as? HomeInteractorProtocol

    init(interactor: HomeInteractorProtocol) {
        super.init(interactor: interactor)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.homeInteractor?.loadStreakActivity(request: .init())
    }

    override func initLanguageIndependentSubmodules() {
        // Continue course
        let continueCourseAssembly = ContinueCourseAssembly()
        let continueCourseViewController = continueCourseAssembly.makeModule()
        self.registerSubmodule(
            .init(
                viewController: continueCourseViewController,
                view: continueCourseViewController.view,
                isLanguageDependent: false,
                type: HomeSubmoduleType.continueCourse
            )
        )

        // Enrolled courses
        let courseListType = EnrolledCourseListType()
        let enrolledCourseListAssembly = HorizontalCourseListAssembly(
            type: courseListType,
            colorMode: .light
        )
        let enrolledCourseViewController = enrolledCourseListAssembly.makeModule()
        enrolledCourseListAssembly.moduleInput?.reload()
        let containerView = CourseListContainerViewFactory(colorMode: .light)
            .makeHorizontalContainerView(
                for: enrolledCourseViewController.view,
                headerDescription: .init(
                    title: NSLocalizedString("Enrolled", comment: ""),
                    summary: nil
                )
            )
        containerView.onShowAllButtonClick = { [weak self] in
            self?.interactor.loadFullscreenCourseList(
                request: .init(courseListType: courseListType)
            )
        }
        self.registerSubmodule(
            .init(
                viewController: enrolledCourseViewController,
                view: containerView,
                isLanguageDependent: false,
                type: HomeSubmoduleType.enrolledCourses
            )
        )
    }

    override func initLanguageDependentSubmodules(contentLanguage: ContentLanguage) {
        // Popular courses
        let courseListType = PopularCourseListType(language: contentLanguage)
        let popularAssembly = HorizontalCourseListAssembly(
            type: courseListType,
            colorMode: .dark,
            output: self.interactor as? CourseListOutputProtocol
        )
        let popularViewController = popularAssembly.makeModule()
        popularAssembly.moduleInput?.reload()
        let containerView = CourseListContainerViewFactory(colorMode: .dark)
            .makeHorizontalContainerView(
                for: popularViewController.view,
                headerDescription: .init(
                    title: NSLocalizedString("Popular", comment: ""),
                    summary: nil
                )
            )
        containerView.onShowAllButtonClick = { [weak self] in
            self?.interactor.loadFullscreenCourseList(
                request: .init(courseListType: courseListType)
            )
        }
        self.registerSubmodule(
            .init(
                viewController: popularViewController,
                view: containerView,
                isLanguageDependent: true,
                type: HomeSubmoduleType.popularCourses
            )
        )
    }

    private enum HomeSubmoduleType: Int, SubmoduleType {
        case streakActivity
        case continueCourse
        case enrolledCourses
        case popularCourses

        var id: Int {
            return self.rawValue
        }

        var position: Int {
            guard let position = HomeViewController.submodulesOrder.index(of: self) else {
                fatalError("Given submodule type has unknown position")
            }
            return position
        }
    }
}

extension HomeViewController: HomeViewControllerProtocol {
    func displayStreakInfo(viewModel: Home.LoadStreak.ViewModel) {
        switch viewModel.result {
        case .hidden:
            if let submodule = self.getSubmodule(type: HomeSubmoduleType.streakActivity) {
                self.removeSubmodule(submodule)
            }
        case .visible(let message, let streak):
            if self.getSubmodule(type: HomeSubmoduleType.streakActivity) == nil {
                self.registerSubmodule(
                    .init(
                        viewController: nil,
                        view: self.streakView,
                        isLanguageDependent: false,
                        type: HomeSubmoduleType.streakActivity
                    )
                )
            }

            streakView.message = message
            streakView.streak = streak
        }
    }
}
