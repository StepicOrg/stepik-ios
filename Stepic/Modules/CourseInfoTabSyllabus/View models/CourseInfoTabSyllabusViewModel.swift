//
//  CourseInfoTabSyllabusSectionViewModel.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13/12/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct CourseInfoTabSyllabusSectionViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType

    let index: String
    let title: String
    let progress: Float

    var units: [UnitViewModelWrapper]

    var downloadState: CourseInfoTabSyllabus.DownloadState

    enum UnitViewModelWrapper {
        case placeholder
        case normal(viewModel: CourseInfoTabSyllabusUnitViewModel)
    }
}

struct CourseInfoTabSyllabusUnitViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType

    let title: String
    let coverImageURL: URL?
    let progress: Float

    let likesCount: Int?
    let learnersLabelText: String
    let progressLabelText: String?

    var downloadState: CourseInfoTabSyllabus.DownloadState
}
