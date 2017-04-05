//
//  SearchResultsAPI.swift
//  Stepic
//
//  Created by Alexander Karpov on 05.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SearchResultsAPI : APIEndpoint {
    let name = "search-results"
    
    func search(query: String, type: String?, page: Int?, headers: [String: String] = AuthInfo.shared.initialHTTPHeaders, success: @escaping ([SearchResult], Meta) -> Void, error errorHandler: @escaping (NSError)->Void) -> Request? {
        var params : Parameters = [:]
        
        params["access_token"] = AuthInfo.shared.token?.accessToken as NSObject?
        params["query"] = query
        
        if let p = page { 
            params["page"] = p 
        }
        if let t = type {
            params["type"] = t
        }
        
        return Alamofire.request("\(StepicApplicationsInfo.apiURL)/search-results", method: .get, parameters: params, encoding: URLEncoding.default, headers: headers).responseSwiftyJSON({ 
            response in
            
            var error = response.result.error
            var json : JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
            let response = response.response
            
            
            if let e = error as? NSError {
                errorHandler(e)
                return
            }
                        
            let meta = Meta(json: json["meta"])
            var results = [SearchResult]() 
            for resultJson in json["search-results"].arrayValue {
                results += [SearchResult(json: resultJson)]
            }
            
            success(results, meta)
        })
    }
}
