//
//  BaseExploreBas?eExploreViewController.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 02/10/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol BaseExploreViewControllerProtocol: class {
    func displayContent(viewModel: BaseExplore.LoadContent.ViewModel)
    func displayFullscreenCourseList(
        viewModel: BaseExplore.PresentFullscreenCourseListModule.ViewModel
    )
    func displayCourseInfo(viewModel: BaseExplore.PresentCourseInfo.ViewModel)
    func displayCourseSyllabus(viewModel: BaseExplore.PresentCourseSyllabus.ViewModel)
    func displayLastStep(viewModel: BaseExplore.PresentLastStep.ViewModel)
    func displayAuthorization()
}

protocol SubmoduleType {
    // to be able to get submodule
    var id: Int { get }
    var position: Int { get }
}

class BaseExploreViewController: UIViewController {
    let interactor: BaseExploreInteractorProtocol
    private var submodules: [Submodule] = []
    private var state: BaseExplore.ViewControllerState

    lazy var exploreView = self.view as? BaseExploreView

    init(
        interactor: BaseExploreInteractorProtocol,
        state: BaseExplore.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = state

        super.init(nibName: nil, bundle: nil)
        self.registerForNotifications()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        let view = BaseExploreView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initLanguageIndependentSubmodules()

        self.updateState(newState: self.state)
        self.interactor.loadContent(request: .init())
    }

    // MARK: Modules

    func registerSubmodule(_ submodule: Submodule) {
        self.submodules.append(submodule)

        if let viewController = submodule.viewController {
            self.addChildViewController(viewController)
        }

        // We have contract here:
        // - subviews in exploreView have same position as in corresponding Submodule object
        for module in self.submodules {
            if module.type.position >= submodule.type.position {
                self.exploreView?.insertBlockView(
                    submodule.view,
                    before: module.view
                )
                return
            }
        }
    }

    func removeLanguageDependentSubmodules() {
        for submodule in self.submodules where submodule.isLanguageDependent {
            self.removeSubmodule(submodule)
        }
        self.submodules = self.submodules.filter { !$0.isLanguageDependent }
    }

    func removeSubmodule(_ submodule: Submodule) {
        self.exploreView?.removeBlockView(submodule.view)
        submodule.viewController?.removeFromParentViewController()
    }

    func getSubmodule(type: SubmoduleType) -> Submodule? {
        return self.submodules.first(where: { $0.type.id == type.id })
    }

    func initLanguageIndependentSubmodules() {
    }

    func initLanguageDependentSubmodules(contentLanguage: ContentLanguage) {
    }

    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            forName: .contentLanguageDidChange,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.interactor.loadContent(request: .init())
        }
    }

    private func updateState(newState: BaseExplore.ViewControllerState) {
        switch newState {
        case .normal(let language):
            self.removeLanguageDependentSubmodules()
            self.initLanguageDependentSubmodules(contentLanguage: language)
        case .loading:
            break
        }
        self.state = newState
    }

    // MARK: - Structs

    struct Submodule {
        let viewController: UIViewController?
        let view: UIView
        let isLanguageDependent: Bool
        let type: SubmoduleType
    }
}

extension BaseExploreViewController: BaseExploreViewControllerProtocol {
    func displayContent(viewModel: BaseExplore.LoadContent.ViewModel) {
        self.updateState(newState: viewModel.state)
    }

    func displayFullscreenCourseList(
        viewModel: BaseExplore.PresentFullscreenCourseListModule.ViewModel
    ) {
        let assembly = FullscreenCourseListAssembly(courseListType: viewModel.courseListType)
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayCourseInfo(viewModel: BaseExplore.PresentCourseInfo.ViewModel) {
        let assembly = CourseInfoLegacyAssembly(course: viewModel.course)
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayCourseSyllabus(viewModel: BaseExplore.PresentCourseSyllabus.ViewModel) {
        let assembly = SyllabusLegacyAssembly(course: viewModel.course)
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayLastStep(viewModel: BaseExplore.PresentLastStep.ViewModel) {
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
