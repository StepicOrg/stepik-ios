import Foundation

enum LessonFinishedDemoPanModal {
    enum ModalLoad {
        struct Request {}

        struct Response {
            let course: Course
            let section: Section
        }

        struct ViewModel {
            let title: String
            let subtitle: String
            let actionButtonTitle: String
        }
    }
}
