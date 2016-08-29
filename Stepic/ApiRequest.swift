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
        }
        
        if AuthInfo.shared.needsToRefreshToken {
           //TODO: Add request to refresh token 
        }
        
        requests.addItem(request)
        
    }
}