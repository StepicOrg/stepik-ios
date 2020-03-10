import UIKit

protocol CourseInfoTabSyllabusPresenterProtocol {
    func presentCourseSyllabus(response: CourseInfoTabSyllabus.SyllabusLoad.Response)
    func presentDownloadButtonUpdate(response: CourseInfoTabSyllabus.DownloadButtonStateUpdate.Response)
    func presentDeleteDownloadsConfirmationAlert(response: CourseInfoTabSyllabus.DeleteDownloadsConfirmation.Response)
    func presentCourseSyllabusHeader(response: CourseInfoTabSyllabus.SyllabusHeaderUpdate.Response)
    func presentWaitingState(response: CourseInfoTabSyllabus.BlockingWaitingIndicatorUpdate.Response)
    func presentFailedDownloadAlert(response: CourseInfoTabSyllabus.FailedDownloadAlertPresentation.Response)
    func presentDownloadOnCellularDataAlert(response: CourseInfoTabSyllabus.DownloadOnCellularDataAlert.Response)
}

final class CourseInfoTabSyllabusPresenter: CourseInfoTabSyllabusPresenterProtocol {
    weak var viewController: CourseInfoTabSyllabusViewControllerProtocol?

    private var cachedSectionViewModels: [Section.IdType: CourseInfoTabSyllabusSectionViewModel] = [:]
    private var cachedUnitViewModels: [Unit.IdType: CourseInfoTabSyllabusUnitViewModel] = [:]

    private var lastDateFailedAlertShown: Date?
    /// Allows to present alert once per minute.
    private var shouldPresentFailedAlert: Bool {
        Date().timeIntervalSince(self.lastDateFailedAlertShown ?? Date(timeIntervalSince1970: 0)) > 60
    }

    func presentCourseSyllabus(response: CourseInfoTabSyllabus.SyllabusLoad.Response) {
        var viewModel: CourseInfoTabSyllabus.SyllabusLoad.ViewModel

        switch response.result {
        case let .success(result):
            let sectionViewModels = result.sections.enumerated().map {
                sectionData -> CourseInfoTabSyllabusSectionViewModel in

                var currentSectionUnitViewModels: [CourseInfoTabSyllabusSectionViewModel.UnitViewModelWrapper] = []

                for (unitIndex, unitID) in sectionData.element.entity.unitsArray.enumerated() {
                    if let matchedUnitRecord = result.units.first(where: { $0.entity?.id == unitID }),
                       let unit = matchedUnitRecord.entity {
                        let isSectionReachable = sectionData.element.entity.isReachable
                        currentSectionUnitViewModels.append(
                            self.makeUnitViewModel(
                                sectionIndex: sectionData.offset,
                                unitIndex: unitIndex,
                                uid: matchedUnitRecord.uniqueIdentifier,
                                unit: unit,
                                downloadState: matchedUnitRecord.downloadState,
                                isAvailable: result.isEnrolled && isSectionReachable
                            )
                        )
                    } else {
                        currentSectionUnitViewModels.append(.placeholder)
                    }
                }

                let hasPlaceholderUnits = currentSectionUnitViewModels.contains(
                    where: { unit in
                        if case .placeholder = unit {
                            return true
                        }
                        return false
                    }
                )

                let sectionDeadline = result.sectionsDeadlines
                    .first { $0.section == sectionData.element.entity.id }?
                    .deadlineDate

                let requiredSection = result.sections
                    .first { $0.entity.id == sectionData.element.entity.requiredSectionID }?
                    .entity

                return self.makeSectionViewModel(
                    index: sectionData.offset,
                    uid: sectionData.element.uniqueIdentifier,
                    section: sectionData.element.entity,
                    requiredSection: requiredSection,
                    units: currentSectionUnitViewModels,
                    downloadState: hasPlaceholderUnits || !result.isEnrolled
                        ? .notAvailable
                        : sectionData.element.downloadState,
                    personalDeadlineDate: sectionDeadline
                )
            }

            viewModel = CourseInfoTabSyllabus.SyllabusLoad.ViewModel(state: .result(data: sectionViewModels))
        default:
            viewModel = CourseInfoTabSyllabus.SyllabusLoad.ViewModel(state: .loading)
        }

        // TODO: Refactor
        self.viewController?.displaySyllabus(viewModel: viewModel)
    }

    func presentDownloadButtonUpdate(response: CourseInfoTabSyllabus.DownloadButtonStateUpdate.Response) {
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
                // Update unit downloadState in cached sections view models.
                var updatedUnit = false
                for (sectionID, sectionViewModel) in self.cachedSectionViewModels where !updatedUnit {
                    for (index, unitViewModelWrapper) in sectionViewModel.units.enumerated() where !updatedUnit {
                        if case .normal(let viewModel) = unitViewModelWrapper,
                           viewModel.uniqueIdentifier == "\(unit.id)" {
                            updatedUnit = true
                            self.cachedSectionViewModels[sectionID]?.units[index] = .normal(viewModel: cachedViewModel)
                        }
                    }
                }

                let viewModel = CourseInfoTabSyllabus.DownloadButtonStateUpdate.ViewModel(
                    data: .unit(viewModel: cachedViewModel)
                )

                self.viewController?.displayDownloadButtonStateUpdate(viewModel: viewModel)
            }
        }
    }

    func presentDeleteDownloadsConfirmationAlert(response: CourseInfoTabSyllabus.DeleteDownloadsConfirmation.Response) {
        let actions: [CourseInfoTabSyllabus.DeleteDownloadsConfirmation.Action] = [
            .init(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: response.cancelActionHandler
            ),
            .init(
                title: NSLocalizedString("Delete", comment: ""),
                style: .destructive,
                handler: response.confirmedActionHandler
            )
        ]

        switch response.type {
        case .course:
            self.viewController?.displayDeleteDownloadsConfirmationAlert(
                viewModel: .init(
                    title: NSLocalizedString(
                        "CourseInfoTabSyllabusDeleteCourseDownloadsConfirmationTitle", comment: ""
                    ),
                    message: NSLocalizedString(
                        "CourseInfoTabSyllabusDeleteCourseDownloadsConfirmationMessage", comment: ""
                    ),
                    actions: actions
                )
            )
        case .unit:
            self.viewController?.displayDeleteDownloadsConfirmationAlert(
                viewModel: .init(
                    title: NSLocalizedString("CourseInfoTabSyllabusDeleteUnitDownloadsConfirmationTitle", comment: ""),
                    message: NSLocalizedString(
                        "CourseInfoTabSyllabusDeleteUnitDownloadsConfirmationMessage", comment: ""
                    ),
                    actions: actions
                )
            )
        case .section:
            self.viewController?.displayDeleteDownloadsConfirmationAlert(
                viewModel: .init(
                    title: NSLocalizedString(
                        "CourseInfoTabSyllabusDeleteSectionDownloadsConfirmationTitle", comment: ""
                    ),
                    message: NSLocalizedString(
                        "CourseInfoTabSyllabusDeleteSectionDownloadsConfirmationMessage", comment: ""
                    ),
                    actions: actions
                )
            )
        }
    }

    func presentDownloadOnCellularDataAlert(response: CourseInfoTabSyllabus.DownloadOnCellularDataAlert.Response) {
        self.viewController?.displayDownloadOnCellularDataAlert(
            viewModel: .init(
                title: NSLocalizedString("CourseInfoTabSyllabusDownloadOnMobileAlertTitle", comment: ""),
                message: NSLocalizedString("CourseInfoTabSyllabusDownloadOnMobileAlertMessage", comment: ""),
                actions: [
                    .init(
                        title: NSLocalizedString("Cancel", comment: ""),
                        style: .cancel,
                        handler: {}
                    ),
                    .init(
                        title: NSLocalizedString("CourseInfoTabSyllabusDownloadOnMobileUseAlwaysAction", comment: ""),
                        style: .default,
                        handler: response.useAlwaysActionHandler
                    ),
                    .init(
                        title: NSLocalizedString("CourseInfoTabSyllabusDownloadOnMobileJustOnceAction", comment: ""),
                        style: .default,
                        handler: response.justOnceActionHandler
                    )
                ]
            )
        )
    }

    func presentCourseSyllabusHeader(response: CourseInfoTabSyllabus.SyllabusHeaderUpdate.Response) {
        let viewModel = CourseInfoTabSyllabusHeaderViewModel(
            isDeadlineButtonVisible: response.isPersonalDeadlinesAvailable,
            isDeadlineButtonEnabled: response.isPersonalDeadlinesEnabled,
            isDownloadAllButtonEnabled: response.isDownloadAllAvailable,
            isDeadlineTooltipVisible: response.isPersonalDeadlinesTooltipVisible,
            courseDownloadState: response.courseDownloadState
        )
        self.viewController?.displaySyllabusHeader(viewModel: .init(data: viewModel))
    }

    func presentWaitingState(response: CourseInfoTabSyllabus.BlockingWaitingIndicatorUpdate.Response) {
        self.viewController?.displayBlockingLoadingIndicator(viewModel: .init(shouldDismiss: response.shouldDismiss))
    }

    func presentFailedDownloadAlert(
        response: CourseInfoTabSyllabus.FailedDownloadAlertPresentation.Response
    ) {
        guard self.shouldPresentFailedAlert else {
            return
        }

        self.lastDateFailedAlertShown = Date()
        self.viewController?.displayFailedDownloadAlert(
            viewModel: .init(
                title: NSLocalizedString("Error", comment: ""),
                message: NSLocalizedString("CourseInfoTabSyllabusFailedDownloadAlertMessage", comment: "")
            )
        )
    }

    // MARK: - Private API

    private func makeSectionViewModel(
        index: Int,
        uid: UniqueIdentifierType,
        section: Section,
        requiredSection: Section?,
        units: [CourseInfoTabSyllabusSectionViewModel.UnitViewModelWrapper],
        downloadState: CourseInfoTabSyllabus.DownloadState,
        personalDeadlineDate: Date? = nil
    ) -> CourseInfoTabSyllabusSectionViewModel {
        let deadlines = self.makeDeadlinesViewModel(
            section: section,
            personalDeadlineDate: personalDeadlineDate
        )

        let progressLabelText: String? = {
            guard let progress = section.progress,
                  progress.cost > 0 else {
                return nil
            }

            return String(
                format: NSLocalizedString("CourseInfoTabSyllabusSectionProgressTitle", comment: ""),
                arguments: ["\(progress.score)", "\(progress.cost)"]
            )
        }()

        let requirementsLabelText = self.makeFormattedSectionRequirementsText(
            section: section,
            requiredSection: requiredSection
        )

        let viewModel = CourseInfoTabSyllabusSectionViewModel(
            uniqueIdentifier: uid,
            index: "\(index + 1)",
            title: section.title,
            progress: (section.progress?.percentPassed ?? 0) / 100.0,
            progressLabelText: progressLabelText,
            requirementsLabelText: requirementsLabelText,
            units: units,
            deadlines: deadlines,
            downloadState: downloadState,
            isDisabled: !section.isReachable,
            isExam: section.isExam
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
            guard let progress = unit.progress,
                  progress.cost > 0 else {
                return nil
            }

            return String(
                format: NSLocalizedString("CourseInfoTabSyllabusUnitProgressTitle", comment: ""),
                arguments: ["\(progress.score)", "\(progress.cost)"]
            )
        }()

        let timeToCompleteLabelText: String? = {
            guard let timeToComplete = unit.lesson?.timeToComplete else {
                return nil
            }

            if timeToComplete < 60 {
                return nil
            } else if case 60..<3600 = timeToComplete {
                return FormatterHelper.minutesInSeconds(timeToComplete, roundingRule: .down)
            } else {
                return FormatterHelper.hoursInSeconds(timeToComplete, roundingRule: .down)
            }
        }()

        let viewModel = CourseInfoTabSyllabusUnitViewModel(
            uniqueIdentifier: uid,
            title: "\(sectionIndex + 1).\(unitIndex + 1) \(lesson.title)",
            coverImageURL: coverImageURL,
            progress: (unit.progress?.percentPassed ?? 0) / 100,
            likesCount: likesCount == 0 ? nil : likesCount,
            learnersLabelText: FormatterHelper.longNumber(lesson.passedBy),
            progressLabelText: progressLabelText,
            timeToCompleteLabelText: timeToCompleteLabelText,
            downloadState: isAvailable ? downloadState : .notAvailable,
            isSelectable: isAvailable
        )

        self.cachedUnitViewModels[unit.id] = viewModel

        return .normal(viewModel: viewModel)
    }

    private func makeDeadlinesViewModel(
        section: Section,
        personalDeadlineDate: Date?
    ) -> CourseInfoTabSyllabusSectionDeadlinesViewModel? {
        let dates: [(title: String, date: Date)] = {
            if let personalDeadlineDate = personalDeadlineDate {
                return [
                    (title: NSLocalizedString("PersonalDeadline", comment: ""), date: personalDeadlineDate)
                ]
            } else {
                return [
                    (title: NSLocalizedString("BeginDate", comment: ""), date: section.beginDate),
                    (title: NSLocalizedString("SoftDeadline", comment: ""), date: section.softDeadline),
                    (title: NSLocalizedString("HardDeadline", comment: ""), date: section.hardDeadline),
                    (title: NSLocalizedString("EndDate", comment: ""), date: section.endDate)
                ].filter { $0.date != nil }.compactMap { ($0.title, $0.date ?? Date()) }
            }
        }()

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

    private func makeFormattedSectionRequirementsText(section: Section, requiredSection: Section?) -> String? {
        if section.isRequirementSatisfied {
            return nil
        }

        guard let requiredSection = requiredSection,
              let requiredSectionProgress = requiredSection.progress else {
            return nil
        }

        let requiredPoints = Int(
            (Float(requiredSectionProgress.cost) * Float(section.requiredPercent) / 100.0).rounded(.up)
        )

        return String(
            format: NSLocalizedString("CourseInfoTabSyllabusSectionRequirementTitle", comment: ""),
            FormatterHelper.pointsCount(requiredPoints),
            requiredSection.title
        )
    }
}
