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
}

final class CourseInfoTabSyllabusPresenter: CourseInfoTabSyllabusPresenterProtocol {
    weak var viewController: CourseInfoTabSyllabusViewControllerProtocol?

    func presentCourseSyllabus(response: CourseInfoTabSyllabus.ShowSyllabus.Response) {
        var viewModel: CourseInfoTabSyllabus.ShowSyllabus.ViewModel

        switch response.result {
        case let .success(result):
            let sectionViewModels = result.sections.enumerated().map {
                sectionData -> CourseInfoTabSyllabusSectionViewModel in

                var currentSectionUnitViewModels: [CourseInfoTabSyllabusUnitViewModel] = []
                let (uid, section) = sectionData.element

                for unitID in section.unitsArray {
                    let unit = result.units.first(where: { $0.1?.id == unitID })?.1
                    currentSectionUnitViewModels.append(self.makeUnitViewModel(uid: "", unit: unit))
                }

                return self.makeSectionViewModel(
                    index: sectionData.offset,
                    uid: uid,
                    section: section,
                    units: currentSectionUnitViewModels
                )
            }

            viewModel = CourseInfoTabSyllabus.ShowSyllabus.ViewModel(state: .result(data: sectionViewModels))
        default:
            viewModel = CourseInfoTabSyllabus.ShowSyllabus.ViewModel(state: .loading)
        }

        viewController?.displaySyllabus(viewModel: viewModel)
    }

    private func makeSectionViewModel(
        index: Int,
        uid: UniqueIdentifierType,
        section: Section,
        units: [CourseInfoTabSyllabusUnitViewModel]
    ) -> CourseInfoTabSyllabusSectionViewModel {
        let viewModel = CourseInfoTabSyllabusSectionViewModel(
            uniqueIdentifier: uid,
            index: "\(index + 1)",
            title: section.title,
            progress: (section.progress?.percentPassed ?? 0) / 100.0,
            units: units
        )
        return viewModel
    }

    private func makeUnitViewModel(
        uid: UniqueIdentifierType,
        unit: Unit?
    ) -> CourseInfoTabSyllabusUnitViewModel {
        let likesCount = unit?.lesson?.voteDelta ?? 0

        let viewModel = CourseInfoTabSyllabusUnitViewModel(
            title: unit?.lesson?.title ?? "LOADING",
            coverImageURL: URL(string: unit?.lesson?.coverURL ?? ""),
            progress: (unit?.progress?.percentPassed ?? 0) / 100,
            likesCount: likesCount == 0 ? nil : likesCount,
            learnersLabelText: "\(unit?.lesson?.passedBy ?? 0)",
            progressLabelText: "\(unit?.progress?.numberOfStepsPassed ?? 0)/\(unit?.progress?.numberOfSteps)"
        )
        return viewModel
    }
}
