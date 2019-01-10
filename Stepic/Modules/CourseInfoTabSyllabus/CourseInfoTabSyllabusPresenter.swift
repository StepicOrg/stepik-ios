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

                var currentSectionUnitViewModels: [CourseInfoTabSyllabusSectionViewModel.UnitViewModelWrapper] = []

                for (unitIndex, unitID) in sectionData.element.entity.unitsArray.enumerated() {
                    if let matchedUnitRecord = result.units.first(where: { $0.entity?.id == unitID }),
                       let unit = matchedUnitRecord.entity {
                        currentSectionUnitViewModels.append(
                            self.makeUnitViewModel(
                                sectionIndex: sectionData.offset,
                                unitIndex: unitIndex,
                                uid: matchedUnitRecord.uniqueIdentifier,
                                unit: unit,
                                downloadState: matchedUnitRecord.downloadState,
                                isAvailable: result.isEnrolled
                            )
                        )
                    } else {
                        currentSectionUnitViewModels.append(.placeholder)
                    }
                }

                let hasPlaceholderUnits = currentSectionUnitViewModels.contains(
                    where: { unit in
                        if case .normal(_) = unit {
                            return false
                        }
                        return true
                    }
                )

                return self.makeSectionViewModel(
                    index: sectionData.offset,
                    uid: sectionData.element.uniqueIdentifier,
                    section: sectionData.element.entity,
                    units: currentSectionUnitViewModels,
                    downloadState: hasPlaceholderUnits || !result.isEnrolled
                        ? .notAvailable
                        : sectionData.element.downloadState
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
        units: [CourseInfoTabSyllabusSectionViewModel.UnitViewModelWrapper],
        downloadState: CourseInfoTabSyllabus.DownloadState
    ) -> CourseInfoTabSyllabusSectionViewModel {
        let deadlines = self.makeDeadlinesViewModel(section: section)

        let viewModel = CourseInfoTabSyllabusSectionViewModel(
            uniqueIdentifier: uid,
            index: "\(index + 1)",
            title: section.title,
            progress: (section.progress?.percentPassed ?? 0) / 100.0,
            units: units,
            deadlines: deadlines,
            downloadState: downloadState,
            isDisabled: !section.isReachable
        )

        self.cachedSectionViewModels[section.id] = viewModel

        return viewModel
    }

    private func makeUnitViewModel(
        sectionIndex: Int,
        unitIndex: Int,
        uid: UniqueIdentifierType,
        unit: Unit,
        downloadState: CourseInfoTabSyllabus.DownloadState,
        isAvailable: Bool
    ) -> CourseInfoTabSyllabusSectionViewModel.UnitViewModelWrapper {
        guard let lesson = unit.lesson else {
            return .placeholder
        }

        let likesCount = lesson.voteDelta
        let coverImageURL: URL? = {
            if let url = lesson.coverURL {
                return URL(string: url)
            } else {
                return nil
            }
        }()

        let progressLabelText: String? = {
            guard let progress = unit.progress else {
                return nil
            }

            return "\(progress.numberOfStepsPassed)/\(progress.numberOfSteps)"
        }()

        let viewModel = CourseInfoTabSyllabusUnitViewModel(
            uniqueIdentifier: uid,
            title: "\(sectionIndex + 1).\(unitIndex + 1) \(lesson.title)",
            coverImageURL: coverImageURL,
            progress: (unit.progress?.percentPassed ?? 0) / 100,
            likesCount: likesCount == 0 ? nil : likesCount,
            learnersLabelText: FormatterHelper.longNumber(lesson.passedBy),
            progressLabelText: progressLabelText,
            downloadState: isAvailable ? downloadState : .notAvailable,
            isSelectable: isAvailable
        )

        self.cachedUnitViewModels[unit.id] = viewModel

        return .normal(viewModel: viewModel)
    }

    private func makeDeadlinesViewModel(
        section: Section
    ) -> CourseInfoTabSyllabusSectionDeadlinesViewModel? {
        let dates: [(title: String, date: Date)] = [
            (title: NSLocalizedString("BeginDate", comment: ""), date: section.beginDate),
            (title: NSLocalizedString("SoftDeadline", comment: ""), date: section.softDeadline),
            (title: NSLocalizedString("HardDeadline", comment: ""), date: section.hardDeadline),
            (title: NSLocalizedString("EndDate", comment: ""), date: section.endDate)
        ].filter { $0.date != nil }.compactMap { ($0.title, $0.date!) }

        if dates.isEmpty {
            return nil
        }

        var previousDate: Date?
        let items: [CourseInfoTabSyllabusSectionDeadlinesViewModel.TimelineItem] = dates.map { item in
            defer {
                previousDate = item.date
            }

            let formattedDate = FormatterHelper.dateStringWithFullMonthAndYear(item.date)

            let nowDate = Date()
            var lineFillingProgress: Float = 0.0
            var isPointFilled = false

            switch nowDate.compare(item.date) {
            case .orderedDescending, .orderedSame:
                // Today >= date
                lineFillingProgress = 1.0
                isPointFilled = true
            case .orderedAscending:
                // Today < date
                isPointFilled = false

                if let previousDate = previousDate {
                    let timeBetweenDates = item.date.timeIntervalSinceReferenceDate
                        - previousDate.timeIntervalSinceReferenceDate
                    let timeAfterPreviousDate = nowDate.timeIntervalSinceReferenceDate
                        - previousDate.timeIntervalSinceReferenceDate

                    lineFillingProgress = Float(max(0, timeAfterPreviousDate) / timeBetweenDates)
                } else {
                    lineFillingProgress = 0
                }
            }

            return .init(
                title: "\(item.title)\n\(formattedDate)",
                lineFillingProgress: lineFillingProgress,
                isPointFilled: isPointFilled
            )
        }

        return .init(timelineItems: items)
    }
}
