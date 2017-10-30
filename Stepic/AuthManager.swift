//
//  AuthManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AuthManager: NSObject {
    static var sharedManager = AuthManager()

    fileprivate override init() {}

    static let oauth = AuthAPI()

    @discardableResult func logInWithCode(_ code: String, success : @escaping (_ token: StepicToken) -> Void, failure : @escaping (_ error: SignInError) -> Void) -> Request? {

        if StepicApplicationsInfo.social == nil {
            failure(SignInError.noAppWithCredentials)
            return nil
        }

        let headers = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Basic \(StepicApplicationsInfo.social!.credentials)"
        ]

        let params = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": StepicApplicationsInfo.social!.redirectUri
        ]

        return Alamofire.request("\(StepicApplicationsInfo.oauthURL)/token/", method: .post, parameters: params, headers: headers).responseSwiftyJSON {
            response in

            var error = response.result.error
            var json: JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
            let response = response.response

            if let e = error {
                failure(SignInError.other(error: e, code: nil, message: nil))
                return
            }

            if let r = response {
                if r.statusCode < 200 || r.statusCode > 299 {
                    failure(SignInError.other(error: nil, code: r.statusCode, message: json["error"].string))
                    return
                }
            }

            let token: StepicToken = StepicToken(json: json)
            AuthInfo.shared.authorizationType = AuthorizationType.code
            success(token)
        }

    }

    @discardableResult func logInWithUsername(_ username: String, password: String, success : @escaping (_ token: StepicToken) -> Void, failure : @escaping (_ error: SignInError) -> Void) -> Request? {

        if StepicApplicationsInfo.password == nil {
            failure(SignInError.noAppWithCredentials)
            return nil
        }

        let headers = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Basic \(StepicApplicationsInfo.password!.credentials)"
        ]

        let params = [
            "grant_type": "password",
            "password": password,
            "username": username
        ]

        return Alamofire.request("\(StepicApplicationsInfo.oauthURL)/token/", method: .post, parameters: params, headers: headers).responseSwiftyJSON({
            response in

            var error = response.result.error
            var json: JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
            let response = response.response

            if let e = error {
                failure(SignInError.other(error: e, code: nil, message: nil))
                return
            }

            if let r = response {
                if r.statusCode < 200 || r.statusCode > 299 {
                    switch r.statusCode {
                    case 497:
                        failure(SignInError.manyAttempts)
                    case 401:
                        failure(SignInError.invalidEmailAndPassword)
                    default:
                        failure(SignInError.other(error: nil, code: r.statusCode, message: json["error"].string))
                    }
                    return
                }
            }

            let token: StepicToken = StepicToken(json: json)
            AuthInfo.shared.authorizationType = AuthorizationType.password
            success(token)
        })
    }

    @discardableResult func refreshTokenWith(_ refresh_token: String, success : @escaping (_ token: StepicToken) -> Void, failure : @escaping (_ error: TokenRefreshError) -> Void) -> Request? {
        func logRefreshError(statusCode: Int?, message: String?) {
            var parameters: [String: NSObject] = [:]
            if let code = statusCode {
                parameters["code"] = code as NSObject?
            }
            if let m = message {
                parameters["message"] = m as NSObject?
            }
            AnalyticsReporter.reportEvent(AnalyticsEvents.Errors.tokenRefresh, parameters: parameters)
        }

        var credentials = ""
        switch AuthInfo.shared.authorizationType {
        case .none:
            failure(TokenRefreshError.other)
            return nil
        case .code:
            if StepicApplicationsInfo.social == nil {
                failure(TokenRefreshError.noAppWithCredentials)
                return nil
            }
            credentials = StepicApplicationsInfo.social!.credentials
        case .password:
            if StepicApplicationsInfo.password == nil {
                failure(TokenRefreshError.noAppWithCredentials)
                return nil
            }
            credentials = StepicApplicationsInfo.password!.credentials
        }

        let headers = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Authorization": "Basic \(credentials)"
        ]

        let params: Parameters = [
            "grant_type": "refresh_token",
            "refresh_token": refresh_token]

        return Alamofire.request("\(StepicApplicationsInfo.oauthURL)/token/", method: .post, parameters: params, headers: headers).responseSwiftyJSON({
            response in

            var error = response.result.error
            var json: JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
            let response = response.response

            if let e = error {
                logRefreshError(statusCode: response?.statusCode, message: "Error \(e.localizedDescription) while refreshing")
                failure(TokenRefreshError.other)
                return
            }

            let token: StepicToken = StepicToken(json: json)

            if token.accessToken == "" {
                logRefreshError(statusCode: response?.statusCode, message: "Error after getting empty access token")
                if response?.statusCode == 401 {
                    failure(TokenRefreshError.noAccess)
                } else {
                    failure(TokenRefreshError.other)
                }
                return
            }

            success(token)
        })

    }

    @discardableResult func autoRefreshToken(success : (() -> Void)? = nil, failure : (() -> Void)? = nil) -> Request? {

        if AuthInfo.shared.didRefresh {
            success?()
            return nil
        }

        return refreshTokenWith(AuthInfo.shared.token!.refreshToken, success: {
            t in

            AuthInfo.shared.token = t
            success?()
            }, failure : {
                _ in
                print("error while auto refresh token")
                failure?()
        })
    }

    @discardableResult func joinCourse(course: Course, delete: Bool = false, success : @escaping (() -> Void), error errorHandler: @escaping ((String) -> Void)) -> Request? {

        let headers: [String : String] = AuthInfo.shared.initialHTTPHeaders

        let params: Parameters = [
            "enrollment": [
                "course": "\(course.id)"
            ]
        ]

        if !delete {
            return Alamofire.request("\(StepicApplicationsInfo.apiURL)/enrollments", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON({
                response in

                var error = response.result.error
                var json : JSON = [:]
                if response.result.value == nil {
                    if error == nil {
                        error = NSError()
                    }
                } else {
                    json = response.result.value!
                }
                let response = response.response

                if let r = response {
                    if r.statusCode >= 200 && r.statusCode <= 299 {
                        if let courseJSON = json["courses"].array?[0] {
                            course.update(json: courseJSON)
                        }
                        success()
                    } else {
                        let s = NSLocalizedString("TryJoinFromWeb", comment: "")
                        errorHandler(s)
                    }
                } else {
                    let s = NSLocalizedString("Error", comment: "")
                    errorHandler(s)
                }
            })
        } else {
            return Alamofire.request("\(StepicApplicationsInfo.apiURL)/enrollments/\(course.id)", method: .delete, parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON({
                response in

                var error = response.result.error
//                var json : JSON = [:]
                if response.result.value == nil {
                    if error == nil {
                        error = NSError()
                    }
                } else {
//                    json = response.result.value!
                }
                let response = response.response

                if let r = response {
                    if r.statusCode >= 200 && r.statusCode <= 299 {
                        success()
                        return
                    }
                }

                let s = NSLocalizedString("Error", comment: "")
                errorHandler(s)
            })

        }

    }

    //TODO: When refactoring code think about this function
    func signUpWith(_ firstname: String, lastname: String, email: String, password: String, success : @escaping (() -> Void), error errorHandler: @escaping ((String?, RegistrationErrorInfo?) -> Void)) {
            let headers: [String : String] = AuthInfo.shared.initialHTTPHeaders

            let params: Parameters =
            ["user": [
                    "first_name": firstname,
                    "last_name": lastname,
                    "email": email,
                    "password": password
                ]
            ]

            print("sending request with headers:\n\(headers)\nparams:\n\(params)")
            _ = Alamofire.request("\(StepicApplicationsInfo.apiURL)/users", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseSwiftyJSON({
                    response in

                    var error = response.result.error
                    var json: JSON = [:]
                    if response.result.value == nil {
                        if error == nil {
                            error = NSError()
                        }
                    } else {
                        json = response.result.value!
                    }
                    let response = response.response

                    if let e = (error as NSError?) {
                        let errormsg = "\(e.code)\n\(e.localizedFailureReason ?? "")\n\(e.localizedRecoverySuggestion ?? "")\n\(e.localizedDescription)"
                        errorHandler(errormsg, nil)
                        return
                    }

                    if let r = response {
                        if r.statusCode >= 200 && r.statusCode <= 299 {
                            success()
                        } else if r.statusCode == 400 {
                            errorHandler(nil, RegistrationErrorInfo(json: json))
                        }
                    }
            })
    }
}

enum TokenRefreshError: Error {
    case noAccess, noAppWithCredentials, other
}

enum SignInError: Error {
    case manyAttempts
    case noAppWithCredentials
    case invalidEmailAndPassword
    case existingEmail(provider: String?, email: String?)
    case other(error: Error?, code: Int?, message: String?)
}
