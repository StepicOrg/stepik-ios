//
//  Attempt.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SwiftyJSON

class Attempt: JSONSerializable {

    typealias IdType = Int

    var id: Int = 0
    var dataset: Dataset?
    var datasetUrl: String?
    var time: String?
    var status: String?
    var step: Int = 0
    var timeLeft: String?
    var user: Int?

    func update(json: JSON) {
        id = json["id"].intValue
        datasetUrl = json["dataset_url"].string
        time = json["time"].string
        status = json["status"].string
        step = json["step"].intValue
        timeLeft = json["time_left"].string
        user = json["user"].int
    }

    func hasEqualId(json: JSON) -> Bool {
        return id == json["id"].int
    }

    init(step: Int) {
        self.step = step
    }

    required init(json: JSON) {
        self.update(json: json)
    }

    func initDataset(json: JSON, stepName: String) {
        dataset = getDatasetFromJSON(json, stepName: stepName)
    }

    init(json: JSON, stepName: String) {
        id = json["id"].intValue
        dataset = nil
        datasetUrl = json["dataset_url"].string
        time = json["time"].string
        status = json["status"].string
        step = json["step"].intValue
        timeLeft = json["time_left"].string
        user = json["user"].int
        dataset = getDatasetFromJSON(json["dataset"], stepName: stepName)
    }

    var json: JSON {
        return [
            "step": step
        ]
    }

    fileprivate func getDatasetFromJSON(_ json: JSON, stepName: String) -> Dataset? {
        switch stepName {
        case "choice" :
            return ChoiceDataset(json: json)
        case "math", "string", "number", "code", "sql":
            return String(json: json)
        case "sorting" :
            return SortingDataset(json: json)
        case "free-answer":
            return FreeAnswerDataset(json: json)
        case "matching":
            return MatchingDataset(json: json)
        case "fill-blanks":
            return FillBlanksDataset(json: json)
        default:
            return nil
        }
    }
}
