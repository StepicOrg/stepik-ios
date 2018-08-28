//
//  CourseListViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

protocol CourseListViewControllerProtocol: class {

}

class CourseListViewController: UIViewController {
    let interactor: CourseListInteractorProtocol
    var state: CourseList.ViewControllerState

    init(interactor: CourseListInteractorProtocol, initialState: CourseList.ViewControllerState = .loading) {
        self.interactor = interactor
        self.state = initialState
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = UIView()
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension CourseListViewController: CourseListViewControllerProtocol {
    func display(newState: CourseList.ViewControllerState) {
        self.state = newState
        switch state {
        case .loading:
            print("loading...")
        case let .error(message):
            print("error \(message)")
        case let .result(items):
            print("result: \(items)")
        case .emptyResult:
            print("empty result")
        }
    }
}
