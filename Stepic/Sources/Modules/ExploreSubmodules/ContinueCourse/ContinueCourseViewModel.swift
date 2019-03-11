//
//  ContinueCourseViewModel.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 25.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct ContinueCourseViewModel {
    typealias ProgressDescription = (description: String, value: Float)?

    let title: String
    let coverImageURL: URL?
    let progress: ProgressDescription
}
