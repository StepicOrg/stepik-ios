//
//  CourseInfoTabSyllabusCourseInfoTabSyllabusViewController.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright 2018 stepik-ios. All rights reserved.
//

import UIKit

protocol CourseInfoTabSyllabusViewControllerProtocol: class {
    func displaySyllabus(viewModel: CourseInfoTabSyllabus.ShowSyllabus.ViewModel)
}

protocol CourseInfoTabSyllabusViewControllerDelegate: class {
    func sectionWillDisplay(_ section: CourseInfoTabSyllabusSectionViewModel)
    func downloadButtonDidClick(_ cell: CourseInfoTabSyllabusUnitViewModel)
    func downloadButtonDidClick(_ cell: CourseInfoTabSyllabusSectionViewModel)
}

final class CourseInfoTabSyllabusViewController: UIViewController {
    let interactor: CourseInfoTabSyllabusInteractorProtocol
    private var state: CourseInfoTabSyllabus.ViewControllerState

    private let syllabusTableDelegate: CourseInfoTabSyllabusTableViewDelegate

    lazy var courseInfoTabSyllabusView = self.view as? CourseInfoTabSyllabusView

    init(
        interactor: CourseInfoTabSyllabusInteractorProtocol,
        initialState: CourseInfoTabSyllabus.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState
        self.syllabusTableDelegate = CourseInfoTabSyllabusTableViewDelegate()

        super.init(nibName: nil, bundle: nil)
        self.syllabusTableDelegate.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = CourseInfoTabSyllabusView(
            frame: UIScreen.main.bounds,
            tableViewDelegate: self.syllabusTableDelegate
        )
    }
}

extension CourseInfoTabSyllabusViewController: CourseInfoTabSyllabusViewControllerProtocol {
    func displaySyllabus(viewModel: CourseInfoTabSyllabus.ShowSyllabus.ViewModel) {
        switch viewModel.state {
        case .loading:
            break
        case .result(let data):
            self.syllabusTableDelegate.viewModels = data
            self.courseInfoTabSyllabusView?.updateTableViewData(delegate: self.syllabusTableDelegate)
        }
    }
}

extension CourseInfoTabSyllabusViewController: CourseInfoTabSyllabusViewControllerDelegate {
    func sectionWillDisplay(_ section: CourseInfoTabSyllabusSectionViewModel) {
        self.interactor.fetchSyllabusSection(
            request: .init(uniqueIdentifier: section.uniqueIdentifier)
        )
    }

    func downloadButtonDidClick(_ cell: CourseInfoTabSyllabusUnitViewModel) {
        self.interactor.doDownloadButtonAction(
            request: .init(type: .unit(uniqueIdentifier: cell.uniqueIdentifier))
        )
    }

    func downloadButtonDidClick(_ cell: CourseInfoTabSyllabusSectionViewModel) {
        self.interactor.doDownloadButtonAction(
            request: .init(type: .section(uniqueIdentifier: cell.uniqueIdentifier))
        )
    }
}
