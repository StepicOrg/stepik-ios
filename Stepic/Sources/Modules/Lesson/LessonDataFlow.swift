import Foundation

enum LessonDataFlow {
    // MARK: Data flow

    /// Load lesson content
    enum LessonLoad {
        struct Request {}

        struct Data: Equatable {
            let lesson: Lesson
            let steps: [Step]
            let progresses: [Progress]
            let startStepIndex: Int
            let canEdit: Bool

            static func == (lhs: Data, rhs: Data) -> Bool {
                if !lhs.lesson.equals(rhs.lesson) {
                    return false
                }

                if lhs.steps.count != rhs.steps.count {
                    return false
                }
                for (lhsStep, rhsStep) in zip(lhs.steps, rhs.steps) {
                    if !lhsStep.equals(rhsStep) {
                        return false
                    }
                }

                if lhs.progresses.count != rhs.progresses.count {
                    return false
                }
                for (lhsProgress, rhsProgress) in zip(lhs.progresses, rhs.progresses) {
                    if !lhsProgress.equals(rhsProgress) {
                        return false
                    }
                }

                if lhs.startStepIndex != rhs.startStepIndex {
                    return false
                }

                if lhs.canEdit != rhs.canEdit {
                    return false
                }

                return true
            }
        }

        struct Response {
            let state: StepikResult<Data>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Load lesson navigation (next / previous lessons)
    enum LessonNavigationLoad {
        struct Response {
            let hasPreviousUnit: Bool
            let hasNextUnit: Bool
        }

        struct ViewModel {
            let hasPreviousUnit: Bool
            let hasNextUnit: Bool
        }
    }

    /// Present alert with about unit navigation error requirement not satisfied
    enum UnitNavigationRequirementNotSatisfiedPresentation {
        struct Response {
            let currentSection: Section
            let targetSection: Section
            let requiredSection: Section
        }

        struct ViewModel {
            let title: String
            let message: String
        }
    }

    /// Present alert with common unit navigation error description
    enum UnitNavigationUnreachablePresentation {
        struct Response {
            let targetSection: Section
        }

        struct ViewModel {
            let title: String
            let message: String
        }
    }

    /// Present exam alert
    enum UnitNavigationExamPresentation {
        struct Response {
            let currentSection: Section
            let targetSection: Section
        }

        struct ViewModel {
            let title: String
            let message: String
        }
    }

    /// Present alert with about unit navigation error closed by begin or end date
    enum UnitNavigationClosedByDatePresentation {
        struct Response {
            let currentSection: Section
            let targetSection: Section
            let dateSource: DateSource

            enum DateSource {
                case beginDate
                case endDate
            }
        }

        struct ViewModel {
            let title: String
            let message: String
        }
    }

    /// Present modal with finished demo access info
    enum UnitNavigationFinishedDemoAccessPresentation {
        struct Response {
            let section: Section
        }

        struct ViewModel {
            let sectionID: Section.IdType
        }
    }

    /// Present new lesson module
    enum LessonModulePresentation {
        struct Response {
            let lessonID: Int
            let stepIndex: Int
        }

        struct ViewModel {
            let lessonID: Int
            let stepIndex: Int
        }
    }

    /// Mark step as passed
    enum StepPassedStatusUpdate {
        struct Response {
            let stepID: Step.IdType
        }

        struct ViewModel {
            // Can't use index here cause lesson can be updated
            let stepID: Step.IdType
        }
    }

    /// Current step index update
    enum CurrentStepUpdate {
        struct Response {
            let index: Int
        }

        struct ViewModel {
            let index: Int
        }
    }

    /// Autoplay current step
    enum CurrentStepAutoplay {
        struct Response {}

        struct ViewModel {}
    }

    /// Load lesson tooltip info content
    enum LessonTooltipInfoLoad {
        struct Response {
            let lesson: Lesson
            let steps: [Step]
            let progresses: [Progress]
        }

        struct ViewModel {
            let data: [Step.IdType: [TooltipInfo]]
        }
    }

    /// Update tooltip info for step
    enum StepTooltipInfoUpdate {
        struct Response {
            let lesson: Lesson
            let step: Step
            let progress: Progress
        }

        struct ViewModel {
            let stepID: Step.IdType
            let info: [TooltipInfo]
        }
    }

    /// Edit current step text
    enum EditStepPresentation {
        struct Request {
            let index: Int
        }

        struct Response {
            let stepID: Step.IdType
        }

        struct ViewModel {
            let stepID: Step.IdType
        }
    }

    enum SubmissionsPresentation {
        struct Request {
            let index: Int
        }

        struct Response {
            let stepID: Step.IdType
            let isTeacher: Bool
        }

        struct ViewModel {
            let stepID: Step.IdType
            let isTeacher: Bool
        }
    }

    /// Load new step HTML text (after step source updated)
    enum StepTextUpdate {
        struct Response {
            let index: Int
            let stepSource: StepSource
        }

        struct ViewModel {
            let index: Int
            let text: String
        }
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

    // MARK: Enums

    enum ViewControllerState {
        case loading
        case result(data: LessonViewModel)
        case error
    }

    /// Lesson module can be presented with lesson attached to unit or with single lesson
    enum Context {
        case unit(id: Unit.IdType)
        case lesson(id: Lesson.IdType)
    }

    /// Start step can be presented by index or by step ID
    enum StartStep {
        case index(_: Int)
        case id(_: Step.IdType)
    }

    // MARK: Structs

    struct TooltipInfo {
        let iconImage: UIImage?
        let text: String
    }
}
