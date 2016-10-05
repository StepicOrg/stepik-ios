//
//  AlamofireSwiftyJSON.swift
//  AlamofireSwiftyJSON
//
//  Created by Pinglin Tang on 14-9-22.
//  Copyright (c) 2014 SwiftyJSON. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

// MARK: - Request for Swift JSON

extension Request {
    
    /**
     Adds a handler to be called once the request has finished.
     
     :param: completionHandler A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the SwiftyJSON enum, if one could be created from the URL response and data, and any error produced while creating the SwiftyJSON enum.
     
     :returns: The request.
     */
    public func responseSwiftyJSON(_ completionHandler: (URLRequest, HTTPURLResponse?, SwiftyJSON.JSON, Error?) -> Void) -> Self {
        return responseSwiftyJSON(nil, options:JSONSerialization.ReadingOptions.allowFragments, completionHandler:completionHandler)
    }
    
    /**
     Adds a handler to be called once the request has finished.
     
     :param: queue The queue on which the completion handler is dispatched.
     :param: options The JSON serialization reading options. `.AllowFragments` by default.
     :param: completionHandler A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the SwiftyJSON enum, if one could be created from the URL response and data, and any error produced while creating the SwiftyJSON enum.
     
     :returns: The request.
     */
    public func responseSwiftyJSON(_ queue: DispatchQueue? = nil, options: JSONSerialization.ReadingOptions = .allowFragments, completionHandler: (URLRequest, HTTPURLResponse?, JSON, Error?) -> Void) -> Self {
        
        // With Alamofire 3, completionHandler returns a Response struct instead of request, response, result.
        //For more information about Response struct see: https://github.com/Alamofire/Alamofire/blob/master/Documentation/Alamofire%203.0%20Migration%20Guide.md
        return response(queue: queue, responseSerializer: Request.JSONResponseSerializer(options: options), completionHandler: { (response) -> Void in
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                var responseJSON: JSON
                if response.result.isFailure
                {
                    responseJSON = JSON.null
                } else {
                    responseJSON = SwiftyJSON.JSON(response.result.value!)
                }
                (queue ?? DispatchQueue.main).async(execute: {
                    completionHandler(response.request!, response.response, responseJSON, response.result.error)
                })
            })
        })
        
    }
}
