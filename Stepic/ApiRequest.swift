//
//  ApiRequest.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire 


enum PerformRequestError : Error {
    case noAccessToRefreshToken, other
}

//Should preferrably be called from a UIViewController subclass
func performRequest(_ request: @escaping ((Void)->Void), error: ((PerformRequestError)->Void)? = nil) {
    ApiRequestPerformer.performAPIRequest(request, error: error)
}

class ApiRequestPerformer {
    
    static func performAPIRequest(_ completion: @escaping ((Void)->Void), error errorHandler: ((PerformRequestError)->Void)? = nil) {
        print("performing API request")
        if !AuthInfo.shared.hasUser {
            print("no user in AuthInfo, retrieving")
            ApiDataDownloader.stepics.retrieveCurrentUser(success: 
                {
                    user in
                    AuthInfo.shared.user = user
                    User.removeAllExcept(user)
                    print("retrieved current user")
                    performRequestWithAuthorizationCheck(completion, error: errorHandler)
                }, error: {
                    errorMsg in
                    errorHandler?(.other)
                }
            )
        } else {
            performRequestWithAuthorizationCheck(completion, error: errorHandler)
        }
         
    }
    
    fileprivate static func performRequestWithAuthorizationCheck(_ completion: @escaping ((Void)->Void), error errorHandler: ((PerformRequestError)->Void)? = nil) {
        
//        if let user = AuthInfo.shared.user {
//            print("performing request with user \(user.id)")
        if !AuthInfo.shared.isAuthorized && Session.needsRefresh {
            _ = Session.refresh(completion: 
                {
                    completion()
                }, error: {
                    _ in 
                    errorHandler?(.other)
                }
            )
            return
        }
        
        if AuthInfo.shared.isAuthorized && AuthInfo.shared.needsToRefreshToken {
            if let refreshToken = AuthInfo.shared.token?.refreshToken {
                AuthManager.sharedManager.refreshTokenWith(refreshToken, success: 
                    {
                        t in
                        AuthInfo.shared.token = t
                        completion()
                    }, failure : {
                        error in
                        print("error while auto refresh token")
                        if error == TokenRefreshError.noAccess {
                            errorHandler?(.noAccessToRefreshToken)
                        } else {
                            errorHandler?(.other)
                        }
                    }
                )
                return
            } else {
                    //No token to refresh with authorized user
                errorHandler?(.other)
                return
            }
        }
                    
        completion()
    }

}
