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
        clientId: "FTQwD022nS8FDO25NzfTyYv1rFGvyHHEtVrk1Men",
        clientSecret: "4VMEZVDV5ApYBvSk1Y5yqDQthp4PO4NpXauaPnqn7rSS2KZd3PJleebX1GqHweWRSCCPZ2KgN8hRpqH1IGIfvRBjDcpPlVib2mTHZAXTm49agD16lqMhnmHBGfVYRhOz",
        credentials: "RlRRd0QwMjJuUzhGRE8yNU56ZlR5WXYxckZHdnlISEV0VnJrMU1lbjo0Vk1FWlZEVjVBcFlCdlNrMVk1eXFEUXRocDRQTzROcFhhdWFQbnFuN3JTUzJLWmQzUEpsZWViWDFHcUh3ZVdSU0NDUFoyS2dOOGhScHFIMUlHSWZ2UkJqRGNwUGxWaWIybVRIWkFYVG00OWFnRDE2bHFNaG5tSEJHZlZZUmhPeg==",
        redirectUri: "stepic://stepic.org/oauth"
    )

    static let apiURL = "https://dev.stepik.org/api"    
    static let oauthURL = "https://dev.stepik.org/oauth2"
    static let stepicURL = "https://dev.stepik.org"
    static let versionInfoURL = "https://stepik.org/media/attachments/lesson/26869/version.json"
   
    static let cookiePrefix = "dev_"

    
    static let doesAllowCourseUnenrollment = true
    static let inAppUpdatesAvailable = false
}
