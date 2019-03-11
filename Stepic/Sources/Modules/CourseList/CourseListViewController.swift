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
    func displayCourses(viewModel: CourseList.CoursesLoad.ViewModel)
    func displayNextCourses(viewModel: CourseList.NextCoursesLoad.ViewModel)
    func displayBlockingLoadingIndicator(viewModel: CourseList.BlockingWaitingIndicatorUpdate.ViewModel)
}

protocol CourseListViewControllerDelegate: class {
    func itemDidSelected(viewModel: CourseWidgetViewModel)
    func primaryButtonClicked(viewModel: CourseWidgetViewModel)
    func secondaryButtonClicked(viewModel: CourseWidgetViewModel)
}

class CourseListViewController: UIViewController {
    let interactor: CourseListInteractorProtocol

    private var state: CourseList.ViewControllerState

    let listDelegate: CourseListCollectionViewDelegate
    let listDataSource: CourseListCollectionViewDataSource

    lazy var courseListView = self.view as? CourseListView

    let colorMode: CourseListColorMode
    private var canTriggerPagination = true

    fileprivate init(
        interactor: CourseListInteractorProtocol,
        initialState: CourseList.ViewControllerState = .loading,
        colorMode: CourseListColorMode = .default,
        maxNumberOfDisplayedCourses: Int? = nil
    ) {
        self.interactor = interactor
        self.state = initialState
        self.colorMode = colorMode

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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateState(newState: self.state)
        self.interactor.doCoursesFetch(request: .init())
    }

    func updatePagination(hasNextPage: Bool, hasError: Bool) {
        self.canTriggerPagination = hasNextPage
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
}

extension CourseListViewController: CourseListViewControllerProtocol {
    func displayCourses(viewModel: CourseList.CoursesLoad.ViewModel) {
        if case .result(let data) = viewModel.state {
            self.listDataSource.viewModels = data.courses
            self.listDelegate.viewModels = data.courses
            self.updateState(newState: viewModel.state)
            self.updatePagination(hasNextPage: data.hasNextPage, hasError: false)
        }
    }

    func displayNextCourses(viewModel: CourseList.NextCoursesLoad.ViewModel) {
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

    func displayBlockingLoadingIndicator(viewModel: CourseList.BlockingWaitingIndicatorUpdate.ViewModel) {
        if viewModel.shouldDismiss {
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.show()
        }
    }
}

extension CourseListViewController: CourseListViewDelegate {
    func courseListViewDidPaginationRequesting(_ courseListView: CourseListView) {
        guard self.canTriggerPagination else {
            return
        }

        self.canTriggerPagination = false
        self.interactor.doNextCoursesFetch(request: CourseList.NextCoursesLoad.Request())
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

final class HorizontalCourseListViewController: CourseListViewController {
    override init(
        interactor: CourseListInteractorProtocol,
        initialState: CourseList.ViewControllerState = .loading,
        colorMode: CourseListColorMode = .default,
        maxNumberOfDisplayedCourses: Int? = nil
    ) {
        super.init(
            interactor: interactor,
            initialState: initialState,
            colorMode: colorMode,
            maxNumberOfDisplayedCourses: maxNumberOfDisplayedCourses
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
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
    }
}

final class VerticalCourseListViewController: CourseListViewController {
    private let presentationDescription: CourseList.PresentationDescription?
    lazy var verticalCourseListView = self.courseListView as? VerticalCourseListView

    init(
        interactor: CourseListInteractorProtocol,
        initialState: CourseList.ViewControllerState = .loading,
        colorMode: CourseListColorMode = .default,
        presentationDescription: CourseList.PresentationDescription?
    ) {
        self.presentationDescription = presentationDescription
        super.init(
            interactor: interactor,
            initialState: initialState,
            colorMode: colorMode,
            maxNumberOfDisplayedCourses: nil
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = VerticalCourseListView(
            frame: UIScreen.main.bounds,
            columnsCount: 1,
            colorMode: self.colorMode,
            delegate: self.listDelegate,
            dataSource: self.listDataSource,
            viewDelegate: self,
            isHeaderViewHidden: self.presentationDescription == nil
        )

        if let presentationDescription = self.presentationDescription {
            let headerView = GradientCoursesPlaceholderViewFactory().makeFullscreenView(
                title: presentationDescription.title,
                subtitle: presentationDescription.subtitle,
                color: presentationDescription.color
            )
            view.headerView = headerView
        }

        let paginationView = PaginationView()
        paginationView.onRefreshButtonClick = { [weak self] in
            self?.interactor.doNextCoursesFetch(request: .init())
        }
        view.paginationView = paginationView

        self.view = view
    }

    override func updatePagination(hasNextPage: Bool, hasError: Bool) {
        super.updatePagination(hasNextPage: hasNextPage, hasError: hasError)

        verticalCourseListView?.isPaginationViewHidden = !hasNextPage

        guard let paginationView = verticalCourseListView?.paginationView as? PaginationView else {
            return
        }

        if hasError {
            paginationView.setError()
        } else {
            paginationView.setLoading()
        }
    }
}
