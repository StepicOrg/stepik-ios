import Foundation

enum CourseListCardStyle {
    case small
    case normal

    static var `default`: CourseListCardStyle { .normal }

    var height: CGFloat {
        switch self {
        case .small:
            return 200
        case .normal:
            return 160
        }
    }
}
