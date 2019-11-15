import Foundation

struct DownloadsItemViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType

    let coverImageURL: URL?
    let title: String
    let subtitle: String
}
