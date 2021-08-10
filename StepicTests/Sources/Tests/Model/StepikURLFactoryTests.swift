@testable
import Stepic

import Nimble
import Quick

class StepikURLFactorySpec: QuickSpec {
    override func spec() {
        describe("StepikURLFactory") {
            var stepikURLFactory: StepikURLFactory!
            let stepikURL = StepikApplicationsInfo.stepikURL

            beforeEach {
                stepikURLFactory = StepikURLFactory()
            }

            context("users") {
                it("returns correct URL for user with id") {
                    // Given
                    let userID = 101
                    let staticURLString = "\(stepikURL)/users/\(userID)"

                    // When
                    let constructedURL = stepikURLFactory.makeUser(id: userID)!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }

                it("returns correct URL for delete user account") {
                    // Given
                    let staticURLString = "\(stepikURL)/users/delete-account/"

                    // When
                    let constructedURL = stepikURLFactory.makeDeleteUserAccount()!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }
            }

            context("course") {
                it("returns correct URL for course with id") {
                    // Given
                    let courseID = 101
                    let staticURLString = "\(stepikURL)/course/\(courseID)"

                    // When
                    let constructedURL = stepikURLFactory.makeCourse(id: courseID)!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }

                it("returns correct URL for course with slug") {
                    // Given
                    let slug = "IMTestCourse-47846"
                    let staticURLString = "\(stepikURL)/course/\(slug)"

                    // When
                    let constructedURL = stepikURLFactory.makeCourse(slug: slug)!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }

                it("returns correct URL for course syllabus with course id") {
                    // Given
                    let courseID = 101
                    let staticURLString = "\(stepikURL)/course/\(courseID)/syllabus"

                    // When
                    let constructedURL = stepikURLFactory.makeCourseSyllabus(id: courseID, fromMobile: false)!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }

                it("returns correct URL for course syllabus with course id and from_mobile_app query item") {
                    // Given
                    let courseID = 101
                    let staticURLString = "\(stepikURL)/course/\(courseID)/syllabus?from_mobile_app=true"

                    // When
                    let constructedURL = stepikURLFactory.makeCourseSyllabus(id: courseID, fromMobile: true)!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }

                it("returns correct URL for course syllabus with course slug") {
                    // Given
                    let slug = "IMTestCourse-47846"
                    let staticURLString = "\(stepikURL)/course/\(slug)/syllabus"

                    // When
                    let constructedURL = stepikURLFactory.makeCourseSyllabus(slug: slug, fromMobile: false)!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }

                it("returns correct URL for course syllabus with course slug and from_mobile_app query item") {
                    // Given
                    let slug = "IMTestCourse-47846"
                    let staticURLString = "\(stepikURL)/course/\(slug)/syllabus?from_mobile_app=true"

                    // When
                    let constructedURL = stepikURLFactory.makeCourseSyllabus(slug: slug, fromMobile: true)!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }

                it("returns correct URL for course pay with id") {
                    // Given
                    let courseID = 101
                    let staticURLString = "\(stepikURL)/course/\(courseID)/pay"

                    // When
                    let constructedURL = stepikURLFactory.makePayForCourse(id: courseID)!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }
            }

            context("lesson") {
                it("returns correct URL for lesson with step position") {
                    // Given
                    let lessonID = 101
                    let stepPosition = 1
                    let staticURLString = "\(stepikURL)/lesson/\(lessonID)/step/\(stepPosition)"

                    // When
                    let constructedURL = stepikURLFactory.makeStep(
                        lessonID: lessonID,
                        stepPosition: stepPosition,
                        fromMobile: false
                    )!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }

                it("returns correct URL for lesson with step position and from_mobile_app query item") {
                    // Given
                    let lessonID = 101
                    let stepPosition = 1
                    let staticURLString = "\(stepikURL)/lesson/\(lessonID)/step/\(stepPosition)?from_mobile_app=true"

                    // When
                    let constructedURL = stepikURLFactory.makeStep(
                        lessonID: lessonID,
                        stepPosition: stepPosition,
                        fromMobile: true
                    )!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }

                it("returns correct URL for lesson with step position in solutions thread") {
                    // Given
                    let lessonID = 101
                    let stepPosition = 1
                    let discussionID = 1001
                    let staticURLString = "\(stepikURL)"
                        + "/lesson/\(lessonID)"
                        + "/step/\(stepPosition)"
                        + "?discussion=\(discussionID)"
                        + "&thread=solutions"

                    // When
                    let constructedURL = stepikURLFactory.makeStepSolutionInDiscussions(
                        lessonID: lessonID,
                        stepPosition: stepPosition,
                        discussionID: discussionID,
                        fromMobile: false
                    )!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }

                it("returns correct URL for lesson with step position in solutions thread and from_mobile_app") {
                    // Given
                    let lessonID = 101
                    let stepPosition = 1
                    let discussionID = 1001
                    let staticURLString = "\(stepikURL)"
                        + "/lesson/\(lessonID)"
                        + "/step/\(stepPosition)"
                        + "?from_mobile_app=true"
                        + "&discussion=\(discussionID)"
                        + "&thread=solutions"

                    // When
                    let constructedURL = stepikURLFactory.makeStepSolutionInDiscussions(
                        lessonID: lessonID,
                        stepPosition: stepPosition,
                        discussionID: discussionID,
                        fromMobile: true
                    )!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }
            }

            context("submissions") {
                it("returns correct URL for submission with step and submission ids") {
                    // Given
                    let stepID = 101
                    let submissionID = 1
                    let staticURLString = "\(stepikURL)/submissions/\(stepID)/\(submissionID)"

                    // When
                    let constructedURL = stepikURLFactory.makeSubmission(stepID: stepID, submissionID: submissionID)!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }

                it("returns correct URL for submission with step, submission and unit ids") {
                    // Given
                    let stepID = 101
                    let submissionID = 1
                    let unitID = 272615
                    let staticURLString = "\(stepikURL)/submissions/\(stepID)/\(submissionID)?unit=\(unitID)"

                    // When
                    let constructedURL = stepikURLFactory.makeSubmission(
                        stepID: stepID,
                        submissionID: submissionID,
                        unitID: unitID
                    )!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }
            }

            context("accounts password reset") {
                it("returns correct URL") {
                    // Given
                    let staticURLString = "\(stepikURL)/accounts/password/reset"

                    // When
                    let constructedURL = stepikURLFactory.makeResetAccountPassword()!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }
            }

            context("catalog") {
                it("returns correct URL for catalog with course list id") {
                    // Given
                    let courseListID = 11
                    let staticURLString = "\(stepikURL)/catalog/\(courseListID)"

                    // When
                    let constructedURL = stepikURLFactory.makeCatalog(id: courseListID)!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }

                it("returns correct URL for catalog without course list id") {
                    // Given
                    let staticURLString = "\(stepikURL)/catalog"

                    // When
                    let constructedURL = stepikURLFactory.makeCatalog()!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }
            }

            context("review") {
                it("returns correct URL for review session with session id") {
                    // Given
                    let sessionID = 908582
                    let staticURLString = "\(stepikURL)/review/sessions/\(sessionID)"

                    // When
                    let constructedURL = stepikURLFactory.makeReviewSession(sessionID: sessionID)!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }

                it("returns correct URL for review session with session and unit ids") {
                    // Given
                    let sessionID = 908582
                    let unitID = 272615
                    let staticURLString = "\(stepikURL)/review/sessions/\(sessionID)?unit=\(unitID)"

                    // When
                    let constructedURL = stepikURLFactory.makeReviewSession(sessionID: sessionID, unitID: unitID)!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }

                it("returns correct URL for review reviews with review id") {
                    // Given
                    let reviewID = 1936960
                    let staticURLString = "\(stepikURL)/review/reviews/\(reviewID)"

                    // When
                    let constructedURL = stepikURLFactory.makeReviewReviews(reviewID: reviewID)!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }

                it("returns correct URL for review reviews with review and unit ids") {
                    // Given
                    let reviewID = 1936960
                    let unitID = 272615
                    let staticURLString = "\(stepikURL)/review/reviews/\(reviewID)?unit=\(unitID)"

                    // When
                    let constructedURL = stepikURLFactory.makeReviewReviews(reviewID: reviewID, unitID: unitID)!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }
            }

            context("stepik academy") {
                it("returns correct URL for Stepik Academy") {
                    // Given
                    let staticURLString = "https://academy.stepik.org?from_mobile_app=true"

                    // When
                    let constructedURL = stepikURLFactory.makeStepikAcademy()!

                    // Then
                    expect(constructedURL.absoluteString) == staticURLString
                }
            }
        }
    }
}
