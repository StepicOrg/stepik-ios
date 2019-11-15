import Foundation

struct DownloadsItemViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType

    let coverImageURL: URL?
    let isAdaptive: Bool
    let title: String
    let subtitle: String
}
