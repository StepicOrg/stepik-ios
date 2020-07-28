import UIKit

protocol NewProfileSocialProfilesPresenterProtocol {
    func presentSomeActionResult(response: NewProfileSocialProfiles.SomeAction.Response)
}

final class NewProfileSocialProfilesPresenter: NewProfileSocialProfilesPresenterProtocol {
    weak var viewController: NewProfileSocialProfilesViewControllerProtocol?

    func presentSomeActionResult(response: NewProfileSocialProfiles.SomeAction.Response) {}
}
