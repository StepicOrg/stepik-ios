//
// CourseInfoTabInfoBlock.swift
// stepik-ios
//
// Created by Ivan Magda on 11/9/18.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import UIKit

enum CourseInfoTabInfoBlock {
    case author(String)
    case introVideo
    case about
    case requirements
    case targetAudience
    case instructors
    case timeToComplete
    case language
    case certificate
    case certificateDetails

    var title: String {
        return self.getResources().title
    }

    var image: UIImage? {
        return UIImage(named: self.getResources().imageName)
    }

    private func getResources() -> (title: String, imageName: String) {
        switch self {
        case .author(let author):
            return (
                "\(NSLocalizedString("CourseInfoTitleAuthor", comment: "")) \(author)",
                "course-info-instructor"
            )
        case .introVideo:
            return ("", "")
        case .about:
            return (
                NSLocalizedString("CourseInfoTitleAbout", comment: ""),
                "course-info-about"
            )
        case .requirements:
            return (
                NSLocalizedString("CourseInfoTitleRequirements", comment: ""),
                "course-info-requirements"
            )
        case .targetAudience:
            return (
                NSLocalizedString("CourseInfoTitleTargetAudience", comment: ""),
                "course-info-target-audience"
            )
        case .instructors:
            return (
                NSLocalizedString("CourseInfoTitleInstructors", comment: ""),
                "course-info-instructor"
            )
        case .timeToComplete:
            return (
                NSLocalizedString("CourseInfoTitleTimeToComplete", comment: ""),
                "course-info-time-to-complete"
            )
        case .language:
            return (
                NSLocalizedString("CourseInfoTitleLanguage", comment: ""),
                "course-info-language"
            )
        case .certificate:
            return (
                NSLocalizedString("CourseInfoTitleCertificate", comment: ""),
                "course-info-certificate"
            )
        case .certificateDetails:
            return (
                NSLocalizedString("CourseInfoTitleCertificateDetails", comment: ""),
                "course-info-certificate-details"
            )
        }
    }
}
