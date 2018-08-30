//
//  CourseWidgetColorMode.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum CourseWidgetColorMode {
    case light
    case dark

    static var `default`: CourseWidgetColorMode {
        return .light
    }
}
