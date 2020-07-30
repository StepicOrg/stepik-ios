import Foundation

struct NewProfileSocialProfilesViewModel {
    struct Item {
        let iconName: String
        let title: String
        let url: URL?
    }

    let socialProfiles: [Item]
}
