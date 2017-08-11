//
//  GlobalFunctions.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.02.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

//Returns tuple of unique non-intersecting and intersecting courses
func findUniqueIntersectionsBetween<T: Equatable>(_ arr1: [T], and arr2: [T]) -> ([T], [T]) {
    var notIntersected = [T]()
    var intersected = [T]()

    for element in arr2 {
        if let _ = arr1.index(of: element) {
            if let _ = intersected.index(of: element) {
                print("wow, there are non-unique courses!")
            } else {
                intersected += [element]
            }
        } else {
            if let _ = notIntersected.index(of: element) {
                print("wow, there are non-unique courses!")
            } else {
                notIntersected += [element]
            }
        }
    }

    return (notIntersected, intersected)
}

func removeIntersectedElements<T: Equatable>(_ arr1: inout [T], _ arr2: inout [T]) {
    for intersectedElement in findUniqueIntersectionsBetween(arr1, and: arr2).1 {
        if let index1 = arr1.index(of: intersectedElement),
            let index2 = arr2.index(of: intersectedElement) {
                arr1.remove(at: index1)
                arr2.remove(at: index2)
        } else {
            print("Strange error occured")
        }
    }
}
