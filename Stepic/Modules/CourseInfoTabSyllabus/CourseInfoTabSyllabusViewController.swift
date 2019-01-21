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
    func displayDownloadButtonStateUpdate(viewModel: CourseInfoTabSyllabus.DownloadButtonStateUpdate.ViewModel)
    func displaySyllabusHeader(viewModel: CourseInfoTabSyllabus.UpdateSyllabusHeader.ViewModel)
}

protocol CourseInfoTabSyllabusViewControllerDelegate: class {
    func sectionWillDisplay(_ section: CourseInfoTabSyllabusSectionViewModel)
    func cellDidSelect(_ cell: CourseInfoTabSyllabusUnitViewModel)
    func downloadButtonDidClick(_ cell: CourseInfoTabSyllabusUnitViewModel)
    func downloadButtonDidClick(_ cell: CourseInfoTabSyllabusSectionViewModel)
}

final class CourseInfoTabSyllabusViewController: UIViewController {
    let interactor: CourseInfoTabSyllabusInteractorProtocol
    private var state: CourseInfoTabSyllabus.ViewControllerState

    private let syllabusTableDelegate: CourseInfoTabSyllabusTableViewDataSource

    lazy var courseInfoTabSyllabusView = self.view as? CourseInfoTabSyllabusView

    private lazy var personalDeadlinesTooltip = TooltipFactory.personalDeadlinesButton

    init(
        interactor: CourseInfoTabSyllabusInteractorProtocol,
        initialState: CourseInfoTabSyllabus.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState
        self.syllabusTableDelegate = CourseInfoTabSyllabusTableViewDataSource()

        super.init(nibName: nil, bundle: nil)
        self.syllabusTableDelegate.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let view = CourseInfoTabSyllabusView(
            frame: UIScreen.main.bounds,
            tableViewDelegate: self.syllabusTableDelegate
        )
        view.delegate = self
        self.view = view
    }
}

extension CourseInfoTabSyllabusViewController: CourseInfoTabSyllabusViewControllerProtocol {
    func displaySyllabusHeader(viewModel: CourseInfoTabSyllabus.UpdateSyllabusHeader.ViewModel) {
        guard let courseInfoTabSyllabusView = self.courseInfoTabSyllabusView else {
            return
        }

        if viewModel.data.isDeadlineButtonVisible && viewModel.data.isDeadlineTooltipVisible {
            // Cause anchor parent should have correct layout
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
                courseInfoTabSyllabusView.setNeedsLayout()
                courseInfoTabSyllabusView.layoutIfNeeded()
                self?.personalDeadlinesTooltip.show(
                    direction: .up,
                    in: courseInfoTabSyllabusView,
                    from: courseInfoTabSyllabusView.deadlinesButtonTooltipAnchorView
                )
            }
        }

        self.courseInfoTabSyllabusView?.configure(headerViewModel: viewModel.data)
    }

    func displaySyllabus(viewModel: CourseInfoTabSyllabus.ShowSyllabus.ViewModel) {
        switch viewModel.state {
        case .loading:
            break
        case .result(let data):
            self.syllabusTableDelegate.update(viewModels: data)
            self.courseInfoTabSyllabusView?.updateTableViewData(delegate: self.syllabusTableDelegate)
        }
    }

    func displayDownloadButtonStateUpdate(
        viewModel: CourseInfoTabSyllabus.DownloadButtonStateUpdate.ViewModel
    ) {
        switch viewModel.data {
        case .section(let viewModel):
            self.syllabusTableDelegate.mergeViewModel(section: viewModel)
        case .unit(let viewModel):
            self.syllabusTableDelegate.mergeViewModel(unit: viewModel)
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

    func cellDidSelect(_ cell: CourseInfoTabSyllabusUnitViewModel) {
        self.interactor.selectUnit(
            request: .init(uniqueIdentifier: cell.uniqueIdentifier)
        )
    }
}

extension CourseInfoTabSyllabusViewController: CourseInfoTabSyllabusViewDelegate {
    func courseInfoTabSyllabusViewDidClickDeadlines(_ courseInfoTabSyllabusView: CourseInfoTabSyllabusView) {
        self.interactor.handlePersonalDeadlinesAction()
    }

    func courseInfoTabSyllabusViewDidClickDownloadAll(_ courseInfoTabSyllabusView: CourseInfoTabSyllabusView) {

    }
}
