import UIKit

protocol CourseInfoTabInfoPresenterProtocol {
    func presentCourseInfo(response: CourseInfoTabInfo.InfoLoad.Response)
    func presentCourseInfoDidAppear(response: CourseInfoTabInfo.ControllerAppearance.Response)
}

final class CourseInfoTabInfoPresenter: CourseInfoTabInfoPresenterProtocol {
    weak var viewController: CourseInfoTabInfoViewControllerProtocol?

    func presentCourseInfo(response: CourseInfoTabInfo.InfoLoad.Response) {
        var viewModel: CourseInfoTabInfo.InfoLoad.ViewModel

        if let course = response.course {
            viewModel = .init(
                state: .result(
                    data: self.makeViewModel(
                        course: course,
                        streamVideoQuality: response.streamVideoQuality
                    )
                )
            )
        } else {
            viewModel = .init(state: .loading)
        }

        self.viewController?.displayCourseInfo(viewModel: viewModel)
    }

    func presentCourseInfoDidAppear(response: CourseInfoTabInfo.ControllerAppearance.Response) {
        self.viewController?.displayCourseInfoDidAppear(viewModel: .init())
    }

    private func makeViewModel(course: Course, streamVideoQuality: StreamVideoQuality) -> CourseInfoTabInfoViewModel {
        let authorsIDs = Set(course.authorsArray).subtracting(Set(course.instructorsArray))
        let authorsViewModel = course.authors.compactMap { author -> CourseInfoTabInfoAuthorViewModel? in
            guard authorsIDs.contains(author.id) else {
                return nil
            }

            return CourseInfoTabInfoAuthorViewModel(
                id: author.id,
                name: FormatterHelper.username(author),
                avatarImageURL: URL(string: author.avatarURL)
            )
        }

        let acquiredSkills = course.acquiredSkillsArray.map { $0.trimmed() }.filter { !$0.isEmpty }

        let certificateText = self.makeFormattedCertificateText(course: course)
        let certificateDetailsText = course.isWithCertificate
            ? self.makeFormattedCertificateDetailsText(
                conditionPoints: course.certificateRegularThreshold,
                distinctionPoints: course.certificateDistinctionThreshold
            )
            : nil

        let instructorsViewModel = course.instructors.map { user in
            CourseInfoTabInfoInstructorViewModel(
                id: user.id,
                avatarImageURL: URL(string: user.avatarURL),
                title: FormatterHelper.username(user),
                description: user.bio
            )
        }

        return CourseInfoTabInfoViewModel(
            authors: authorsViewModel,
            acquiredSkills: acquiredSkills,
            introVideoURL: self.makeIntroVideoURL(course: course, streamVideoQuality: streamVideoQuality),
            introVideoThumbnailURL: URL(string: course.introVideo?.thumbnailURL ?? ""),
            summaryText: course.summary.trimmed(),
            aboutText: course.courseDescription.trimmed(),
            requirementsText: course.requirements.trimmed(),
            targetAudienceText: course.audience.trimmed(),
            timeToCompleteText: self.makeFormattedTimeToCompleteText(timeToComplete: course.timeToComplete),
            languageText: self.makeLocalizedLanguageText(code: course.languageCode),
            certificateText: certificateText,
            certificateDetailsText: certificateDetailsText,
            instructors: instructorsViewModel
        )
    }

    private func makeIntroVideoURL(course: Course, streamVideoQuality: StreamVideoQuality) -> URL? {
        if let introVideo = course.introVideo, !introVideo.urls.isEmpty {
            return introVideo.getUrlForQuality(streamVideoQuality.uniqueIdentifier)
        } else {
            return URL(string: course.introURL)
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
        Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? ""
    }

    private func makeFormattedCertificateText(course: Course) -> String {
        let predefinedText = course.isWithCertificate
            ? NSLocalizedString("CertificateIsIssued", comment: "")
            : NSLocalizedString("CertificateIsNotIssued", comment: "")
        let certificateText = course.certificate.trimmingCharacters(in: .whitespaces)

        return course.isWithCertificate && !certificateText.isEmpty
            ? certificateText
            : predefinedText
    }

    private func makeFormattedCertificateDetailsText(conditionPoints: Int?, distinctionPoints: Int?) -> String {
        let formattedCondition = self.makeFormattedCertificateDetailTitle(
            NSLocalizedString("CertificateCondition", comment: ""),
            points: conditionPoints
        )
        let formattedDistinction = self.makeFormattedCertificateDetailTitle(
            NSLocalizedString("WithDistinction", comment: ""),
            points: distinctionPoints
        )

        return "\(formattedCondition)\n\(formattedDistinction)".trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func makeFormattedCertificateDetailTitle(_ title: String, points: Int?) -> String {
        if let points = points, points > 0 {
            return "\(title): \(FormatterHelper.pointsCount(points))"
        } else {
            return ""
        }
    }
}
