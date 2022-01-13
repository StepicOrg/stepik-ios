import Foundation
import GoogleSignIn
import PromiseKit

protocol GoogleIDSocialSDKProviderDelegate: AnyObject {
    var googleSignInPresentingViewController: UIViewController? { get }
}

final class GoogleIDSocialSDKProvider: NSObject, SocialSDKProvider {
    static let instance = GoogleIDSocialSDKProvider()

    weak var delegate: GoogleIDSocialSDKProviderDelegate?

    let name = "google"

    private let sdkInstance: GIDSignIn
    private let signInConfig: GIDConfiguration

    override private init() {
        self.sdkInstance = GIDSignIn.sharedInstance
        self.signInConfig = GIDConfiguration.init(clientID: StepikApplicationsInfo.SocialInfo.AppIds.google)
        super.init()
    }

    func getAccessInfo() -> Promise<SocialSDKCredential> {
        Promise { seal in
            self.getAccessInfo(
                success: { socialSDKCredential in
                    seal.fulfill(socialSDKCredential)
                },
                error: { error in
                    seal.reject(error)
                }
            )
        }
    }

    private func getAccessInfo(
        success successHandler: @escaping (SocialSDKCredential) -> Void,
        error errorHandler: @escaping (SocialSDKError) -> Void
    ) {
        guard let presentingViewController = self.delegate?.googleSignInPresentingViewController else {
            return errorHandler(.connectionError)
        }

        if self.sdkInstance.hasPreviousSignIn() {
            self.sdkInstance.signOut()
        }

        self.sdkInstance.signIn(with: self.signInConfig, presenting: presentingViewController) { user, error in
            if let error = error {
                print("GoogleIDSocialSDKProvider :: error = \(error.localizedDescription)")
                errorHandler(.connectionError)
            } else if let user = user {
                let email = user.profile?.email
                user.authentication.do { authentication, error in
                    if let error = error {
                        print("GoogleIDSocialSDKProvider :: error = \(error.localizedDescription)")
                        errorHandler(.connectionError)
                    } else if let authentication = authentication {
                        successHandler(SocialSDKCredential(token: authentication.accessToken, email: email))
                    } else {
                        print("GoogleIDSocialSDKProvider :: error missing accessToken")
                        errorHandler(.accessDenied)
                    }
                }
            } else {
                print("GoogleIDSocialSDKProvider :: error missing accessToken")
                errorHandler(.accessDenied)
            }
        }
    }
}
