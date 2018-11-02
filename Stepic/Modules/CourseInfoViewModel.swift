//
//  CourseInfoViewModel.swift
//  Stepic
//
//  Created by Ivan Magda on 11/2/18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum CourseInfoBlockType {
    case author
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
        case .author:
            return (
                NSLocalizedString("CourseInfoTitleAuthor", comment: ""),
                "course-info-instructor"
            )
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

protocol CourseInfoBlockViewModelProtocol {
    var type: CourseInfoBlockType { get }

    var image: UIImage? { get }
    var title: String { get }
}

extension CourseInfoBlockViewModelProtocol {
    var image: UIImage? {
        return self.type.image
    }

    var title: String {
        return self.type.title
    }
}

struct CourseInfoTextBlockViewModel: CourseInfoBlockViewModelProtocol {
    let type: CourseInfoBlockType
    let message: String
}

struct CourseInfoInstructorViewModel {
    let avatar: UIImage?
    let title: String
    let description: String
}

struct CourseInfoInstructorsBlockViewModel: CourseInfoBlockViewModelProtocol {
    var type: CourseInfoBlockType {
        return .instructors
    }

    let instructors: [CourseInfoInstructorViewModel]
}

struct CourseInfoViewModel {
    let blocks: [CourseInfoBlockViewModelProtocol]
}
