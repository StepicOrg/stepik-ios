//
//  Constants.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 14/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class Constants {
    // For backward compatibility with the Stepic target.
    static let placeholderImage = UIImage(named: "stepic_logo_black_and_white")!
    static let joinCourseButtonText = NSLocalizedString("JoinCourse", comment: "")
    static let alreadyJoinedCourseButtonText = NSLocalizedString("Studying", comment: "")

    struct Images {
        static let videoDark = UIImage(named: "ic_video_dark")!
        static let theoryDark = UIImage(named: "ic_theory_dark")!
        static let hardDark = UIImage(named: "ic_hard_dark")!
        static let easyDark = UIImage(named: "ic_easy_dark")!
    }
}
