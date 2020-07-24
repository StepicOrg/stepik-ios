//
//  Session.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation

final class StepikSession {
    static var cookieHeaders = [String: String]()
    static var needsRefresh: Bool { self.cookieHeaders.isEmpty }

    static var cookieDict = [String: String]()
    static var hasCookies: Bool { !self.cookieDict.isEmpty }

    static func delete() {
        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies ?? [] {
            if cookie.domain.range(of: "stepic") != nil || cookie.domain.range(of: "stepik") != nil {
                storage.deleteCookie(cookie)
            }
        }
        self.cookieDict = [:]
        self.cookieHeaders = [:]
    }

    static func refresh(
        completion: @escaping () -> Void,
        error errorHandler: @escaping (String) -> Void
    ) -> Request? {
        print("refreshing session")

        let stepikURLString = StepikApplicationsInfo.stepikURL
        let stepikURL = URL(string: stepikURLString)!

        self.delete()

        return AlamofireDefaultSessionManager.shared.request(
            stepikURLString,
            parameters: nil,
            encoding: URLEncoding.default
        ).response { response in
            let error = response.error
            let response = response.response

            if let error = error {
                errorHandler((error as NSError).localizedDescription)
            }

            if let response = response {
                let cookies = HTTPCookie.cookies(
                    withResponseHeaderFields: response.allHeaderFields as! [String: String],
                    for: stepikURL
                )
                HTTPCookieStorage.shared.setCookies(cookies, for: stepikURL, mainDocumentURL: nil)

                var cookieDict = [String: String]()
                for cookie in cookies {
                    cookieDict[cookie.name] = cookie.value
                }

                print(cookieDict)

                StepikSession.cookieDict = cookieDict

                let cookiePrefix = StepikApplicationsInfo.cookiePrefix

                if let csrftoken = cookieDict["\(cookiePrefix)csrftoken"],
                   let sessionId = cookieDict["\(cookiePrefix)sessionid"] {
                    self.cookieHeaders = [
                        "Referer": "\(StepikApplicationsInfo.stepikURL)/",
                        "X-CSRFToken": csrftoken,
                        "Cookie": "\(cookiePrefix)csrftoken=\(csrftoken); \(cookiePrefix)sessionid=\(sessionId)"
                    ]
                    completion()
                } else {
                    errorHandler("bad cookies in response")
                }
            } else {
                errorHandler("No response")
            }
        }
    }
}
