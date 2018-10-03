//
//  LegacyAssemblies.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.10.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

@available(*, deprecated, message: "Class for backward compatibility")
final class SyllabusLegacyAssembly: Assembly {
    private let course: Course

    init(course: Course) {
        self.course = course
    }

    func makeModule() -> UIViewController {
        let viewController = ControllerHelper.instantiateViewController(
            identifier: "SectionsViewController"
        ) as! SectionsViewController
        viewController.course = course
        viewController.hidesBottomBarWhenPushed = true
        return viewController
    }
}

@available(*, deprecated, message: "Class for backward compatibility")
final class CourseInfoLegacyAssembly: Assembly {
    private let course: Course

    init(course: Course) {
        self.course = course
    }

    func makeModule() -> UIViewController {
        let viewController = ControllerHelper.instantiateViewController(
            identifier: "CoursePreviewViewController"
        ) as! CoursePreviewViewController
        viewController.course = course
        viewController.hidesBottomBarWhenPushed = true
        return viewController
    }
}
