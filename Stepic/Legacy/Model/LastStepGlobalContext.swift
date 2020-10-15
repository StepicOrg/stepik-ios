//
//  LastStepGlobalContext.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

final class LastStepGlobalContext {
    private init() {}

    static let context = LastStepGlobalContext()

    var course: Course?
    var unitID: Unit.IdType?
    var stepID: Step.IdType?
}
