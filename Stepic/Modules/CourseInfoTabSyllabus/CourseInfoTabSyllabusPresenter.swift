//
//  CourseInfoTabSyllabusCourseInfoTabSyllabusPresenter.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright 2018 stepik-ios. All rights reserved.
//

import UIKit

protocol CourseInfoTabSyllabusPresenterProtocol {
    func presentCourseSyllabus(response: CourseInfoTabSyllabus.ShowSyllabus.Response)
    func presentDownloadButtonUpdate(response: CourseInfoTabSyllabus.DownloadButtonStateUpdate.Response)
}

final class CourseInfoTabSyllabusPresenter: CourseInfoTabSyllabusPresenterProtocol {
    weak var viewController: CourseInfoTabSyllabusViewControllerProtocol?

    private var cachedSectionViewModels: [Section.IdType: CourseInfoTabSyllabusSectionViewModel] = [:]
    private var cachedUnitViewModels: [Unit.IdType: CourseInfoTabSyllabusUnitViewModel] = [:]

    func presentCourseSyllabus(response: CourseInfoTabSyllabus.ShowSyllabus.Response) {
        var viewModel: CourseInfoTabSyllabus.ShowSyllabus.ViewModel

        switch response.result {
        case let .success(result):
            let sectionViewModels = result.sections.enumerated().map {
                sectionData -> CourseInfoTabSyllabusSectionViewModel in

                var currentSectionUnitViewModels: [CourseInfoTabSyllabusUnitViewModel] = []

                for unitID in sectionData.element.entity.unitsArray {
                    let matchedUnitRecord = result.units.first(where: { $0.entity?.id == unitID })
                    currentSectionUnitViewModels.append(
                        self.makeUnitViewModel(
                            uid: matchedUnitRecord?.uniqueIdentifier ?? "",
                            unit: matchedUnitRecord?.entity,
                            downloadState: matchedUnitRecord?.downloadState ?? .notAvailable
                        )
                    )
                }

                return self.makeSectionViewModel(
                    index: sectionData.offset,
                    uid: sectionData.element.uniqueIdentifier,
                    section: sectionData.element.entity,
                    units: currentSectionUnitViewModels,
                    downloadState: sectionData.element.downloadState
                )
            }

            viewModel = CourseInfoTabSyllabus.ShowSyllabus.ViewModel(state: .result(data: sectionViewModels))
        default:
            viewModel = CourseInfoTabSyllabus.ShowSyllabus.ViewModel(state: .loading)
        }

        self.viewController?.displaySyllabus(viewModel: viewModel)
    }

    func presentDownloadButtonUpdate(
        response: CourseInfoTabSyllabus.DownloadButtonStateUpdate.Response
    ) {
        switch response.source {
        case .section(let section):
            self.cachedSectionViewModels[section.id]?.downloadState = response.downloadState
            if let cachedViewModel = self.cachedSectionViewModels[section.id] {
                let viewModel = CourseInfoTabSyllabus.DownloadButtonStateUpdate.ViewModel(
                    data: .section(viewModel: cachedViewModel)
                )
                self.viewController?.displayDownloadButtonStateUpdate(viewModel: viewModel)
            }
        case .unit(let unit):
            self.cachedUnitViewModels[unit.id]?.downloadState = response.downloadState
            if let cachedViewModel = self.cachedUnitViewModels[unit.id] {
                let viewModel = CourseInfoTabSyllabus.DownloadButtonStateUpdate.ViewModel(
                    data: .unit(viewModel: cachedViewModel)
                )
                self.viewController?.displayDownloadButtonStateUpdate(viewModel: viewModel)
            }
        }
    }

    private func makeSectionViewModel(
        index: Int,
        uid: UniqueIdentifierType,
        section: Section,
        units: [CourseInfoTabSyllabusUnitViewModel],
        downloadState: CourseInfoTabSyllabus.DownloadState
    ) -> CourseInfoTabSyllabusSectionViewModel {
        let viewModel = CourseInfoTabSyllabusSectionViewModel(
            uniqueIdentifier: uid,
            index: "\(index + 1)",
            title: section.title,
            progress: (section.progress?.percentPassed ?? 0) / 100.0,
            units: units,
            downloadState: downloadState
        )

        self.cachedSectionViewModels[section.id] = viewModel

        return viewModel
    }

    private func makeUnitViewModel(
        uid: UniqueIdentifierType,
        unit: Unit?,
        downloadState: CourseInfoTabSyllabus.DownloadState
    ) -> CourseInfoTabSyllabusUnitViewModel {
        let likesCount = unit?.lesson?.voteDelta ?? 0

        let viewModel = CourseInfoTabSyllabusUnitViewModel(
            uniqueIdentifier: uid,
            title: unit?.lesson?.title ?? "LOADING",
            coverImageURL: URL(string: unit?.lesson?.coverURL ?? ""),
            progress: (unit?.progress?.percentPassed ?? 0) / 100,
            likesCount: likesCount == 0 ? nil : likesCount,
            learnersLabelText: "\(unit?.lesson?.passedBy ?? 0)",
            progressLabelText: "\(unit?.progress?.numberOfStepsPassed ?? 0)/\(unit?.progress?.numberOfSteps)",
            downloadState: downloadState
        )

        if let unit = unit {
            self.cachedUnitViewModels[unit.id] = viewModel
        }

        return viewModel
    }
}
