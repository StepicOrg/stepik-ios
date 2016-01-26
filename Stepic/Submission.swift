//
//  Submission.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class Submission: NSObject {
    var id : Int?
    var status : String?
    var reply : Reply?
    var attempt : Int?
    
    init(json: JSON, stepName: String) {
        id = json["id"].int
        status = json["status"].string
        attempt = json["attempt"].int
        reply = nil
        super.init()
        reply = getReplyFromJSON(json["reply"], stepName: stepName)
    }
    
    private func getReplyFromJSON(json: JSON, stepName: String) -> Reply? {
        switch stepName {
        case "choice" : return ChoiceReply(json: json)
        case "string" : return TextReply(json: json)
        case "number": return NumberReply(json: json)
//        case "free_answer": return String(json: json)
        default: return nil
        }
    }
    
}
