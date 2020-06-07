//
//  CodeSample+CoreDataProperties.swift
//  Stepic
//
//  Created by Ostrenkiy on 22.06.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation

extension CodeSample {
    @NSManaged var managedInput: String?
    @NSManaged var managedOutput: String?

    @NSManaged var managedOptions: StepOptions?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "CodeSample", in: CoreDataHelper.shared.context)!
    }

    static var fetchRequest: NSFetchRequest<CodeSample> {
        NSFetchRequest<CodeSample>(entityName: "CodeSample")
    }

    convenience init() {
        self.init(entity: CodeSample.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var input: String {
        get {
             managedInput ?? ""
        }
        set(value) {
            managedInput = value
        }
    }

    var output: String {
        get {
             managedOutput ?? ""
        }
        set(value) {
            managedOutput = value
        }
    }
}
