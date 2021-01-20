import Foundation

enum WidgetURL {
    case course(id: Int)
    case catalog

    var url: URL {
        let stringValue: String = {
            switch self {
            case .course(let id):
                return "\(WidgetConstants.URL.widgetURL)/course/\(id)"
            case .catalog:
                return  "\(WidgetConstants.URL.widgetURL)/catalog"
            }
        }()

        return URL(string: stringValue)!
    }
}
