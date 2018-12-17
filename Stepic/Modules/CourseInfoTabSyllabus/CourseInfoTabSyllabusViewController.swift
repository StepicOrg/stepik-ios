//
//  CourseInfoTabSyllabusCourseInfoTabSyllabusViewController.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright 2018 stepik-ios. All rights reserved.
//

import UIKit

protocol CourseInfoTabSyllabusViewControllerProtocol: class {

}

final class CourseInfoTabSyllabusViewController: UIViewController {
    let interactor: CourseInfoTabSyllabusInteractorProtocol
    private var state: CourseInfoTabSyllabus.ViewControllerState

    init(
        interactor: CourseInfoTabSyllabusInteractorProtocol,
        initialState: CourseInfoTabSyllabus.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = CourseInfoTabSyllabusView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension CourseInfoTabSyllabusViewController: CourseInfoTabSyllabusViewControllerProtocol {

}
