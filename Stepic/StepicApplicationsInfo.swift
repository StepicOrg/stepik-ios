//
//  StepicApplicationsInfo.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct StepicApplicationsInfo {
    
    static var social = ApplicationInfo(
        clientId: "LubtinhKaUBwYG7hIvnvNs0ucFOXcn3dfb9383BT",
        clientSecret: "ExHhWF11exXAjRRVqxaU83l9UTDGGpH8N25xaiQg6pWb19cRnoMh2FPEss1Xp88qd34g3JxhjXsrTy5IxnV3QG4Mct0nc1lFt7IcEd8THCwAPf5IryMMKLJbvpZIk57J",
        credentials: "THVidGluaEthVUJ3WUc3aEl2bnZOczB1Y0ZPWGNuM2RmYjkzODNCVDpFeEhoV0YxMWV4WEFqUlJWcXhhVTgzbDlVVERHR3BIOE4yNXhhaVFnNnBXYjE5Y1Jub01oMkZQRXNzMVhwODhxZDM0ZzNKeGhqWHNyVHk1SXhuVjNRRzRNY3QwbmMxbEZ0N0ljRWQ4VEhDd0FQZjVJcnlNTUtMSmJ2cFpJazU3Sg==",
        redirectUri: "stepic://stepic.org/auth"
    )
    
    static var password = ApplicationInfo(
        clientId: "1r15RgyxPvb91KSSDGwDZlFWzEXlegD9uz52MN4O",
        clientSecret: "plKrsCERhQJG9j83LvX2kGZOGj1F4GIzvgazrz1W0Ji8nQxvndrbiIpmx1tMuD1ciiN32Rp3fb4ce5JFpfL3Zq0S3LqDAnHjaDB6wLTtnwB25VlngSO58cDBLVqk7dGA",
        credentials: "MXIxNVJneXhQdmI5MUtTU0RHd0RabEZXekVYbGVnRDl1ejUyTU40TzpwbEtyc0NFUmhRSkc5ajgzTHZYMmtHWk9HajFGNEdJenZnYXpyejFXMEppOG5ReHZuZHJiaUlwbXgxdE11RDFjaWlOMzJScDNmYjRjZTVKRnBmTDNacTBTM0xxREFuSGphREI2d0xUdG53QjI1VmxuZ1NPNThjREJMVnFrN2RHQQ==",
        redirectUri: "stepic://stepic.org/password"
    )

}

struct ApplicationInfo {
    var clientId : String
    var clientSecret: String
    var credentials : String
    var redirectUri : String
    
    init(clientId id: String, clientSecret secret: String, credentials c : String, redirectUri uri: String) {
        self.clientId = id
        self.clientSecret = secret
        self.credentials = c
        self.redirectUri = uri
    }
}