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

    private var sdkInstance: GIDSignIn

    private var successHandler: ((SocialSDKCredential) -> Void)?
    private var errorHandler: ((SocialSDKError) -> Void)?

    override private init() {
        self.sdkInstance = GIDSignIn.sharedInstance()
        super.init()
        self.sdkInstance.clientID = StepikApplicationsInfo.SocialInfo.AppIds.google
        self.sdkInstance.delegate = self
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
        self.successHandler = successHandler
        self.errorHandler = errorHandler

        self.sdkInstance.presentingViewController = self.delegate?.googleSignInPresentingViewController

        if self.sdkInstance.hasPreviousSignIn() {
            self.sdkInstance.signOut()
        }

        self.sdkInstance.signIn()
    }
}

extension GoogleIDSocialSDKProvider: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("GoogleIDSocialSDKProvider :: error=\(error.localizedDescription)")
            self.errorHandler?(SocialSDKError.connectionError)
        } else if let authentication = user.authentication,
                  let accessToken = authentication.accessToken {
            var email: String?
            if let profile = user.profile,
               let profileEmail = profile.email {
                email = profileEmail
            }
            self.successHandler?(SocialSDKCredential(token: accessToken, email: email))
        } else {
            print("GoogleIDSocialSDKProvider :: error missing accessToken")
            self.errorHandler?(SocialSDKError.accessDenied)
        }
    }
}
