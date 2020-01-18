import UIKit

protocol CourseInfoTabInfoPresenterProtocol {
    func presentCourseInfo(response: CourseInfoTabInfo.InfoLoad.Response)
}

final class CourseInfoTabInfoPresenter: CourseInfoTabInfoPresenterProtocol {
    weak var viewController: CourseInfoTabInfoViewControllerProtocol?

    private let splitTestingService = SplitTestingService(
        analyticsService: AnalyticsUserProperties(),
        storage: UserDefaults.standard
    )

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

    private func makeViewModel(course: Course, streamVideoQuality: StreamVideoQuality) -> CourseInfoTabInfoViewModel {
        let instructorsViewModel = course.instructors.map { user in
            CourseInfoTabInfoInstructorViewModel(
                id: user.id,
                avatarImageURL: URL(string: user.avatarURL),
                title: "\(user.firstName) \(user.lastName)",
                description: user.bio
            )
        }

        let certificateText = self.makeFormattedCertificateText(course: course)
        let certificateDetailsText = course.hasCertificate
            ? self.makeFormattedCertificateDetailsText(
                conditionPoints: course.certificateRegularThreshold,
                distinctionPoints: course.certificateDistinctionThreshold
            )
            : nil

        let aboutText: String = {
            var text = course.summary
            if AboutCourseStringSplitTest.shouldParticipate {
                let splitTest = self.splitTestingService.fetchSplitTest(AboutCourseStringSplitTest.self)
                if case .test = splitTest.currentGroup {
                    text = course.courseDescription
                }
            }
            return text.trimmingCharacters(in: .whitespaces)
        }()

        return CourseInfoTabInfoViewModel(
            author: self.makeFormattedAuthorText(authors: course.authors),
            introVideoURL: self.makeIntroVideoURL(course: course, streamVideoQuality: streamVideoQuality),
            introVideoThumbnailURL: URL(string: course.introVideo?.thumbnailURL ?? ""),
            aboutText: aboutText,
            requirementsText: course.requirements.trimmingCharacters(in: .whitespaces),
            targetAudienceText: course.audience.trimmingCharacters(in: .whitespaces),
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

    private func makeFormattedAuthorText(authors: [User]) -> String {
        if authors.isEmpty {
            return ""
        } else {
            var authorString = authors.reduce(into: "") { result, user in
                result += "\(user.firstName) \(user.lastName), "
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
        Locale.current.localizedString(forLanguageCode: code)?.capitalized ?? ""
    }

    private func makeFormattedCertificateText(course: Course) -> String {
        let predefinedText = course.hasCertificate
            ? NSLocalizedString("CertificateIsIssued", comment: "")
            : NSLocalizedString("CertificateIsNotIssued", comment: "")
        let certificateText = course.certificate.trimmingCharacters(in: .whitespaces)

        return course.hasCertificate && !certificateText.isEmpty
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
