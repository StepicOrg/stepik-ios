//
//  CourseListViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

protocol CourseListViewControllerProtocol: class {
    func displayCourses(viewModel: CourseList.ShowCourses.ViewModel)
    func displayNextCourses(viewModel: CourseList.LoadNextCourses.ViewModel)
}

protocol CourseListViewControllerDelegate: class {
    func itemDidSelected(viewModel: CourseWidgetViewModel)
}

final class CourseListViewController: UIViewController {
    let interactor: CourseListInteractorProtocol
    weak var moduleOutput: CourseListOutputProtocol?

    var state: CourseList.ViewControllerState

    private let listDelegate: CourseListCollectionViewDelegate
    private let listDataSource: CourseListCollectionViewDataSource

    lazy var courseListView = self.view as? CourseListView

    private let colorMode: CourseListColorMode
    private var canTriggerPagination = true

    init(
        interactor: CourseListInteractorProtocol,
        initialState: CourseList.ViewControllerState = .loading,
        colorMode: CourseListColorMode = .default,
    ) {
        self.interactor = interactor
        self.state = initialState
        self.colorMode = colorMode

        self.listDelegate = CourseListCollectionViewDelegate()
        self.listDataSource = CourseListCollectionViewDataSource()

        super.init(nibName: nil, bundle: nil)

        self.listDelegate.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CourseListView(
            frame: UIScreen.main.bounds,
            colorMode: self.colorMode,
            orientation: .horizontal(rowsCount: 2, columnsCount: 1),
            delegate: self.listDelegate,
            dataSource: self.listDataSource,
            viewDelegate: self
        )
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactor.fetchCourses(request: CourseList.ShowCourses.Request())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func updatePagination(hasNextPage: Bool) {
        self.courseListView?.isPaginationViewHidden = !hasNextPage
        self.canTriggerPagination = hasNextPage
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
}
