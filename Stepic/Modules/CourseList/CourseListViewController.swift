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
    func displayJoinCourseCompletion(viewModel: CourseList.JoinCourse.ViewModel)
}

protocol CourseListViewControllerDelegate: class {
    func itemDidSelected(viewModel: CourseWidgetViewModel)
    func primaryButtonClicked(viewModel: CourseWidgetViewModel)
    func secondaryButtonClicked(viewModel: CourseWidgetViewModel)
}

final class CourseListViewController: UIViewController {
    let interactor: CourseListInteractorProtocol
    weak var moduleOutput: CourseListOutputProtocol?

    var state: CourseList.ViewControllerState

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
        orientation: PresentationOrientation
    ) {
        self.interactor = interactor
        self.state = initialState
        self.colorMode = colorMode
        self.orientation = orientation

        self.listDelegate = CourseListCollectionViewDelegate()
        self.listDataSource = CourseListCollectionViewDataSource()

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
        self.interactor.fetchCourses(request: CourseList.ShowCourses.Request())
    }

    private func updatePagination(hasNextPage: Bool) {
        if let verticalCourseListView = self.courseListView as? VerticalCourseListView {
            verticalCourseListView.isPaginationViewHidden = !hasNextPage
        }
        self.canTriggerPagination = hasNextPage
    }

    enum PresentationOrientation {
        case horizontal
        case vertical
    }
}

extension CourseListViewController: CourseListViewControllerProtocol {
    func displayCourses(viewModel: CourseList.ShowCourses.ViewModel) {
        switch viewModel.state {
        case .result(let data):
            self.listDataSource.viewModels = data.courses
            self.listDelegate.viewModels = data.courses
            self.courseListView?.updateCollectionViewData(
                delegate: self.listDelegate,
                dataSource: self.listDataSource
            )
            self.updatePagination(hasNextPage: data.hasNextPage)
        default:
            break
        }
    }

    func displayNextCourses(viewModel: CourseList.LoadNextCourses.ViewModel) {
        switch viewModel.state {
        case .result(let data):
            self.listDataSource.viewModels.append(contentsOf: data.courses)
            self.listDelegate.viewModels.append(contentsOf: data.courses)
            self.courseListView?.updateCollectionViewData(
                delegate: self.listDelegate,
                dataSource: self.listDataSource
            )
            self.updatePagination(hasNextPage: data.hasNextPage)
        default:
            break
        }
    }

    func displayJoinCourseCompletion(viewModel: CourseList.JoinCourse.ViewModel) {
        SVProgressHUD.dismiss()

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
    }

    func primaryButtonClicked(viewModel: CourseWidgetViewModel) {
        self.interactor.joinCourse(request: .init(id: viewModel.courseId))
        SVProgressHUD.show()
    }

    func secondaryButtonClicked(viewModel: CourseWidgetViewModel) {
        print(viewModel)
    }
}
