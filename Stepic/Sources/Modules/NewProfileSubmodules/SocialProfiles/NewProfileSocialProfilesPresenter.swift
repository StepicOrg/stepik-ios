import UIKit

protocol NewProfileSocialProfilesPresenterProtocol {
    func presentSocialProfiles(response: NewProfileSocialProfiles.SocialProfilesLoad.Response)
}

final class NewProfileSocialProfilesPresenter: NewProfileSocialProfilesPresenterProtocol {
    weak var viewController: NewProfileSocialProfilesViewControllerProtocol?

    func presentSocialProfiles(response: NewProfileSocialProfiles.SocialProfilesLoad.Response) {}
}
