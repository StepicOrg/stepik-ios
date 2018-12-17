//
//  CourseInfoTabSyllabusSectionViewModel.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct CourseInfoTabSyllabusSectionViewModel {
    let title: String
    let units: [CourseInfoTabSyllabusUnitViewModel]
}

struct CourseInfoTabSyllabusUnitViewModel {
    let title: String
    let coverImageURL: URL?
}
