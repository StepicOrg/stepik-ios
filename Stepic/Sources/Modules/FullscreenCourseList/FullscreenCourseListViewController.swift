//
//  FullscreenCourseListFullscreenCourseListViewController.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 19/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol FullscreenCourseListViewControllerProtocol: class {
    func displayCourseInfo(viewModel: FullscreenCourseList.CourseInfoPresentation.ViewModel)
    func displayCourseSyllabus(viewModel: FullscreenCourseList.CourseSyllabusPresentation.ViewModel)
    func displayLastStep(viewModel: FullscreenCourseList.LastStepPresentation.ViewModel)
    func displayAuthorization(viewModel: FullscreenCourseList.PresentAuthorization.ViewModel)
    func displayPlaceholder(viewModel: FullscreenCourseList.PresentPlaceholder.ViewModel)
}

final class FullscreenCourseListViewController: UIViewController,
                                                ControllerWithStepikPlaceholder {
    let interactor: FullscreenCourseListInteractorProtocol
    private let courseListType: CourseListType
    private let presentationDescription: CourseList.PresentationDescription?

    lazy var fullscreenCourseListView = self.view as? FullscreenCourseListView
    private var submoduleViewController: UIViewController?

    var placeholderContainer = StepikPlaceholderControllerContainer()

    init(
        interactor: FullscreenCourseListInteractorProtocol,
        courseListType: CourseListType,
        presentationDescription: CourseList.PresentationDescription?
    ) {
        self.interactor = interactor
        self.presentationDescription = presentationDescription
        self.courseListType = courseListType

        super.init(nibName: nil, bundle: nil)

        if self.presentationDescription != nil {
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
        let view = FullscreenCourseListView(frame: UIScreen.main.bounds)
        self.view = view
        self.refreshSubmodule()

        // Register placeholders
        // Error
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnection,
                action: { [weak self] in
                    self?.refreshSubmodule()
                }
            ),
            for: .connectionError
        )

        // Empty
        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .emptySearch,
                action: { [weak self] in
                    self?.refreshSubmodule()
                }
            ),
            for: .empty
        )
    }

    private func refreshSubmodule() {
        self.submoduleViewController?.removeFromParentViewController()

        let courseListAssembly = VerticalCourseListAssembly(
            type: self.courseListType,
            colorMode: .light,
            presentationDescription: self.presentationDescription,
            output: self.interactor
        )
        let courseListViewController = courseListAssembly.makeModule()
        self.addChildViewController(courseListViewController)

        self.submoduleViewController = courseListViewController

        self.fullscreenCourseListView?.attachContentView(
            courseListViewController.view
        )

        if let moduleInput = courseListAssembly.moduleInput {
            self.interactor.doOnlineModeReset(request: .init(module: moduleInput))
        }
    }
}

extension FullscreenCourseListViewController: FullscreenCourseListViewControllerProtocol {
    func displayPlaceholder(viewModel: FullscreenCourseList.PresentPlaceholder.ViewModel) {
        switch viewModel.state {
        case .error:
            self.showPlaceholder(for: .empty)
        case .empty:
            self.showPlaceholder(for: .connectionError)
        }
    }

    func displayCourseInfo(viewModel: FullscreenCourseList.CourseInfoPresentation.ViewModel) {
        let assembly = CourseInfoAssembly(courseID: viewModel.courseID, initialTab: .info)
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayCourseSyllabus(viewModel: FullscreenCourseList.CourseSyllabusPresentation.ViewModel) {
        let assembly = CourseInfoAssembly(courseID: viewModel.courseID, initialTab: .syllabus)
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayLastStep(viewModel: FullscreenCourseList.LastStepPresentation.ViewModel) {
        guard let navigationController = self.navigationController else {
            return
        }

        LastStepRouter.continueLearning(
            for: viewModel.course,
            isAdaptive: viewModel.isAdaptive,
            using: navigationController
        )
    }

    func displayAuthorization(viewModel: FullscreenCourseList.PresentAuthorization.ViewModel) {
        RoutingManager.auth.routeFrom(controller: self, success: nil, cancel: nil)
    }
}

private extension StepikPlaceholderControllerContainer.PlaceholderState {
    static let empty = StepikPlaceholderControllerContainer.PlaceholderState(id: "empty")
}
