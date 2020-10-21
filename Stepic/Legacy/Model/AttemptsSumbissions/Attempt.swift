//
//  Attempt.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation
import SwiftyJSON

final class Attempt: JSONSerializable {
    typealias IdType = Int

    var id: Int = 0
    var dataset: Dataset?
    var datasetURL: String?
    var time: String?
    var status: String?
    var stepID: Step.IdType = 0
    var timeLeft: String?
    var userID: User.IdType?

    var json: JSON { [JSONKey.step.rawValue: stepID] }

    init(stepID: Step.IdType) {
        self.stepID = stepID
    }

    init(
        id: Int,
        dataset: Dataset?,
        datasetURL: String?,
        time: String?,
        status: String?,
        stepID: Step.IdType,
        timeLeft: String?,
        userID: User.IdType?
    ) {
        self.id = id
        self.dataset = dataset
        self.datasetURL = datasetURL
        self.time = time
        self.status = status
        self.stepID = stepID
        self.timeLeft = timeLeft
        self.userID = userID
    }

    init(json: JSON, stepBlockName: String) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.dataset = nil
        self.datasetURL = json[JSONKey.datasetURL.rawValue].string
        self.time = json[JSONKey.time.rawValue].string
        self.status = json[JSONKey.status.rawValue].string
        self.stepID = json[JSONKey.step.rawValue].intValue
        self.timeLeft = json[JSONKey.timeLeft.rawValue].string
        self.userID = json[JSONKey.user.rawValue].int
        self.dataset = self.getDatasetFromJSON(json[JSONKey.dataset.rawValue], stepBlockName: stepBlockName)
    }

    required init(json: JSON) {
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.datasetURL = json[JSONKey.datasetURL.rawValue].string
        self.time = json[JSONKey.time.rawValue].string
        self.status = json[JSONKey.status.rawValue].string
        self.stepID = json[JSONKey.step.rawValue].intValue
        self.timeLeft = json[JSONKey.timeLeft.rawValue].string
        self.userID = json[JSONKey.user.rawValue].int
    }

    func hasEqualId(json: JSON) -> Bool {
        self.id == json[JSONKey.id.rawValue].int
    }

    func initDataset(json: JSON, stepBlockName: String) {
        self.dataset = self.getDatasetFromJSON(json, stepBlockName: stepBlockName)
    }

    private func getDatasetFromJSON(_ json: JSON, stepBlockName: String) -> Dataset? {
        guard let blockType = Block.BlockType(rawValue: stepBlockName) else {
            return nil
        }

        switch blockType {
        case .choice:
            return ChoiceDataset(json: json)
        case .math, .string, .number, .code, .sql:
            return StringDataset(json: json)
        case .sorting:
            return SortingDataset(json: json)
        case .fillBlanks:
            return FillBlanksDataset(json: json)
        case .freeAnswer:
            return FreeAnswerDataset(json: json)
        case .matching:
            return MatchingDataset(json: json)
        case .table:
            return TableDataset(json: json)
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
