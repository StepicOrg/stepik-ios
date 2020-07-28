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
        let itemsViewModels = socialProfiles
            .sorted { $0.providerString < $1.providerString }
            .map {
                NewProfileSocialProfilesViewModel.Item(
                    iconName: $0.provider?.iconName ?? "social-profile-provider-website",
                    title: $0.name,
                    url: URL(string: $0.urlString)
                )
            }
        return NewProfileSocialProfilesViewModel(socialProfiles: itemsViewModels)
    }
}
