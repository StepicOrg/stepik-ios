//
//  CourseListsCollectionViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

protocol CourseListsCollectionViewControllerProtocol: class {
    func displayCourseLists(viewModel: CourseListsCollection.ShowCourseLists.ViewModel)
}

final class CourseListsCollectionViewController: UIViewController {
    let interactor: CourseListsCollectionInteractorProtocol

    lazy var courseListsCollectionView = self.view as? CourseListsCollectionView

    init(interactor: CourseListsCollectionInteractorProtocol) {
        self.interactor = interactor

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactor.fetchCourseLists(request: CourseListsCollection.ShowCourseLists.Request())
    }

    override func loadView() {
        let view = CourseListsCollectionView(frame: UIScreen.main.bounds)
        self.view = view
    }
}

extension CourseListsCollectionViewController: CourseListsCollectionViewControllerProtocol {
    func displayCourseLists(viewModel: CourseListsCollection.ShowCourseLists.ViewModel) {
        self.childViewControllers.forEach { $0.removeFromParentViewController() }
        self.courseListsCollectionView?.removeAllBlocks()

        switch viewModel.state {
        case .result(let data):
            for courseListViewModel in data {
                let assembly = HorizontalCourseListAssembly(
                    type: courseListViewModel.courseList,
                    colorMode: .light,
                    output: self.interactor as? CourseListOutputProtocol
                )
                let viewController = assembly.makeModule()
                assembly.moduleInput?.setOnlineStatus()
                self.addChildViewController(viewController)

                let containerView = CourseListContainerViewFactory()
                    .makeHorizontalCoursesCollectionContainerView(
                        for: viewController.view,
                        headerDescription: .init(
                            title: courseListViewModel.title,
                            summary: courseListViewModel.description,
                            description: "\(courseListViewModel.summary ?? "")",
                            color: courseListViewModel.color
                        )
                    )
                containerView.onShowAllButtonClick = { [weak self] in
                    self?.interactor.loadFullscreenCourseList(
                        request: .init(
                            presentationDescription: .init(
                                title: courseListViewModel.title,
                                subtitle: courseListViewModel.description,
                                color: courseListViewModel.color
                            ),
                            courseListType: courseListViewModel.courseList
                        )
                    )
                }
                self.courseListsCollectionView?.addBlockView(containerView)
            }
        default:
            break
        }
    }
}
