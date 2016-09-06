//
//  ApiRequest.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire 


func performRequest(request: (Void->Void), error: (Void->Void)? = nil) {
    ApiRequestPerformer.performAPIRequest(request, error: error)
}

class ApiRequestPerformer {
    
    //TODO: Add error type for this
    static func performAPIRequest(completion: (Void->Void), error errorHandler: (Void->Void)? = nil) {
        if !AuthInfo.shared.hasUser {
            ApiDataDownloader.stepics.retrieveCurrentUser(success: 
                {
                    user in
                    AuthInfo.shared.user = user
                    CoreDataHelper.instance.save()
                    performRequestWithAuthorizationCheck(completion, error: errorHandler)
                }, error: {
                    errorMsg in
                    errorHandler?()
                }
            )
        } else {
            performRequestWithAuthorizationCheck(completion, error: errorHandler)
        }
         
    }
    
    private static func performRequestWithAuthorizationCheck(completion: (Void->Void), error errorHandler: (Void->Void)? = nil) {
        
        if let user = AuthInfo.shared.user {
            print("performing request with user \(user.id)")
            if user.isGuest && Session.needsRefresh {
                Session.refresh(completion: 
                    {
                        completion()
                    }, error: {
                        _ in 
                        errorHandler?()
                    }
                )
                return
            }
            
            if !user.isGuest && AuthInfo.shared.needsToRefreshToken {
                if let refreshToken = AuthInfo.shared.token?.refreshToken {
                    AuthManager.sharedManager.refreshTokenWith(refreshToken, success: 
                        {
                            t in
                            AuthInfo.shared.token = t
                            completion()
                        }, failure : {
                            error in
                            print("error while auto refresh token")
                            errorHandler?()
                        }
                    )
                    return
                } else {
                    //No token to refresh with authorized user
                    errorHandler?()
                    return
                }
            }
            
            completion()
        } else {
            errorHandler?()
        }
    }

}