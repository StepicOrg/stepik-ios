//
//  ApiRequest.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire 

func performAPIRequest(request: Request?, allSuccess: (Void->Void), oneFailed: (Void->Void)) {
    if let request = request {
        var requests = [Request]()
        
        if !AuthInfo.shared.hasUser {
            //TODO: Add request to stepics/1
            let stepicsRequest = ApiDataDownloader.stepics.retrieveCurrentUser(success: 
                {
                    user in
                    AuthInfo.shared.user = user
                }, error: {
                    errorMsg in
                }
            )
            requests.append(stepicsRequest)
        }
        
        if AuthInfo.shared.needsToRefreshToken {
//            if let tokenRefreshRequest = AuthManager.sharedManager.refreshTokenWith(<#T##refresh_token: String##String#>, success: <#T##(token: StepicToken) -> Void#>, failure: <#T##(error: ErrorType) -> Void#>) {
                
//            }
           //TODO: Add request to refresh token 
        }
        
        requests.append(request)
        
    }
}