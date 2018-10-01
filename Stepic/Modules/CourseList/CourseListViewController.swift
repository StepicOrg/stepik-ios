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
        switch self.orientation {
        case .horizontal:
            let view = HorizontalCourseListView(
                frame: UIScreen.main.bounds,
                columnsCount: 1,
                rowsCount: 2,
                colorMode: self.colorMode,
                delegate: self.listDelegate,
                dataSource: self.listDataSource,
                viewDelegate: self
            )
            self.view = view
        case .vertical:
            let view = VerticalCourseListView(
                frame: UIScreen.main.bounds,
                columnsCount: 1,
                colorMode: self.colorMode,
                delegate: self.listDelegate,
                dataSource: self.listDataSource,
                viewDelegate: self,
                isHeaderViewHidden: false
            )

            let headerView = GradientCoursesPlaceholderView(frame: .zero, color: .blue)
            headerView.titleText = NSAttributedString(string: "Текст какой-то")
            headerView.subtitleText = NSAttributedString(string: "Подтекст")
            view.headerView = headerView

            let paginationView = PaginationView(frame: .zero)
            paginationView.onRefreshButtonClick = { [weak self] in
                self?.interactor.fetchNextCourses(request: .init())
            }
            view.paginationView = paginationView

            self.view = view
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateState(newState: self.state)
        self.interactor.fetchCourses(request: .init())
    }

    private func updatePagination(hasNextPage: Bool, hasError: Bool) {
        defer {
            self.canTriggerPagination = hasNextPage
        }
        guard let verticalCourseListView = self.courseListView as? VerticalCourseListView else {
            return
        }

        verticalCourseListView.isPaginationViewHidden = !hasNextPage

        guard let paginationView = verticalCourseListView.paginationView as? PaginationView else {
            return
        }

        if hasError {
            paginationView.setError()
        } else {
            paginationView.setLoading()
        }
    }

    private func updateState(newState: CourseList.ViewControllerState) {
        if case .result(_) = newState {
            self.courseListView?.hideLoading()
            self.courseListView?.updateCollectionViewData(
                delegate: self.listDelegate,
                dataSource: self.listDataSource
            )
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
            self.updateState(newState: viewModel.state)
            self.updatePagination(hasNextPage: data.hasNextPage, hasError: false)
        }
    }

    func displayNextCourses(viewModel: CourseList.LoadNextCourses.ViewModel) {
        switch viewModel.state {
        case .result(let data):
            self.listDataSource.viewModels.append(contentsOf: data.courses)
            self.listDelegate.viewModels.append(contentsOf: data.courses)
            self.updateState(newState: self.state)
            self.updatePagination(hasNextPage: data.hasNextPage, hasError: false)
        case .error:
            self.updateState(newState: self.state)
            self.updatePagination(hasNextPage: false, hasError: true)
        }
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
