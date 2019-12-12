import Foundation

struct CourseInfoTabSyllabusHeaderViewModel {
    let isDeadlineButtonVisible: Bool
    let isDeadlineButtonEnabled: Bool
    let isDownloadAllButtonEnabled: Bool
    let isDeadlineTooltipVisible: Bool

    let courseDownloadState: CourseInfoTabSyllabus.DownloadState
}

struct CourseInfoTabSyllabusSectionViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType

    let index: String
    let title: String
    let progress: Float
    let progressLabelText: String?
    let requirementLabelText: String?

    var units: [UnitViewModelWrapper]
    var deadlines: CourseInfoTabSyllabusSectionDeadlinesViewModel?

    var downloadState: CourseInfoTabSyllabus.DownloadState
    let isDisabled: Bool
    let isExam: Bool

    enum UnitViewModelWrapper {
        case placeholder
        case normal(viewModel: CourseInfoTabSyllabusUnitViewModel)
    }
}

struct CourseInfoTabSyllabusUnitViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType

    let title: String
    let coverImageURL: URL?
    let progress: Float

    let likesCount: Int?
    let learnersLabelText: String
    let progressLabelText: String?
    let timeToCompleteLabelText: String?

    var downloadState: CourseInfoTabSyllabus.DownloadState
    let isSelectable: Bool
}

struct CourseInfoTabSyllabusSectionDeadlinesViewModel {
    struct TimelineItem {
        let title: String
        let lineFillingProgress: Float
        let isPointFilled: Bool
    }

    let timelineItems: [TimelineItem]
}
