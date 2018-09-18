//
//  CourseListOutputProtocol.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 17.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol CourseListOutputProtocol: class {
    func openCourseList(_ courseList: CourseListType)
    func openCourseInfo(_ course: CourseWidgetViewModel)
}
