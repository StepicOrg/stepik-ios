//
//  Session.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation

final class Session {
    static func delete() {
        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies ?? [] {
            if cookie.domain.range(of: "stepic") != nil || cookie.domain.range(of: "stepik") != nil {
                storage.deleteCookie(cookie)
            }
        }
        cookieDict = [:]
        cookieHeaders = [:]
    }

    static func refresh(completion: @escaping (() -> Void), error errorHandler: @escaping ((String) -> Void)) -> Request? {
        print("refreshing session")
        let stepicURLString = StepikApplicationsInfo.stepikURL
        let stepicURL = URL(string: stepicURLString)!
        delete()

        return AlamofireDefaultSessionManager.shared.request(stepicURLString, parameters: nil, encoding: URLEncoding.default).response {
            response in

            let error = response.error
            let response = response.response

            if let e = error {
                errorHandler((e as NSError).localizedDescription)
            }

            if let r = response {
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: r.allHeaderFields as! [String: String], for: stepicURL)
                HTTPCookieStorage.shared.setCookies(cookies, for: stepicURL, mainDocumentURL: nil)

                var cookieDict = [String: String]()
                for cookie in cookies {
                    cookieDict[cookie.name] = cookie.value
                }

                print(cookieDict)

                Session.cookieDict = cookieDict

                if let csrftoken = cookieDict["\(StepikApplicationsInfo.cookiePrefix)csrftoken"],
                    let sessionId = cookieDict["\(StepikApplicationsInfo.cookiePrefix)sessionid"] {
                    Session.cookieHeaders = [
                        "Referer": "\(StepikApplicationsInfo.stepikURL)/",
                        "X-CSRFToken": csrftoken,
                        "Cookie": "csrftoken=\(csrftoken); sessionid=\(sessionId)"
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

    static var cookieHeaders = [String: String]()
    static var needsRefresh: Bool { self.cookieHeaders.isEmpty }

    static var cookieDict = [String: String]()
    static var hasCookies: Bool { !self.cookieDict.isEmpty }
}
