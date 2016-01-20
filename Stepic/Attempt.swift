//
//  Attempt.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class Attempt: NSObject {
    
    var id: Int?
    var dataset : Dataset?
    var datasetUrl: String?
    var time: String?
    var status : String?
    var step : Int
    var timeLeft : String?
    var user : Int?
    
    init(json: JSON, stepName: String) {
        id = json["id"].intValue
        dataset = nil
        datasetUrl = json["dataset_url"].string
        time = json["time"].string
        status = json["status"].string
        step = json["step"].intValue
        timeLeft = json["time_left"].string
        user = json["user"].int
        super.init()
        dataset = getDatasetFromJSON(json["dataset"], stepName: stepName)
    }
    
    func getDatasetFromJSON(json: JSON, stepName: String) -> Dataset? {
        switch stepName {
        case "choice" : return ChoiceDataset(json: json)
        default: return nil
        }
    }
}
