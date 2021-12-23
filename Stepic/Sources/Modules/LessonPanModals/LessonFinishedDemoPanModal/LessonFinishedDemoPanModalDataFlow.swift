import Foundation

enum LessonFinishedDemoPanModal {
    enum ModalLoad {
        struct Request {}

        struct Response {
            let course: Course
            let section: Section
            let coursePurchaseFlow: CoursePurchaseFlowType
            let mobileTier: MobileTier?
        }

        struct ViewModel {
            let title: String
            let subtitle: String
            let actionButtonTitle: String
        }
    }

    enum MainModalAction {
        struct Request {}
    }
}
