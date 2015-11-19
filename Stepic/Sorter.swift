//
//  Sorter.swift
//  Stepic
//
//  Created by Alexander Karpov on 26.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation

struct Sorter {
    static func sort<T : JSONInitializable>(array : [T], byIds ids: [Int]) -> [T] {
        var res : [T] = []
        
        for id in ids {
            let elements = array.filter({return $0.id == id})
            if elements.count == 1 {
                res += [elements[0]]
            } else {
                //TODO : Maybe should throw exception here
                print("Something went wrong")
            }
        }
        
        return res
    }
    
    static func sort(array: [Progress], byIds ids: [String]) -> [Progress] {
        var res : [Progress] = []
        
        for id in ids {
            let elements = array.filter({return $0.id == id})
            if elements.count == 1 {
                res += [elements[0]]
            } else {
                //TODO : Maybe should throw exception here
                print("Something went wrong")
            }
        }
        
        return res
    }
    
    static func sort(assignments : [Assignment], steps : [Step]) -> [Assignment] {
        
        var res : [Assignment] = []

        for step in steps {
            let elements = assignments.filter({return $0.stepId == step.id})
            if elements.count == 1 {
                res += [elements[0]]
            } else {
                //TODO : Maybe should throw exception here
                print("Something went wrong")
            }
        }
        
        return res
    }
}