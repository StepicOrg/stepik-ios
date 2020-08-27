import Foundation

final class StepikURLFactory {
    // MARK: Users

    func makeUser(id: User.IdType) -> URL? {
        self.makeURL(path: .users(id))
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

    func makeSubmission(stepID: Step.IdType, submissionID: Submission.IdType) -> URL? {
        self.makeURL(path: .submissionsStepIDSubmissionID(stepID: stepID, submissionID: submissionID))
    }

    // MARK: Accounts

    func makeResetAccountPassword() -> URL? {
        self.makeURL(path: .resetAccountPassword)
    }

    // MARK: - Private API -

    private func makeURL(path: Path, queryItems: [QueryItem] = []) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = StepikApplicationsInfo.stepikHost
        components.path = path.formattedPath

        if !queryItems.isEmpty {
            components.queryItems = queryItems.map(\.urlQueryItem)
        }

        return components.url
    }

    private enum QueryItem {
        case fromMobileApp
        case discussion(Comment.IdType)
        case solutionsThread

        var urlQueryItem: URLQueryItem {
            switch self {
            case .fromMobileApp:
                return URLQueryItem(name: "from_mobile_app", value: "true")
            case .discussion(let id):
                return URLQueryItem(name: "discussion", value: "\(id)")
            case .solutionsThread:
                return URLQueryItem(name: "thread", value: "solutions")
            }
        }
    }

    private enum Path {
        case users(User.IdType)
        case courseID(Course.IdType)
        case courseSlug(String)
        case courseIDSyllabus(Course.IdType)
        case courseSlugSyllabus(String)
        case coursePay(Course.IdType)
        case lessonIDStepPosition(lessonID: Lesson.IdType, stepPosition: Int)
        case submissionsStepIDSubmissionID(stepID: Step.IdType, submissionID: Submission.IdType)
        case resetAccountPassword

        var formattedPath: String {
            switch self {
            case .users(let id):
                return "/users/\(id)"
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
            }
        }
    }
}
