//
//  CourseInfoTabReviewsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/02/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import UIKit

protocol CourseInfoTabReviewsViewControllerProtocol: class {
    func displayReviews(viewModel: CourseInfoTabReviews.ShowReviews.ViewModel)
    func displayNextReviews(viewModel: CourseInfoTabReviews.LoadNextReviews.ViewModel)
}

final class CourseInfoTabReviewsViewController: UIViewController {
    let interactor: CourseInfoTabReviewsInteractorProtocol

    lazy var courseInfoTabReviewsView = self.view as? CourseInfoTabReviewsView

    private var state: CourseInfoTabReviews.ViewControllerState
    private var canTriggerPagination = true

    private let tableDataSource = CourseInfoTabReviewsTableViewDataSource()

    init(
        interactor: CourseInfoTabReviewsInteractorProtocol,
        initialState: CourseInfoTabReviews.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateState(newState: self.state)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = CourseInfoTabReviewsView()
    }

    private func updatePagination(hasNextPage: Bool, hasError: Bool) {
        self.canTriggerPagination = hasNextPage
    }

    private func updateState(newState: CourseInfoTabReviews.ViewControllerState) {
        if case .result(_) = newState {
            // self.courseInfoTabReviewsView?.hideLoading()
            self.courseInfoTabReviewsView?.updateTableViewData(dataSource: self.tableDataSource)
        } else {
            // self.courseInfoTabReviewsView?.showLoading()
        }
        self.state = newState
    }
}

extension CourseInfoTabReviewsViewController: CourseInfoTabReviewsViewControllerProtocol {
    func displayReviews(viewModel: CourseInfoTabReviews.ShowReviews.ViewModel) {
        switch viewModel.state {
        case .loading:
            break
        case .result(let data):
            self.tableDataSource.viewModels = data.reviews
            self.updatePagination(hasNextPage: data.hasNextPage, hasError: false)
        }
        self.updateState(newState: viewModel.state)
    }

    func displayNextReviews(viewModel: CourseInfoTabReviews.LoadNextReviews.ViewModel) {
        switch viewModel.state {
        case .result(let data):
            self.tableDataSource.viewModels.append(contentsOf: data.reviews)
            self.updatePagination(hasNextPage: data.hasNextPage, hasError: false)
        case .error:
            self.updatePagination(hasNextPage: false, hasError: true)
        }
        self.updateState(newState: self.state)
    }
}
