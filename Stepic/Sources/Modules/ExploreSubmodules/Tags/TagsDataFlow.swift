import Foundation

enum Tags {
    // MARK: Common structs
    struct Tag {
        // cause CourseTag sucks (we should have language in each layer)
        let id: Int
        let title: String
        let summary: String
        let analyticsTitle: String
    }

    // MARK: Use cases

    /// Show tag list
    enum TagsLoad {
        struct Request { }

        struct Response {
            let result: Result<[(UniqueIdentifierType, Tag)]>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Present collection of tag (after click)
    enum TagCollectionPresentation {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: [TagViewModel])
        case emptyResult
        case error(message: String)
    }
}
