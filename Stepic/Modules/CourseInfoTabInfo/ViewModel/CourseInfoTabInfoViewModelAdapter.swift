//
// CourseInfoTabInfoViewModelAdapter.swift
// stepik-ios
//
// Created by Ivan Magda on 2018-11-30.
// Copyright 2018 Stepik. All rights reserved.
//

import Foundation

extension CourseInfoTabInfoViewModel {
    init(course: Course) {
        let instructorsViewModel = course.instructors.map { user in
            CourseInfoTabInfoInstructorViewModel(
                avatarImageURL: URL(string: user.avatarURL),
                title: "\(user.firstName) \(user.lastName)",
                description: user.bio
            )
        }

        self.introVideoThumbnailURL = URL(string: course.introVideo?.thumbnailURL ?? "")
        self.aboutText = course.courseDescription.trimmingCharacters(in: .whitespaces)
        self.requirementsText = course.requirements.trimmingCharacters(in: .whitespaces)
        self.targetAudienceText = course.audience.trimmingCharacters(in: .whitespaces)
        self.instructors = instructorsViewModel
        self.author = CourseInfoTabInfoViewModel.formattedAuthor(authors: course.authors)
        self.introVideoURL = CourseInfoTabInfoViewModel.getIntroVideoURL(course: course)
        self.languageText = CourseInfoTabInfoViewModel.localizedLanguage(code: course.languageCode)
        self.certificateText = CourseInfoTabInfoViewModel.formattedCertificate(course: course)
        self.timeToCompleteText = CourseInfoTabInfoViewModel.formattedTimeToComplete(
            timeToComplete: course.timeToComplete
        )
        self.certificateDetailsText = CourseInfoTabInfoViewModel.formattedCertificateDetails(
            conditionPoints: course.certificateRegularThreshold,
            distinctionPoints: course.certificateDistinctionThreshold
        )
        self.actionButtonTitle = course.enrolled
            ? NSLocalizedString("ContinueLearning", comment: "")
            : NSLocalizedString("JoinCourse", comment: "")
    }

    private static func getIntroVideoURL(course: Course) -> URL? {
        if let introVideo = course.introVideo, !introVideo.urls.isEmpty {
            // FIXME: VideosInfo dependency
            return introVideo.getUrlForQuality(VideosInfo.watchingVideoQuality)
        } else {
            return URL(string: course.introURL)
        }
    }

    private static func formattedAuthor(authors: [User]) -> String {
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

    private static func formattedTimeToComplete(timeToComplete: Int?) -> String {
        if let timeToComplete = timeToComplete {
            return FormatterHelper.hoursInSeconds(TimeInterval(timeToComplete))
        } else {
            return ""
        }
    }

    private static func localizedLanguage(code: String) -> String {
        return Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? ""
    }

    private static func formattedCertificate(course: Course) -> String {
        let certificateText = course.certificate.trimmingCharacters(in: .whitespaces)
        if certificateText.isEmpty {
            return course.certificateRegularThreshold ?? 0 > 0 && course.certificateDistinctionThreshold ?? 0 > 0
                ? NSLocalizedString("Yes", comment: "")
                : NSLocalizedString("No", comment: "")
        } else {
            return certificateText
        }
    }

    private static func formattedCertificateDetails(
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

    private static func formattedCertificateDetailTitle(
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
