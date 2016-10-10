//
//  UnitsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class UnitsAPI {
    let name = "units"
    
    func retrieve(lesson lessonId: Int, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ((Unit) -> Void), error errorHandler: @escaping ((UnitRetrieveError) -> Void)) -> Request {
        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/\(name)?lesson=\(lessonId)", headers: headers).responseSwiftyJSON(
            {
                _, response, json, error in 
                
                if let e = error as? NSError {
                    print("RETRIEVE units?\(lessonId): error \(e.domain) \(e.code): \(e.localizedDescription)")
                    errorHandler(.connectionError)
                    return
                }
                
                if response?.statusCode != 200 {
                    print("RETRIEVE units?\(lessonId)): bad response status code \(response?.statusCode)")
                    errorHandler(.badStatus)
                    return
                }
                
                let units = json["units"].arrayValue.map({return Unit(json: $0)})
                
                guard let unit = units.first else {
                    errorHandler(.noUnits)
                    return
                }
                
                success(unit)
                
                return
            }
        )
    }
}


//TODO: Add parameters
enum UnitRetrieveError : Error {
    case connectionError, badStatus, noUnits
}
