//
//  Attempt.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import SwiftyJSON
import UIKit

final class Attempt: JSONSerializable {
    typealias IdType = Int

    var id: Int = 0
    var dataset: Dataset?
    var datasetUrl: String?
    var time: String?
    var status: String?
    var step: Int = 0
    var timeLeft: String?
    var user: Int?

    var json: JSON {
        [
            JSONKey.step.rawValue: step
        ]
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.datasetUrl = json[JSONKey.datasetURL.rawValue].string
        self.time = json[JSONKey.time.rawValue].string
        self.status = json[JSONKey.status.rawValue].string
        self.step = json[JSONKey.step.rawValue].intValue
        self.timeLeft = json[JSONKey.timeLeft.rawValue].string
        self.user = json[JSONKey.user.rawValue].int
    }

    func hasEqualId(json: JSON) -> Bool {
        self.id == json[JSONKey.id.rawValue].int
    }

    init(step: Int) {
        self.step = step
    }

    required init(json: JSON) {
        self.update(json: json)
    }

    func initDataset(json: JSON, stepName: String) {
        self.dataset = self.getDatasetFromJSON(json, stepName: stepName)
    }

    init(json: JSON, stepName: String) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.dataset = nil
        self.datasetUrl = json[JSONKey.datasetURL.rawValue].string
        self.time = json[JSONKey.time.rawValue].string
        self.status = json[JSONKey.status.rawValue].string
        self.step = json[JSONKey.step.rawValue].intValue
        self.timeLeft = json[JSONKey.timeLeft.rawValue].string
        self.user = json[JSONKey.user.rawValue].int
        self.dataset = self.getDatasetFromJSON(json[JSONKey.dataset.rawValue], stepName: stepName)
    }

    private func getDatasetFromJSON(_ json: JSON, stepName: String) -> Dataset? {
        switch stepName {
        case "choice":
            return ChoiceDataset(json: json)
        case "math", "string", "number", "code", "sql":
            return String(json: json)
        case "sorting":
            return SortingDataset(json: json)
        case "free-answer":
            return FreeAnswerDataset(json: json)
        case "matching":
            return MatchingDataset(json: json)
        default:
            return nil
        }
    }

    enum JSONKey: String {
        case id
        case datasetURL = "dataset_url"
        case time
        case status
        case step
        case timeLeft = "time_left"
        case user
        case dataset
    }
}
