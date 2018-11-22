//
// CourseInfoTabInfoViewModel.swift
// stepik-ios
//
//  Created by Ivan Magda on 11/2/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

struct CourseInfoTabInfoViewModel {
    let author: String
    let introVideoURL: URL?

    let aboutText: String
    let requirementsText: String
    let targetAudienceText: String

    let timeToCompleteText: String
    let languageText: String
    let certificateText: String
    let certificateDetailsText: String

    let instructors: [CourseInfoTabInfoInstructorViewModel]

    let actionButtonTitle: String
}

struct CourseInfoTabInfoInstructorViewModel {
    let avatarImageURL: URL?
    let title: String
    let description: String
}
