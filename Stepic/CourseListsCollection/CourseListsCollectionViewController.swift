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
                let view = ExploreCoursesCollectionHeaderView(frame: .zero)
                view.titleText = courseListViewModel.title
                view.summaryText = "\(courseListViewModel.courseList.ids.count) курсов"
                view.descriptionText = "\(courseListViewModel.summary ?? "")"

                let assembly = CourseListAssembly(type: PopularCourseListType(language: .russian), colorMode: .light)
                let vc = assembly.makeModule()
                assembly.getModuleInput().reload()
                self.addChildViewController(vc)
                let container = ExploreBlockContainerView(
                    frame: .zero,
                    headerView: view,
                    contentView: vc.view,
                    shouldShowSeparator: false
                )

                courseListsCollectionView?.addBlockView(container)
            }
        default:
            break
        }
    }
}
