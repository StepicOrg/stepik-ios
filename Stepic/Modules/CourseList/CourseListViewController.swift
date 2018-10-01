//
//  CourseListViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol CourseListViewControllerProtocol: class {
    func displayCourses(viewModel: CourseList.ShowCourses.ViewModel)
    func displayNextCourses(viewModel: CourseList.LoadNextCourses.ViewModel)

    func hideBlockingLoadingIndicator()
    func showBlockingLoadingIndicator()
}

protocol CourseListViewControllerDelegate: class {
    func itemDidSelected(viewModel: CourseWidgetViewModel)
    func primaryButtonClicked(viewModel: CourseWidgetViewModel)
    func secondaryButtonClicked(viewModel: CourseWidgetViewModel)
}

final class CourseListViewController: UIViewController {
    let interactor: CourseListInteractorProtocol

    private var state: CourseList.ViewControllerState

    private let listDelegate: CourseListCollectionViewDelegate
    private let listDataSource: CourseListCollectionViewDataSource

    lazy var courseListView = self.view as? CourseListView

    private let colorMode: CourseListColorMode
    private let orientation: PresentationOrientation
    private var canTriggerPagination = true

    init(
        interactor: CourseListInteractorProtocol,
        initialState: CourseList.ViewControllerState = .loading,
        colorMode: CourseListColorMode = .default,
        orientation: PresentationOrientation,
        maxNumberOfDisplayedCourses: Int? = nil
    ) {
        self.interactor = interactor
        self.state = initialState
        self.colorMode = colorMode
        self.orientation = orientation

        self.listDelegate = CourseListCollectionViewDelegate()
        self.listDataSource = CourseListCollectionViewDataSource(
            maxNumberOfDisplayedCourses: maxNumberOfDisplayedCourses
        )

        super.init(nibName: nil, bundle: nil)

        self.listDelegate.delegate = self
        self.listDataSource.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        var view: UIView
        switch self.orientation {
        case .horizontal:
            view = HorizontalCourseListView(
                frame: UIScreen.main.bounds,
                columnsCount: 1,
                rowsCount: 2,
                colorMode: self.colorMode,
                delegate: self.listDelegate,
                dataSource: self.listDataSource,
                viewDelegate: self
            )
        case .vertical:
            view = VerticalCourseListView(
                frame: UIScreen.main.bounds,
                columnsCount: 1,
                colorMode: self.colorMode,
                delegate: self.listDelegate,
                dataSource: self.listDataSource,
                viewDelegate: self
            )
        }
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateState(newState: self.state)
        self.interactor.fetchCourses(request: .init())
    }

    private func updatePagination(hasNextPage: Bool) {
        if let verticalCourseListView = self.courseListView as? VerticalCourseListView {
            verticalCourseListView.isPaginationViewHidden = !hasNextPage
        }
        self.canTriggerPagination = hasNextPage
    }

    private func updateState(newState: CourseList.ViewControllerState) {
        if case .result(let data) = newState {
            self.courseListView?.hideLoading()
            self.courseListView?.updateCollectionViewData(
                delegate: self.listDelegate,
                dataSource: self.listDataSource
            )
            self.updatePagination(hasNextPage: data.hasNextPage)
        } else {
            self.courseListView?.showLoading()
        }
        self.state = newState
    }

    enum PresentationOrientation {
        case horizontal
        case vertical
    }
}

extension CourseListViewController: CourseListViewControllerProtocol {
    func displayCourses(viewModel: CourseList.ShowCourses.ViewModel) {
        if case .result(let data) = viewModel.state {
            self.listDataSource.viewModels = data.courses
            self.listDelegate.viewModels = data.courses
        }
        self.updateState(newState: viewModel.state)
    }

    func displayNextCourses(viewModel: CourseList.LoadNextCourses.ViewModel) {
        if case .result(let data) = viewModel.state {
            self.listDataSource.viewModels.append(contentsOf: data.courses)
            self.listDelegate.viewModels.append(contentsOf: data.courses)
        }
        self.updateState(newState: self.state)
    }

    func hideBlockingLoadingIndicator() {
        SVProgressHUD.dismiss()
    }

    func showBlockingLoadingIndicator() {
        SVProgressHUD.show()
    }
}

extension CourseListViewController: CourseListViewDelegate {
    func courseListViewDidPaginationRequesting(_ courseListView: CourseListView) {
        guard self.canTriggerPagination else {
            return
        }
        print("TRIGGER PAGINATION")

        self.canTriggerPagination = false
        self.interactor.fetchNextCourses(request: CourseList.LoadNextCourses.Request())
    }
}

extension CourseListViewController: CourseListViewControllerDelegate {
    func itemDidSelected(viewModel: CourseWidgetViewModel) {
        self.interactor.doMainAction(
            request: .init(viewModelUniqueIdentifier: viewModel.uniqueIdentifier)
        )
    }

    func primaryButtonClicked(viewModel: CourseWidgetViewModel) {
        self.interactor.doPrimaryAction(
            request: .init(viewModelUniqueIdentifier: viewModel.uniqueIdentifier)
        )
    }

    func secondaryButtonClicked(viewModel: CourseWidgetViewModel) {
        self.interactor.doSecondaryAction(
            request: .init(viewModelUniqueIdentifier: viewModel.uniqueIdentifier)
        )
    }
}
