//
//  CourseInfoTabInfoPresenter.swift
//  stepik-ios
//
//  Created by Ivan Magda on 15/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol CourseInfoTabInfoPresenterProtocol {
    func presentCourseInfo(response: CourseInfoTabInfo.ShowInfo.Response)
}

final class CourseInfoTabInfoPresenter: CourseInfoTabInfoPresenterProtocol {
    weak var viewController: CourseInfoTabInfoViewControllerProtocol?

    func presentCourseInfo(response: CourseInfoTabInfo.ShowInfo.Response) {
        var viewModel: CourseInfoTabInfo.ShowInfo.ViewModel

        if let course = response.course {
            viewModel = .init(state: .result(data: self.courseToViewModel(course: course)))
        } else {
            viewModel = .init(state: .loading)
        }

        self.viewController?.displayCourseInfo(viewModel: viewModel)
    }

    // MARK: Prepare view data

    private func courseToViewModel(course: Course) -> CourseInfoTabInfoViewModel {
        // authors: [int]
        // language: String
        // certificate_regular_threshold: int
        // certificate_distinction_threshold: int

        let instructors = course.instructors.map { user in
            CourseInfoTabInfoInstructorViewModel(
                avatarImageURL: URL(string: user.avatarURL),
                title: "\(user.firstName) \(user.lastName)",
                description: user.bio
            )
        }

        return CourseInfoTabInfoViewModel(
            author: "Yandex",
            introVideoURL: URL(string: course.introURL),
            aboutText: course.summary,
            requirementsText: course.requirements,
            targetAudienceText: course.audience,
            timeToCompleteText: self.formattedTimeToComple(seconds: course.timeToComplete),
            languageText: "English",
            certificateText: course.certificate,
            certificateDetailsText: "Certificate condition: 50 points\nWith distinction: 75 points",
            instructors: instructors
        )
    }

    private func formattedTimeToComple(seconds: Int?) -> String {
        if let seconds = seconds {
            let hour = 3600.0
            let hours = Int(ceil(Double(seconds) / hour))

            let pluralizedHoursString = StringHelper.pluralize(
                number: hours,
                forms: [
                    NSLocalizedString("hours1", comment: ""),
                    NSLocalizedString("hours234", comment: ""),
                    NSLocalizedString("hours567890", comment: "")
                ]
            )

            return "\(hours) \(pluralizedHoursString)"
        } else {
            return ""
        }
    }
}
