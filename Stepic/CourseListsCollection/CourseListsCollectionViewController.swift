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
        let assembly = CourseListAssembly(type: PopularCourseListType(language: .russian), colorMode: .light)
        let vc = assembly.makeModule()
        assembly.getModuleInput().reload()
        addChildViewController(vc)

        let view = CourseListsCollectionView(frame: UIScreen.main.bounds, contentView: vc.view)
        self.view = view
    }
}

extension CourseListsCollectionViewController: CourseListsCollectionViewControllerProtocol {
    func displayCourseLists(viewModel: CourseListsCollection.ShowCourseLists.ViewModel) {
        print(viewModel)
    }
}
