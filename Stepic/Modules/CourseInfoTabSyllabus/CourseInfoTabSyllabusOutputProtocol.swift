//
//  CourseInfoTabSyllabusInputProtocol.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol CourseInfoTabSyllabusOutputProtocol: class {
    func presentLesson(in unit: Unit)
    func presentPersonalDeadlinesCreation(for course: Course)
    func presentPersonalDeadlinesSettings(for course: Course)
}
