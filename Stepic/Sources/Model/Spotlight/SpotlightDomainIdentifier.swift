import Foundation

/// An identifier for a domain, helps group items together in a way that makes sense.
enum SpotlightDomainIdentifier {
    case course

    var identifier: String {
        switch self {
        case .course:
            return "com.AlexKarpov.Stepic.spotlight.course"
        }
    }
}
