import Foundation

enum NewLesson {
    // MARK: Data flow

    enum LessonLoad {
        struct Response {
            let data: Result<(Lesson, [Step])>
        }

        struct ViewModel {
            let state: ViewControllerState
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
}
