//
//  CourseInfoHeaderViewModel.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.11.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct CourseInfoProgressViewModel {
    var progress: Float
    var progressLabelText: String
}

struct CourseInfoHeaderViewModel {
    var title: String
    var coverImageURL: URL?

    var rating: Int
    var learnersLabelText: String
    var progress: CourseInfoProgressViewModel?
    var isVerified: Bool
}
