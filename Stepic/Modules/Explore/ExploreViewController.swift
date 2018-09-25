//
//  ExploreExploreViewController.swift
//  stepik-ios
//
//  Created by Stepik on 10/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol ExploreViewControllerProtocol: class {
    func displayContent(viewModel: Explore.LoadContent.ViewModel)
    func displayLanguageSwitchBlock(viewModel: Explore.CheckLanguageSwitchAvailability.ViewModel)
    func displayFullscreenCourseList(viewModel: Explore.PresentFullscreenCourseListModule.ViewModel)
    func displayCourseInfo(response: Explore.PresentCourseInfo.ViewModel)
    func displayCourseSyllabus(response: Explore.PresentCourseSyllabus.ViewModel)
}

final class ExploreViewController: UIViewController {
    let interactor: ExploreInteractorProtocol
    private var state: Explore.ViewControllerState
    private var submodules: [Submodule] = []

    lazy var exploreView = self.view as? ExploreView

    init(
        interactor: ExploreInteractorProtocol,
        initialState: Explore.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

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
        let view = ExploreView(frame: UIScreen.main.bounds)
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactor.loadLanguageSwitchBlock(request: .init())
        self.interactor.loadContent(request: .init())
    }

    // MARK: Private methods

    private func registerSubmodule(_ submodule: Submodule, insertionPosition: Int? = nil) {
        self.submodules.append(submodule)
        self.addChildViewController(submodule.viewController)

        let position = insertionPosition ?? self.submodules.count - 1
        if let view = submodule.view {
            self.exploreView?.insertBlockView(view, at: position)
        }
    }

    private func removeLanguageDependentSubmodules() {
        for submodule in self.submodules where submodule.isLanguageDependent {
            if let view = submodule.view {
                self.exploreView?.removeBlockView(view)
            }
            submodule.viewController.removeFromParentViewController()
        }
        self.submodules = self.submodules.filter { !$0.isLanguageDependent }
    }

    private func initLanguageDependentSubmodules(contentLanguage: ContentLanguage) {
        // Tags
        let tagsAssembly = TagsAssembly(
            contentLanguage: contentLanguage,
            output: self.interactor as? TagsOutputProtocol
        )
        let tagsViewController = tagsAssembly.makeModule()
        self.registerSubmodule(
            .init(
                viewController: tagsViewController,
                view: tagsViewController.view,
                isLanguageDependent: true
            )
        )

        // Collection
        let collectionAssembly = CourseListsCollectionAssembly(
            contentLanguage: contentLanguage,
            output: self.interactor
                as? (CourseListCollectionOutputProtocol & CourseListOutputProtocol)
        )
        let collectionViewController = collectionAssembly.makeModule()
        self.registerSubmodule(
            .init(
                viewController: collectionViewController,
                view: collectionViewController.view,
                isLanguageDependent: true
            )
        )

        // Popular courses
        let courseListType = PopularCourseListType(language: contentLanguage)
        let popularAssembly = CourseListAssembly(
            type: courseListType,
            colorMode: .dark,
            presentationOrientation: .horizontal,
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
                isLanguageDependent: true
            )
        )
    }

    private func registerForNotifications() {
        NotificationCenter.default.addObserver(
            forName: .contentLanguageDidChange,
            object: nil,
            queue: nil
        ) { _ in
            self.interactor.loadContent(request: .init())
        }
    }

    struct Submodule {
        let viewController: UIViewController
        let view: UIView?
        let isLanguageDependent: Bool
    }
}

extension ExploreViewController: ExploreViewControllerProtocol {
    func displayContent(viewModel: Explore.LoadContent.ViewModel) {
        switch viewModel.state {
        case .normal(let language):
            self.removeLanguageDependentSubmodules()
            self.initLanguageDependentSubmodules(contentLanguage: language)
        case .loading:
            break
        }
    }

    func displayLanguageSwitchBlock(viewModel: Explore.CheckLanguageSwitchAvailability.ViewModel) {
        if viewModel.isHidden {
            return
        }

        let contentLanguageSwitchAssembly = ContentLanguageSwitchAssembly()
        let viewController = contentLanguageSwitchAssembly.makeModule()
        self.registerSubmodule(
            .init(
                viewController: viewController,
                view: viewController.view,
                isLanguageDependent: false
            ),
            insertionPosition: 0
        )
    }

    func displayFullscreenCourseList(
        viewModel: Explore.PresentFullscreenCourseListModule.ViewModel
    ) {
        let assembly = FullscreenCourseListAssembly(courseListType: viewModel.courseListType)
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayCourseInfo(response: Explore.PresentCourseInfo.ViewModel) {
        let assembly = CourseInfoLegacyAssembly(course: response.course)
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func displayCourseSyllabus(response: Explore.PresentCourseSyllabus.ViewModel) {
        let assembly = SyllabusLegacyAssembly(course: response.course)
        let viewController = assembly.makeModule()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

@available(*, deprecated, message: "Class for backward compatibility")
fileprivate final class SyllabusLegacyAssembly: Assembly {
    private let course: Course

    init(course: Course) {
        self.course = course
    }

    func makeModule() -> UIViewController {
        let viewController = ControllerHelper.instantiateViewController(
            identifier: "SectionsViewController"
        ) as! SectionsViewController
        viewController.course = course
        viewController.hidesBottomBarWhenPushed = true
        return viewController
    }
}

@available(*, deprecated, message: "Class for backward compatibility")
fileprivate final class CourseInfoLegacyAssembly: Assembly {
    private let course: Course

    init(course: Course) {
        self.course = course
    }

    func makeModule() -> UIViewController {
        let viewController = ControllerHelper.instantiateViewController(
            identifier: "CoursePreviewViewController"
        ) as! CoursePreviewViewController
        viewController.course = course
        viewController.hidesBottomBarWhenPushed = true
        return viewController
    }
}
