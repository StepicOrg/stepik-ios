//
//  ImageAsset.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 14/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

struct ImageAsset {
    enum StepIcons: String {
        case easyWhite = "easy_quiz"
        case easyDark = "ic_easy_dark"
        case adminWhite = "ic_admin"
        case adminDark = "ic_hard_dark"
        case animationWhite = "ic_animation"
        case chemicalWhite = "ic_chemical"
        case choiceWhite = "ic_choice"
        case codeWhite = "ic_code"
        case datasetWhite = "ic_dataset"
        case fillBlanksWhite = "ic_fill-blanks"
        case freeAnswerWhite = "ic_free-answer"
        case matchingWhite = "ic_matching"
        case mathWhite = "ic_math"
        case number = "ic_number"
        case puzzleWhite = "ic_puzzle"
        case pycharmWhite = "ic_pycharm"
        case sortingWhite = "ic_sorting"
        case stringWhite = "ic_string"
        case tableWhite = "ic_table"
        case theoryWhite = "ic_theory"
        case theoryDark = "ic_theory_dark"
        case filmstripWhite = "video"
        case videoWhite = "ic_video"
        case videoDark = "ic_video_dark"

        var image: UIImage {
            return UIImage(named: rawValue)!
        }
    }
}
