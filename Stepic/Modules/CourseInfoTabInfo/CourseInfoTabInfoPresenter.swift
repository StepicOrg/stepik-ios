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

    func presentWaitingState()
    func dismissWaitingState()
    func presentErrorState(message: String?)
}

extension CourseInfoTabInfoPresenterProtocol {
    func presentErrorState() {
        self.presentErrorState(message: NSLocalizedString("Error", comment: ""))
    }
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

    func presentWaitingState() {
        self.viewController?.showLoadingIndicator()
    }

    func dismissWaitingState() {
        self.viewController?.hideLoadingIndicator()
    }

    func presentErrorState(message: String?) {
        self.viewController?.showErrorIndicator(message: message)
    }

    // MARK: Prepare view data

    private func courseToViewModel(course: Course) -> CourseInfoTabInfoViewModel {
        let authorText = self.formattedAuthor(authors: course.authors)
        let timeToCompleteText = self.formattedTimeToComplete(seconds: course.timeToComplete)
        let languageText = self.localizedLanguage(code: course.languageCode)

        let certificateText = self.formattedCertificate(course: course)
        let certificateDetailsText = self.formattedCertificateDetails(
            conditionPoints: course.certificateRegularThreshold,
            distinctionPoints: course.certificateDistinctionThreshold
        )

        let instructorsViewModel = course.instructors.map { user in
            CourseInfoTabInfoInstructorViewModel(
                avatarImageURL: URL(string: user.avatarURL),
                title: "\(user.firstName) \(user.lastName)",
                description: user.bio
            )
        }

        let actionButtonTitle = course.enrolled
            ? NSLocalizedString("ContinueLearning", comment: "")
            : NSLocalizedString("JoinCourse", comment: "")

        return CourseInfoTabInfoViewModel(
            author: authorText,
            introVideoURL: URL(string: course.introURL),
            aboutText: course.summary.trimmingCharacters(in: .whitespaces),
            requirementsText: course.requirements.trimmingCharacters(in: .whitespaces),
            targetAudienceText: course.audience.trimmingCharacters(in: .whitespaces),
            timeToCompleteText: timeToCompleteText,
            languageText: languageText,
            certificateText: certificateText,
            certificateDetailsText: certificateDetailsText,
            instructors: instructorsViewModel,
            actionButtonTitle: actionButtonTitle
        )
    }

    private func formattedAuthor(authors: [User]) -> String {
        if authors.isEmpty {
            return ""
        } else {
            var authorString = authors.reduce("") { result, user in
                result + "\(user.firstName) \(user.lastName), "
            }.trimmingCharacters(in: .whitespaces)
            authorString.removeLast()

            return authorString
        }
    }

    private func formattedTimeToComplete(seconds: Int?) -> String {
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

    private func localizedLanguage(code: String) -> String {
        return Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? ""
    }

    private func formattedCertificate(course: Course) -> String {
        let certificateText = course.certificate.trimmingCharacters(in: .whitespaces)
        if certificateText.isEmpty {
            return course.certificateRegularThreshold != nil && course.certificateDistinctionThreshold != nil
                ? NSLocalizedString("Yes", comment: "")
                : NSLocalizedString("No", comment: "")
        } else {
            return certificateText
        }
    }

    private func formattedCertificateDetails(
        conditionPoints: Int?,
        distinctionPoints: Int?
    ) -> String {
        let formattedCondition = self.formattedCertificateDetailTitle(
            NSLocalizedString("CertificateCondition", comment: ""),
            points: conditionPoints
        )
        let formattedDistinction = self.formattedCertificateDetailTitle(
            NSLocalizedString("WithDistinction", comment: ""),
            points: distinctionPoints
        )

        return "\(formattedCondition)\n\(formattedDistinction)".trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private func formattedCertificateDetailTitle(_ title: String, points: Int?) -> String {
        if let points = points {
            let pluralizedPointsString = StringHelper.pluralize(
                number: points,
                forms: [
                    NSLocalizedString("points1", comment: ""),
                    NSLocalizedString("points234", comment: ""),
                    NSLocalizedString("points567890", comment: "")
                ]
            )
            return "\(title): \(points) \(pluralizedPointsString)"
        } else {
            return ""
        }
    }
}
