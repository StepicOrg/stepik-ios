//import FBSDKLoginKit
//import Foundation
//import PromiseKit
//
//final class FBSocialSDKProvider: NSObject, SocialSDKProvider {
//    static let instance = FBSocialSDKProvider()
//
//    let name = "facebook"
//
//    override private init() {
//        super.init()
//    }
//
//    func getAccessInfo() -> Promise<SocialSDKCredential> {
//        Promise { seal in
//            let loginManager = LoginManager()
//            loginManager.logIn(
//                permissions: ["email"],
//                from: nil,
//                handler: { result, error in
//                    if error != nil {
//                        seal.reject(SocialSDKError.connectionError)
//                        return
//                    }
//
//                    guard let result = result else {
//                        seal.reject(SocialSDKError.connectionError)
//                        return
//                    }
//
//                    if result.isCancelled {
//                        seal.reject(SocialSDKError.accessDenied)
//                        return
//                    }
//
//                    if let token = result.token?.tokenString {
//                        seal.fulfill(SocialSDKCredential(token: token))
//                        return
//                    }
//                }
//            )
//        }
//    }
//}
