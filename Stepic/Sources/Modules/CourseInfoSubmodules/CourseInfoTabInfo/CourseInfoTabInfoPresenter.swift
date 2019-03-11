//
//  CourseInfoTabInfoPresenter.swift
//  stepik-ios
//
//  Created by Ivan Magda on 15/11/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol CourseInfoTabInfoPresenterProtocol {
    func presentCourseInfo(response: CourseInfoTabInfo.InfoLoad.Response)
}

final class CourseInfoTabInfoPresenter: CourseInfoTabInfoPresenterProtocol {
    weak var viewController: CourseInfoTabInfoViewControllerProtocol?

    func presentCourseInfo(response: CourseInfoTabInfo.InfoLoad.Response) {
        var viewModel: CourseInfoTabInfo.InfoLoad.ViewModel

        if let course = response.course {
            viewModel = .init(state: .result(data: self.makeViewModel(course: course)))
        } else {
            viewModel = .init(state: .loading)
        }

        self.viewController?.displayCourseInfo(viewModel: viewModel)
    }

    private func makeViewModel(course: Course) -> CourseInfoTabInfoViewModel {
        let instructorsViewModel = course.instructors.map { user in
            CourseInfoTabInfoInstructorViewModel(
                avatarImageURL: URL(string: user.avatarURL),
                title: "\(user.firstName) \(user.lastName)",
                description: user.bio
            )
        }
        let certificateDetailsText = self.makeFormattedCertificateDetailsText(
            conditionPoints: course.certificateRegularThreshold,
            distinctionPoints: course.certificateDistinctionThreshold
        )

        return CourseInfoTabInfoViewModel(
            author: self.makeFormattedAuthorText(authors: course.authors),
            introVideoURL: self.makeIntroVideoURL(course: course),
            introVideoThumbnailURL: URL(string: course.introVideo?.thumbnailURL ?? ""),
            aboutText: course.summary.trimmingCharacters(in: .whitespaces),
            requirementsText: course.requirements.trimmingCharacters(in: .whitespaces),
            targetAudienceText: course.audience.trimmingCharacters(in: .whitespaces),
            timeToCompleteText: self.makeFormattedTimeToCompleteText(timeToComplete: course.timeToComplete),
            languageText: self.makeLocalizedLanguageText(code: course.languageCode),
            certificateText: self.makeFormattedCertificateText(course: course),
            certificateDetailsText: certificateDetailsText,
            instructors: instructorsViewModel
        )
    }

    private func makeIntroVideoURL(course: Course) -> URL? {
        if let introVideo = course.introVideo, !introVideo.urls.isEmpty {
            // FIXME: VideosInfo dependency
            return introVideo.getUrlForQuality(VideosInfo.watchingVideoQuality)
        } else {
            return URL(string: course.introURL)
        }
    }

    private func makeFormattedAuthorText(authors: [User]) -> String {
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

    private func makeFormattedTimeToCompleteText(timeToComplete: Int?) -> String {
        if let timeToComplete = timeToComplete {
            return FormatterHelper.hoursInSeconds(TimeInterval(timeToComplete))
        } else {
            return ""
        }
    }

    private func makeLocalizedLanguageText(code: String) -> String {
        return Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? ""
    }

    private func makeFormattedCertificateText(course: Course) -> String {
        let certificateText = course.certificate.trimmingCharacters(in: .whitespaces)
        if certificateText.isEmpty {
            return course.certificateRegularThreshold ?? 0 > 0 && course.certificateDistinctionThreshold ?? 0 > 0
                ? NSLocalizedString("Yes", comment: "")
                : NSLocalizedString("No", comment: "")
        } else {
            return certificateText
        }
    }

    private func makeFormattedCertificateDetailsText(
        conditionPoints: Int?,
        distinctionPoints: Int?
    ) -> String {
        let formattedCondition = self.makeFormattedCertificateDetailTitle(
            NSLocalizedString("CertificateCondition", comment: ""),
            points: conditionPoints
        )
        let formattedDistinction = self.makeFormattedCertificateDetailTitle(
            NSLocalizedString("WithDistinction", comment: ""),
            points: distinctionPoints
        )

        return "\(formattedCondition)\n\(formattedDistinction)".trimmingCharacters(
            in: .whitespacesAndNewlines
        )
    }

    private func makeFormattedCertificateDetailTitle(
        _ title: String,
        points: Int?
    ) -> String {
        if let points = points, points > 0 {
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
