import Foundation

enum CourseInfoTabSyllabus {
    // MARK: Common structs

    struct SyllabusData {
        struct Record<T>: UniqueIdentifiable {
            let uniqueIdentifier: UniqueIdentifierType
            let entity: T
            let downloadState: DownloadState
        }

        let sections: [Record<Section>]
        let units: [Record<Unit?>]
        let sectionsDeadlines: [SectionDeadline]
        let isEnrolled: Bool
    }

    enum DownloadState {
        case notAvailable
        case waiting
        case notCached
        case cached(bytesTotal: UInt64, hasCachedVideosOrImages: Bool)
        case downloading(progress: Float)
    }

    // MARK: Use cases

    /// Course syllabus
    enum SyllabusLoad {
        struct Request { }

        struct Response {
            var result: Result<SyllabusData>
        }

        struct ViewModel {
            var state: ViewControllerState
        }
    }

    /// Load syllabus section
    enum SyllabusSectionLoad {
        struct Request {
            let uniqueIdentifier: UniqueIdentifierType
        }
    }

    /// Click on download button
    enum DownloadButtonAction {
        enum `Type` {
            case section(uniqueIdentifier: UniqueIdentifierType)
            case unit(uniqueIdentifier: UniqueIdentifierType)
            case all
        }

        struct Request {
            let type: Type
        }
    }

    /// Request delete downloads confirmation via alert
    enum DeleteDownloadsConfirmation {
        enum `Type` {
            case course
            case section
            case unit
        }

        struct Response {
            let type: Type
            let cancelActionHandler: (() -> Void)
            let confirmedActionHandler: (() -> Void)
        }

        struct Action {
            let title: String
            let style: Style
            let handler: (() -> Void)

            enum Style {
                case cancel
                case destructive
            }
        }

        struct ViewModel {
            let title: String?
            let message: String
            let actions: [Action]
        }
    }

    /// Update download state
    enum DownloadButtonStateUpdate {
        enum Source {
            case unit(entity: Unit)
            case section(entity: Section)
        }

        enum Result {
            case section(viewModel: CourseInfoTabSyllabusSectionViewModel)
            case unit(viewModel: CourseInfoTabSyllabusUnitViewModel)
        }

        struct Response {
            let source: Source
            let downloadState: DownloadState
        }

        struct ViewModel {
            let data: Result
        }
    }

    /// Click on unit
    enum UnitSelection {
        struct Request {
            let uniqueIdentifier: UniqueIdentifierType
        }
    }

    /// Update syllabus header (deadlines, download all)
    enum SyllabusHeaderUpdate {
        struct Request { }

        struct Response {
            let isPersonalDeadlinesAvailable: Bool
            let isPersonalDeadlinesEnabled: Bool
            let isDownloadAllAvailable: Bool
            let isPersonalDeadlinesTooltipVisible: Bool
            let courseDownloadState: CourseInfoTabSyllabus.DownloadState
        }

        struct ViewModel {
            let data: CourseInfoTabSyllabusHeaderViewModel
        }
    }

    /// Click on personal deadlines button
    enum PersonalDeadlinesButtonAction {
        struct Request { }
    }

    /// Handle HUD
    enum BlockingWaitingIndicatorUpdate {
        struct Response {
            let shouldDismiss: Bool
        }

        struct ViewModel {
            let shouldDismiss: Bool
        }
    }

    /// Present alert when video/image download failed
    enum FailedDownloadAlertPresentation {
        struct Response {
            let error: Error
        }

        struct ViewModel {
            let title: String
            let message: String
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: [CourseInfoTabSyllabusSectionViewModel])
    }
}
