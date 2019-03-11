//
//  ContinueCourseViewModel.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 25.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct ContinueCourseViewModel {
    let title: String
    let coverImageURL: URL?
    let progress: (description: String, value: Float)?
}
