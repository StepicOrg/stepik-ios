import Foundation

enum ProfileEdit {
    enum ProfileEditLoad {
        struct Request { }

        struct Response {
            let profile: Profile
        }

        struct ViewModel {
            let viewModel: ProfileEditViewModel
        }
    }
}
