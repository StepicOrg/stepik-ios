import AuthenticationServices
import Foundation
import PromiseKit

@available(iOS 13.0, *)
final class AppleIDSocialSDKProvider: NSObject, SocialSDKProvider {
    private typealias CompletionHandler = (Swift.Result<SocialSDKCredential, SocialSDKError>) -> Void

    let name = "apple"

    private var completionHandler: CompletionHandler?

    func getAccessInfo() -> Promise<SocialSDKCredential> {
        Promise { seal in
            self.signInWithApple { result in
                switch result {
                case .success(let credential):
                    seal.fulfill(credential)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }

    private func signInWithApple(completionHandler: @escaping CompletionHandler) {
        self.completionHandler = completionHandler

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

@available(iOS 13.0, *)
extension AppleIDSocialSDKProvider: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return self.handleDidCompleteWithError(SocialSDKError.connectionError)
        }

        guard let appleAuthCode = appleIDCredential.authorizationCode else {
            print("AppleIDSocialSDKProvider :: Unable to fetch authorization code")
            return self.handleDidCompleteWithError(SocialSDKError.connectionError)
        }

        guard let authCodeString = String(data: appleAuthCode, encoding: .utf8) else {
            print("AppleIDSocialSDKProvider :: Unable to serialize authorization code from data: \(appleAuthCode.debugDescription)")
            return self.handleDidCompleteWithError(SocialSDKError.connectionError)
        }

        guard let appleIDToken = appleIDCredential.identityToken else {
            print("AppleIDSocialSDKProvider :: Unable to fetch identity token")
            return self.handleDidCompleteWithError(SocialSDKError.connectionError)
        }

        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("AppleIDSocialSDKProvider :: Unable to serialize token string from data: \(appleIDToken.debugDescription)")
            return self.handleDidCompleteWithError(SocialSDKError.connectionError)
        }

        let credential = SocialSDKCredential(
            token: authCodeString,
            identityToken: idTokenString,
            email: appleIDCredential.email,
            firstName: appleIDCredential.fullName?.givenName,
            lastName: appleIDCredential.fullName?.familyName
        )

        self.completionHandler?(.success(credential))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.handleDidCompleteWithError(error)
    }

    private func handleDidCompleteWithError(_ error: Error) {
        let socialSDKError: SocialSDKError = {
            if let socialSDKError = error as? SocialSDKError {
                return socialSDKError
            } else if let authorizationError = error as? ASAuthorizationError {
                switch authorizationError.code {
                case .canceled:
                    return .accessDenied
                case .unknown, .invalidResponse, .notHandled, .failed:
                    return .connectionError
                @unknown default:
                    return .connectionError
                }
            } else {
                return .connectionError
            }
        }()

        self.completionHandler?(.failure(socialSDKError))
    }
}

@available(iOS 13.0, *)
extension AppleIDSocialSDKProvider: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        SourcelessRouter().window.require()
    }
}
