//
//  AdaptiveStepicApplicationsInfo.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 23.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
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
        clientId: "1r15RgyxPvb91KSSDGwDZlFWzEXlegD9uz52MN4O",
        clientSecret: "plKrsCERhQJG9j83LvX2kGZOGj1F4GIzvgazrz1W0Ji8nQxvndrbiIpmx1tMuD1ciiN32Rp3fb4ce5JFpfL3Zq0S3LqDAnHjaDB6wLTtnwB25VlngSO58cDBLVqk7dGA",
        credentials: "MXIxNVJneXhQdmI5MUtTU0RHd0RabEZXekVYbGVnRDl1ejUyTU40TzpwbEtyc0NFUmhRSkc5ajgzTHZYMmtHWk9HajFGNEdJenZnYXpyejFXMEppOG5ReHZuZHJiaUlwbXgxdE11RDFjaWlOMzJScDNmYjRjZTVKRnBmTDNacTBTM0xxREFuSGphREI2d0xUdG53QjI1VmxuZ1NPNThjREJMVnFrN2RHQQ==",
        redirectUri: "stepic://stepic.org/password"
    )
    
    static let apiURL = "https://stepik.org/api"
    static let oauthURL = "https://stepik.org/oauth2"
    static let stepicURL = "https://stepik.org"
    static let versionInfoURL = "https://stepik.org/media/attachments/lesson/26869/version.json"
    
    static let doesAllowCourseUnenrollment = true
    static let inAppUpdatesAvailable = false
    
    static let cookiePrefix = ""
    
    static let adaptiveCourseId = 1838
}
