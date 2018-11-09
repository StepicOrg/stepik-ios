//
//  CourseInfoTabInfoViewModel.swift
//  Stepic
//
//  Created by Ivan Magda on 11/2/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

struct CourseInfoTabInfoViewModel {
    let blocks: [CourseInfoTabInfoBlockViewModelProtocol]
}

struct CourseInfoTabInfoTextBlockViewModel: CourseInfoTabInfoBlockViewModelProtocol {
    let blockType: CourseInfoTabInfoBlockType
    let message: String
}

struct CourseInfoTabInfoIntroVideoBlockViewModel: CourseInfoTabInfoBlockViewModelProtocol {
    var blockType: CourseInfoTabInfoBlockType {
        return .introVideo
    }

    let introURL: URL?
}

struct CourseInfoTabInfoInstructorViewModel {
    let avatarURL: URL?
    let title: String
    let description: String
}

struct CourseInfoTabInfoInstructorsBlockViewModel: CourseInfoTabInfoBlockViewModelProtocol {
    var blockType: CourseInfoTabInfoBlockType {
        return .instructors
    }

    let instructors: [CourseInfoTabInfoInstructorViewModel]
}
