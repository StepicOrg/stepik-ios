import Foundation

enum ContinueCourse {
    // MARK: Use cases

    /// Load last course
    enum LastCourseLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<Course>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Go to last step
    enum ContinueCourseAction {
        struct Request {}
    }

    /// Go to catalog
    enum ContinueCourseEmptyAction {
        struct Request {}
    }

    /// Check for tooltip
    enum TooltipAvailabilityCheck {
        struct Request {}

        struct Response {
            let shouldShowTooltip: Bool
        }

        struct ViewModel {
            let shouldShowTooltip: Bool
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case empty
        case result(data: ContinueCourseViewModel)
    }
}
