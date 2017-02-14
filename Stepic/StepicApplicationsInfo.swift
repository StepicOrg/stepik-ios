//
//  StepicApplicationsInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct StepicApplicationsInfo {
    static var social : ApplicationInfo? = ApplicationInfo(
        clientId: "LubtinhKaUBwYG7hIvnvNs0ucFOXcn3dfb9383BT",
        clientSecret: "ExHhWF11exXAjRRVqxaU83l9UTDGGpH8N25xaiQg6pWb19cRnoMh2FPEss1Xp88qd34g3JxhjXsrTy5IxnV3QG4Mct0nc1lFt7IcEd8THCwAPf5IryMMKLJbvpZIk57J",
        credentials: "THVidGluaEthVUJ3WUc3aEl2bnZOczB1Y0ZPWGNuM2RmYjkzODNCVDpFeEhoV0YxMWV4WEFqUlJWcXhhVTgzbDlVVERHR3BIOE4yNXhhaVFnNnBXYjE5Y1Jub01oMkZQRXNzMVhwODhxZDM0ZzNKeGhqWHNyVHk1SXhuVjNRRzRNY3QwbmMxbEZ0N0ljRWQ4VEhDd0FQZjVJcnlNTUtMSmJ2cFpJazU3Sg==",
        redirectUri: "stepic://stepic.org/auth"
    )
    
    static var password : ApplicationInfo? = ApplicationInfo(
        clientId: "mxTldCXcL6WCnmHbElZAYDtRH4yHWGFqVD8kMPNK",
        clientSecret: "P29j50MBdIUSMJF8qy2LWIA6Zai1YschwrOB3WZLqqof6fMdkLsKIkWLO2yGMbMUrnbO5mBUmNIaTfHcSdn4QHoSdExWH0dkAuzOaLkSptu85DhcWtwM2kD53PnZrP29",
        credentials: "bXhUbGRDWGNMNldDbm1IYkVsWkFZRHRSSDR5SFdHRnFWRDhrTVBOSzpQMjlqNTBNQmRJVVNNSkY4cXkyTFdJQTZaYWkxWXNjaHdyT0IzV1pMcXFvZjZmTWRrTHNLSWtXTE8yeUdNYk1Vcm5iTzVtQlVtTklhVGZIY1NkbjRRSG9TZEV4V0gwZGtBdXpPYUxrU3B0dTg1RGhjV3R3TTJrRDUzUG5aclAyOQ==",
        redirectUri: "stepic://stepic.org/password"
    )

    static let apiURL = "https://dev.stepik.org/api"    
    static let oauthURL = "https://dev.stepik.org/oauth2"
    static let stepicURL = "https://dev.stepik.org"
    static let versionInfoURL = "https://stepik.org/media/attachments/lesson/26869/version.json"
   
    static let cookiePrefix = "dev_"

    
    static let doesAllowCourseUnenrollment = true
    static let inAppUpdatesAvailable = false
}
