//
//  Progress.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Progress: NSManagedObject, JSONInitializable {

    typealias idType = String

    convenience required init(json: JSON) {
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
    }

    func update(json: JSON) {
        initialize(json)
    }

    func hasEqualId(json: JSON) -> Bool {
        return id == json["id"].stringValue
    }

    static func deleteAllStoredProgresses() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Progress")

        do {
            let results = try CoreDataHelper.instance.context.fetch(request) as? [Progress]
            for obj in results ?? [] {
                CoreDataHelper.instance.deleteFromStore(obj)
            }
        } catch {
            print("\n\n\nCould nnot delete progresses! \n\n\n")
        }

    }
}
