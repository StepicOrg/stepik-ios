import UIKit

protocol NewProfileSocialProfilesPresenterProtocol {
    func presentSocialProfiles(response: NewProfileSocialProfiles.SocialProfilesLoad.Response)
}

final class NewProfileSocialProfilesPresenter: NewProfileSocialProfilesPresenterProtocol {
    weak var viewController: NewProfileSocialProfilesViewControllerProtocol?

    func presentSocialProfiles(response: NewProfileSocialProfiles.SocialProfilesLoad.Response) {
        switch response.result {
        case .success(let socialProfiles):
            let viewModel = self.makeViewModel(socialProfiles: socialProfiles)
            self.viewController?.displaySocialProfiles(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displaySocialProfiles(viewModel: .init(state: .error))
        }
    }

    private func makeViewModel(socialProfiles: [SocialProfile]) -> NewProfileSocialProfilesViewModel {
        let sortedSocialProfiles = socialProfiles.sorted { lhs, rhs in
            self.orderValue(for: lhs.provider) > self.orderValue(for: rhs.provider)
        }

        let itemsViewModels = sortedSocialProfiles.map { socialProfile in
            NewProfileSocialProfilesViewModel.Item(
                iconName: "vk",
                title: socialProfile.name,
                url: URL(string: socialProfile.urlString)
            )
        }

        return NewProfileSocialProfilesViewModel(socialProfiles: itemsViewModels)
    }

    private func orderValue(for provider: SocialProfileProvider?) -> Int { provider?.importanceValue ?? -1 }
}
