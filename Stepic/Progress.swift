//
//  Progress.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

final class Progress: NSManagedObject, JSONSerializable, IDFetchable {
    typealias IdType = String

    required convenience init(json: JSON) {
        self.init()
        initialize(json)
    }

    func initialize(_ json: JSON) {
        id = json["id"].stringValue
        isPassed = json["is_passed"].boolValue
        score = json["score"].intValue
        cost = json["cost"].intValue
        numberOfSteps = json["n_steps"].intValue
        numberOfStepsPassed = json["n_steps_passed"].intValue
        lastViewed = json["last_viewed"].doubleValue
    }

    var json: JSON {
        [
            "id": id,
            "is_passed": isPassed,
            "score": score,
            "cost": cost,
            "n_steps": numberOfSteps,
            "n_steps_passed": numberOfStepsPassed,
            "last_viewed": lastViewed
        ]
    }

    func update(json: JSON) {
        initialize(json)
    }

    var percentPassed: Float {
        self.numberOfSteps != 0
            ? Float(self.numberOfStepsPassed) / Float(self.numberOfSteps) * 100
            : 100.0
    }

    static func deleteAllStoredProgresses() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Progress")

        do {
            let results = try CoreDataHelper.shared.context.fetch(request) as? [Progress]
            for obj in results ?? [] {
                CoreDataHelper.shared.deleteFromStore(obj)
            }
        } catch {
            print("\n\n\nCould nnot delete progresses! \n\n\n")
        }
    }
}
