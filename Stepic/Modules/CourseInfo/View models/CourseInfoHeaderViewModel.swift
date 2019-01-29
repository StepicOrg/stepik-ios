//
//  CourseInfoHeaderViewModel.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.11.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct CourseInfoProgressViewModel {
    let progress: Float
    let progressLabelText: String
}

struct CourseInfoHeaderViewModel {
    let title: String
    let coverImageURL: URL?

    let rating: Int
    let learnersLabelText: String
    let progress: CourseInfoProgressViewModel?
    let isVerified: Bool
    let isEnrolled: Bool
}
