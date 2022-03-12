import Foundation

final class StepikURLFactory {
    // MARK: Users

    func makeUser(id: User.IdType) -> URL? {
        self.makeURL(path: .users(id))
    }

    func makeDeleteUserAccount() -> URL? {
        self.makeURL(path: .deleteUserAccount)
    }

    // MARK: Certificate

    func makeCertificate(id: Certificate.IdType) -> URL? {
        self.makeURL(path: .certificate(id))
    }

    // MARK: Course

    func makeCourse(id: Course.IdType) -> URL? {
        self.makeURL(path: .courseID(id))
    }

    func makeCourse(slug: String) -> URL? {
        self.makeURL(path: .courseSlug(slug))
    }

    func makeCourseSyllabus(id: Course.IdType, fromMobile: Bool = true) -> URL? {
        self.makeURL(path: .courseIDSyllabus(id), queryItems: fromMobile ? [.fromMobileApp] : [])
    }

    func makeCourseSyllabus(slug: String, fromMobile: Bool = true) -> URL? {
        self.makeURL(path: .courseSlugSyllabus(slug), queryItems: fromMobile ? [.fromMobileApp] : [])
    }

    func makePayForCourse(id: Course.IdType) -> URL? {
        self.makeURL(path: .coursePay(id))
    }

    // MARK: Catalog

    func makeCatalog() -> URL? {
        self.makeURL(path: .catalog(nil))
    }

    func makeCatalog(id: CourseListModel.IdType) -> URL? {
        self.makeURL(path: .catalog(id))
    }

    // MARK: Lesson

    func makeStep(lessonID: Lesson.IdType, stepPosition position: Int, fromMobile: Bool = true) -> URL? {
        self.makeURL(
            path: .lessonIDStepPosition(lessonID: lessonID, stepPosition: position),
            queryItems: fromMobile ? [.fromMobileApp] : []
        )
    }

    func makeStepSolutionInDiscussions(
        lessonID: Lesson.IdType,
        stepPosition: Int,
        discussionID: Comment.IdType,
        fromMobile: Bool = true
    ) -> URL? {
        let queryItems: [QueryItem] = [.discussion(discussionID), .solutionsThread]
        return self.makeURL(
            path: .lessonIDStepPosition(lessonID: lessonID, stepPosition: stepPosition),
            queryItems: fromMobile ? ([.fromMobileApp] + queryItems) : queryItems
        )
    }

    // MARK: Submissions

    func makeSubmission(stepID: Step.IdType, submissionID: Submission.IdType, unitID: Unit.IdType? = nil) -> URL? {
        self.makeURL(
            path: .submissionsStepIDSubmissionID(stepID: stepID, submissionID: submissionID),
            queryItems: unitID != nil ? [.unit(unitID.require())] : []
        )
    }

    // MARK: Accounts

    func makeResetAccountPassword() -> URL? {
        self.makeURL(path: .resetAccountPassword)
    }

    // MARK: Review

    func makeReviewSession(sessionID: Int, unitID: Unit.IdType? = nil) -> URL? {
        self.makeURL(
            path: .reviewSession(sessionID),
            queryItems: unitID != nil ? [.unit(unitID.require())] : []
        )
    }

    func makeReviewReviews(reviewID: Int, unitID: Unit.IdType? = nil) -> URL? {
        self.makeURL(
            path: .reviewReviews(reviewID),
            queryItems: unitID != nil ? [.unit(unitID.require())] : []
        )
    }

    // MARK: Stepik Academy

    func makeStepikAcademy() -> URL? {
        self.makeURL(path: nil, host: "academy.stepik.org", queryItems: [.fromMobileApp])
    }

    // MARK: - Private API -

    private func makeURL(
        path: Path?,
        host: String = StepikApplicationsInfo.stepikHost,
        queryItems: [QueryItem] = []
    ) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path?.formattedPath ?? ""

        if !queryItems.isEmpty {
            components.queryItems = queryItems.map(\.urlQueryItem)
        }

        return components.url
    }

    private enum QueryItem {
        case fromMobileApp
        case discussion(Comment.IdType)
        case solutionsThread
        case unit(Unit.IdType)

        var urlQueryItem: URLQueryItem {
            switch self {
            case .fromMobileApp:
                return URLQueryItem(name: "from_mobile_app", value: "true")
            case .discussion(let id):
                return URLQueryItem(name: "discussion", value: "\(id)")
            case .solutionsThread:
                return URLQueryItem(name: "thread", value: "solutions")
            case .unit(let id):
                return URLQueryItem(name: "unit", value: "\(id)")
            }
        }
    }

    private enum Path {
        case users(User.IdType)
        case certificate(Certificate.IdType)
        case courseID(Course.IdType)
        case courseSlug(String)
        case courseIDSyllabus(Course.IdType)
        case courseSlugSyllabus(String)
        case coursePay(Course.IdType)
        case lessonIDStepPosition(lessonID: Lesson.IdType, stepPosition: Int)
        case submissionsStepIDSubmissionID(stepID: Step.IdType, submissionID: Submission.IdType)
        case resetAccountPassword
        case deleteUserAccount
        case catalog(CourseListModel.IdType?)
        case reviewSession(Int)
        case reviewReviews(Int)

        var formattedPath: String {
            switch self {
            case .users(let id):
                return "/users/\(id)"
            case .certificate(let id):
                return "/cert/\(id)"
            case .courseID(let id):
                return "/course/\(id)"
            case .courseSlug(let slug):
                return "/course/\(slug)"
            case .courseIDSyllabus(let id):
                return "/course/\(id)/syllabus"
            case .courseSlugSyllabus(let slug):
                return "/course/\(slug)/syllabus"
            case .coursePay(let id):
                return "/course/\(id)/pay"
            case .lessonIDStepPosition(let lessonID, let stepPosition):
                return "/lesson/\(lessonID)/step/\(stepPosition)"
            case .submissionsStepIDSubmissionID(let stepID, let submissionID):
                return "/submissions/\(stepID)/\(submissionID)"
            case .resetAccountPassword:
                return "/accounts/password/reset"
            case .deleteUserAccount:
                return "/users/delete-account/"
            case .catalog(let courseListIDOrNil):
                if let courseListID = courseListIDOrNil {
                    return "/catalog/\(courseListID)"
                }
                return "/catalog"
            case .reviewSession(let sessionID):
                return "/review/sessions/\(sessionID)"
            case .reviewReviews(let reviewID):
                return "/review/reviews/\(reviewID)"
            }
        }
    }
}
