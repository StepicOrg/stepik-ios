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
        switch viewModel.state {
        case .result(let data):
            for courseListViewModel in data {
                let assembly = CourseListAssembly(type: PopularCourseListType(language: .russian), colorMode: .light)
                let vc = assembly.makeModule()
                assembly.moduleInput?.reload()
                self.addChildViewController(vc)

                let containerView = CourseListContainerViewFactory()
                    .makeHorizontalCoursesCollectionContainerView(
                        for: vc.view,
                        headerDescription: .init(
                            title: courseListViewModel.title,
                            summary: "\(courseListViewModel.courseList.ids.count) курсов",
                            description: "\(courseListViewModel.summary ?? "")"
                        )
                    )
                courseListsCollectionView?.addBlockView(containerView)
            }
        default:
            break
        }
    }
}
