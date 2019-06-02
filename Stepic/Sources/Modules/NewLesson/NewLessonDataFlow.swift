import Foundation

enum NewLesson {
    // MARK: Data flow

    /// Load lesson content
    enum LessonLoad {
        struct ResponseData {
            let lesson: Lesson
            let steps: [Step]
            let progresses: [Progress]
            let startStepIndex: Int
        }

        enum ResponseState {
            case loading
            case error
            case success(result: ResponseData)
        }

        struct Response {
            let state: ResponseState
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

    // MARK: Enums

    enum ViewControllerState {
        case loading
        case result(data: NewLessonViewModel)
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
}
