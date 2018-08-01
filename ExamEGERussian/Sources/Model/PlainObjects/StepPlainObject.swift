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

    let id: Int
    let lessonId: Int
    let position: Int
    let text: String
    let type: StepType

    var image: UIImage {
        switch type {
        case .video:
            return #imageLiteral(resourceName: "ic_video_dark")
        case .text:
            return #imageLiteral(resourceName: "ic_theory_dark")
        case .code, .dataset, .admin, .sql:
            return #imageLiteral(resourceName: "ic_hard_dark")
        default:
            return #imageLiteral(resourceName: "ic_easy_dark")
        }
    }
}
