//
//  AuthInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation

extension Foundation.Notification.Name {
    static let didLogout = Foundation.Notification.Name("didLogout")
    static let didLogin = Foundation.Notification.Name("didLogin")
    static let didChangeCurrentUser = Foundation.Notification.Name("didChangeCurrentUser")
}

@available(*, deprecated, message: "Legacy class")
final class AuthInfo: NSObject {
    static var shared = AuthInfo()

    private let defaults = UserDefaults.standard

    private lazy var logoutDataClearService: LogoutDataClearServiceProtocol = LogoutDataClearService()

    @available(iOS 14.0, *)
    private lazy var widgetTokenFileManager: StepikWidgetTokenFileManagerProtocol = StepikWidgetTokenFileManager.default

    override private init() {
        super.init()

        print("AuthInfo :: initializing AuthInfo with userId \(String(describing: self.userId))")
        if let id = self.userId {
            if let users = User.fetchById(id) {
                print("AuthInfo :: initializing fetched users = \(users)")
                if users.isEmpty {
                    StepikAnalytics.shared.send(.errorAuthInfoNoUserOnInit)
                } else {
                    self.user = users.first
                }
            }
        }

        if #available(iOS 14.0, *) {
            try? self.widgetTokenFileManager.write(token: StepikWidgetToken(accessToken: self.token?.accessToken))
        }
    }

    private func setTokenValue(_ newToken: StepikToken?) {
        print("AuthInfo :: setting token value = \(String(describing: newToken))")
        self.defaults.setValue(newToken?.accessToken, forKey: "access_token")
        self.defaults.setValue(newToken?.refreshToken, forKey: "refresh_token")
        self.defaults.setValue(newToken?.tokenType, forKey: "token_type")
        self.defaults.setValue(newToken?.expireDate.timeIntervalSince1970, forKey: "expire_date")
        self.defaults.synchronize()

        if #available(iOS 14.0, *) {
            try? self.widgetTokenFileManager.write(token: StepikWidgetToken(accessToken: newToken?.accessToken))
        }
    }

    var token: StepikToken? {
        set(newToken) {
            if newToken == nil || newToken?.accessToken == "" {
                print("AuthInfo :: setting new token to nil")
                self.logoutDataClearService.clearCurrentUserData().done {
                    self.user = nil
                    self.setTokenValue(nil)
                    NotificationCenter.default.post(name: .didLogout, object: nil)
                }
            } else {
                let oldToken = token
                print("AuthInfo :: setting new token -> \(String(describing: newToken?.accessToken))")
                didRefresh = true
                setTokenValue(newToken)
                StepikSession.delete()
                if oldToken == nil {
                    // first set, not refresh
                    NotificationCenter.default.post(name: .didLogin, object: nil)
                }
            }
        }
        get {
            if let accessToken = defaults.value(forKey: "access_token") as? String,
               let refreshToken = defaults.value(forKey: "refresh_token") as? String,
               let tokenType = defaults.value(forKey: "token_type") as? String {
                //print("AuthInfo :: got accessToken \(accessToken)")
                let expireDate = Date(timeIntervalSince1970: defaults.value(forKey: "expire_date") as? TimeInterval ?? 0.0)
                return StepikToken(accessToken: accessToken, refreshToken: refreshToken, tokenType: tokenType, expireDate: expireDate)
            } else {
                return nil
            }
        }
    }

    var isAuthorized: Bool { self.token != nil }

    var hasUser: Bool { self.user != nil }

    var needsToRefreshToken: Bool {
        //TODO: Fix this
        if let token = token {
            return Date().compare(token.expireDate as Date) == ComparisonResult.orderedDescending
        } else {
            return false
        }
    }

    var authorizationType: AuthorizationType {
        get {
            if let typeRaw = defaults.value(forKey: "authorization_type") as? Int {
                return AuthorizationType(rawValue: typeRaw)!
            } else {
                return AuthorizationType.none
            }
        }
        set(type) {
            defaults.setValue(type.rawValue, forKey: "authorization_type")
            defaults.synchronize()
        }
    }

    var didRefresh = false

    var anonymousUserId: Int?

    var userId: Int? {
        set(id) {
            if let user = user {
                if user.isGuest {
                    print("AuthInfo :: setting anonymous user id \(String(describing: id))")
                    anonymousUserId = id
                    AnalyticsUserProperties.shared.setUserID(to: nil)
                    return
                }
            }
            AnalyticsUserProperties.shared.setUserID(to: user?.id)
            print("AuthInfo :: setting user id \(String(describing: id))")
            defaults.setValue(id, forKey: "user_id")
            defaults.synchronize()
        }
        get {
            if let user = user {
                if user.isGuest {
                    print("AuthInfo :: returning anonymous user id \(String(describing: anonymousUserId))")
                    return anonymousUserId
                } else {
                    print("AuthInfo :: returning normal user id \(String(describing: defaults.value(forKey: "user_id") as? Int))")
                    return defaults.value(forKey: "user_id") as? Int
                }
            } else {
                print("AuthInfo :: returning normal user id \(String(describing: defaults.value(forKey: "user_id") as? Int))")
                return defaults.value(forKey: "user_id") as? Int
            }
        }
    }

    var user: User? {
        didSet {
            print("AuthInfo :: did set user with id \(String(describing: user?.id))")
            userId = user?.id
            NotificationCenter.default.post(name: .didChangeCurrentUser, object: nil)
        }
    }

    var initialHTTPHeaders: HTTPHeaders {
        if !AuthInfo.shared.isAuthorized {
            var headers = HTTPHeaders(StepikSession.cookieHeaders)
            headers.add(.stepikUserAgent)
            return headers
        } else {
            var headers = APIDefaults.Headers.bearer
            headers.add(.stepikUserAgent)
            return headers
        }
    }
}

enum AuthorizationType: Int {
    case none = 0, password, code
}
