import Foundation

struct CourseInfoTabSyllabusHeaderViewModel {
    let isDeadlineButtonVisible: Bool
    let isDownloadAllButtonEnabled: Bool
    let isDeadlineTooltipVisible: Bool
}

struct CourseInfoTabSyllabusSectionViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType

    let index: String
    let title: String
    let progress: Float

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
