//
//  CodeSample+CoreDataProperties.swift
//  Stepic
//
//  Created by Ostrenkiy on 22.06.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData

extension CodeSample {
    @NSManaged var managedInput: String?
    @NSManaged var managedOutput: String?
    
    @NSManaged var managedOptions: StepOptions?
    
    class var oldEntity : NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "CodeSample", in: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: CodeSample.oldEntity, insertInto: CoreDataHelper.instance.context)
    }
    
    var input: String {
        get {
            return managedInput ?? ""
        }
        set(value) {
            managedInput = value
        }
    }
    
    var output: String {
        get {
            return managedOutput ?? ""
        }
        set(value) {
            managedOutput = value
        }
    }    
}
