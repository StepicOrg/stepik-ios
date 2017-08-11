//
//  LastStepGlobalContext.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class LastStepGlobalContext {
    private init() {}

    static let context = LastStepGlobalContext()

    var course: Course?
    var unitId: Int?
    var stepId: Int?
}
