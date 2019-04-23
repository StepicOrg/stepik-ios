import Foundation

enum NewLesson {
    // MARK: Data flow
    enum SomeAction {
        struct Request { }

        struct Response { }

        struct ViewModel { }
    }

    // MARK: Enums

    /// Lesson module can be presented with lesson attached to unit or with single lesson
    enum Context {
        case unit(id: Unit.IdType)
        case lesson(id: Lesson.IdType)
    }
}
