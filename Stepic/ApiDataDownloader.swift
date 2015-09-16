//
//  ApiDataDownloader.swift
//  Stepic
//
//  Created by Alexander Karpov on 15.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ApiDataDownloader: NSObject {
    
    static let sharedDownloader = ApiDataDownloader()
    private override init() {}
    
    func getCoursesWith(featured: Bool?, page: Int, success : ([Course], Bool) -> Void, failure : (error : NSError) -> Void) {
        let params : [String : NSObject] = [:]

        Alamofire.request(.GET, "https://stepic.org/api/courses", parameters: params, encoding: .URL).responseSwiftyJSON({
            (_, _, json, error) in
            
            if let e = error {
                failure(error: e)
                return
            }
            
            let meta = Meta(json: json["meta"])
            var courses : [Course] = []
            for courseJSON in json["courses"].arrayValue {
                courses += [Course(json: courseJSON)]
            }
        })
    }
}
