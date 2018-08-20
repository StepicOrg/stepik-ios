//
//  StepPlainObject.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit.UIImage

struct StepPlainObject {
    let id: Int
    let lessonId: Int
    let position: Int
    let text: String
    let type: StepType
    let progressId: String?
    var isPassed = false

    var image: UIImage {
        switch type {
        case .video:
            return ImageAsset.StepIcons.videoDark.image
        case .text:
            return ImageAsset.StepIcons.theoryDark.image
        case .code, .dataset, .admin, .sql:
            return ImageAsset.StepIcons.adminDark.image
        default:
            return ImageAsset.StepIcons.easyDark.image
        }
    }

    // MARK: Types

    enum StepType: String {
        case text
        case choice
        case string
        case number
        case freeAnswer = "free-answer"
        case math
        case sorting
        case matching
        case fillBlanks = "fill-blanks"
        case code
        case sql
        case table
        case video
        case dataset
        case admin
    }
}
