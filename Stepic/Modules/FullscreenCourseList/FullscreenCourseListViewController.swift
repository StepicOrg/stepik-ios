//
//  FullscreenCourseListFullscreenCourseListViewController.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 19/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol FullscreenCourseListViewControllerProtocol: class {
    func displayCourseInfo(viewModel: FullscreenCourseList.PresentCourseInfo.ViewModel)
    func displayCourseSyllabus(viewModel: FullscreenCourseList.PresentCourseSyllabus.ViewModel)
    func displayLastStep(viewModel: FullscreenCourseList.PresentLastStep.ViewModel)
    func displayAuthorization()
}

final class FullscreenCourseListViewController: UIViewController {
    let interactor: FullscreenCourseListInteractorProtocol
    private let courseListType: CourseListType
    private let presentationDescription: CourseList.PresentationDescription?

    init(
        interactor: FullscreenCourseListInteractorProtocol,
        courseListType: CourseListType,
        presentationDescription: CourseList.PresentationDescription?
    ) {
        self.interactor = interactor
        self.presentationDescription = presentationDescription
        self.courseListType = courseListType

        super.init(nibName: nil, bundle: nil)

        if let presentationDescription = self.presentationDescription {
            self.title = NSLocalizedString("RecommendedCategory", comment: "")
        } else {
            self.title = NSLocalizedString("AllCourses", comment: "")
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        let courseListAssembly = VerticalCourseListAssembly(
            type: self.courseListType,
            colorMode: .light,
            presentationDescription: self.presentationDescription,
            output: self.interactor
        )
        let courseListViewController = courseListAssembly.makeModule()
        self.addChildViewController(courseListViewController)

        let view = FullscreenCourseListView(
            frame: UIScreen.main.bounds,
            contentView: courseListViewController.view
        )
        self.view = view

        if let moduleInput = courseListAssembly.moduleInput {
            self.interactor.tryToSetOnlineMode(request: .init(module: moduleInput))
        }
    }
}

extension FullscreenCourseListViewController: FullscreenCourseListViewControllerProtocol {
    func displayCourseInfo(viewModel: FullscreenCourseList.PresentCourseInfo.ViewModel) {
        let assembly = CourseInfoLegacyAssembly(course: viewModel.course)
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayCourseSyllabus(viewModel: FullscreenCourseList.PresentCourseSyllabus.ViewModel) {
        let assembly = SyllabusLegacyAssembly(course: viewModel.course)
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayLastStep(viewModel: FullscreenCourseList.PresentLastStep.ViewModel) {
        guard let navigationController = self.navigationController else {
            return
        }

        LastStepRouter.continueLearning(
            for: viewModel.course,
            isAdaptive: viewModel.isAdaptive,
            using: navigationController
        )
    }

    func displayAuthorization() {
        RoutingManager.auth.routeFrom(controller: self, success: nil, cancel: nil)
    }
}
