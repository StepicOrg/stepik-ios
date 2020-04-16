import Foundation

struct AmplitudeAnalyticsEvents {
    // MARK: - Launch -

    struct Launch {
        static var firstTime = AnalyticsEvent(name: "Launch first time")

        static func sessionStart(
            notificationType: String? = nil,
            sinceLastSession: TimeInterval
        ) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Session start",
                parameters: [
                    "notification_type": notificationType as Any,
                    "seconds_since_last_session": sinceLastSession
                ]
            )
        }
    }

    // MARK: - Onboarding -

    struct Onboarding {
        static func screenOpened(screen: Int) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Onboarding screen opened",
                parameters: [
                    "screen": screen
                ]
            )
        }

        static func closed(screen: Int) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Onboarding closed",
                parameters: [
                    "screen": screen
                ]
            )
        }

        static let completed = AnalyticsEvent(name: "Onboarding completed")
    }

    // MARK: - SignIn -

    struct SignIn {
        static func loggedIn(source: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Logged in",
                parameters: [
                    "source": source
                ]
            )
        }
    }

    // MARK: - SignUp -

    struct SignUp {
        static func registered(source: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Registered",
                parameters: [
                    "source": source
                ]
            )
        }
    }

    // MARK: - Course -

    struct Course {
        static func joined(source: String, courseID: Int, courseTitle: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Course joined",
                parameters: [
                    "source": source,
                    "course": courseID,
                    "title": courseTitle
                ]
            )
        }

        static func unsubscribed(courseID: Int, courseTitle: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Course unsubscribed",
                parameters: [
                    "course": courseID,
                    "title": courseTitle
                ]
            )
        }

        static func continuePressed(source: String, courseID: Int, courseTitle: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Continue course pressed",
                parameters: [
                    "source": source,
                    "course": courseID,
                    "title": courseTitle
                ]
            )
        }

        static func buyPressed(source: CourseBuyingSource, courseID: Int) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Buy course pressed",
                parameters: [
                    "source": source.rawValue,
                    "course": courseID
                ]
            )
        }

        enum CourseBuyingSource: String {
            case courseWidget = "course_widget"
            case courseScreen = "course_screen"
        }
    }

    // MARK: - Steps -

    struct Steps {
        static func submissionMade(step: Int, type: String, language: String? = nil) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Submission made",
                parameters: [
                    "step": step,
                    "type": type,
                    "language": language as Any
                ]
            )
        }

        static func stepOpened(step: Int, type: String, number: Int? = nil) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Step opened",
                parameters: [
                    "step": step,
                    "type": type,
                    "number": number as Any
                ]
            )
        }

        static func stepEditOpened(stepID: Int, type: String, position: Int) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Step edit opened",
                parameters: [
                    "step": stepID,
                    "type": type,
                    "number": position
                ]
            )
        }

        static func stepEditCompleted(stepID: Int, type: String, position: Int) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Step edit completed",
                parameters: [
                    "step": stepID,
                    "type": type,
                    "number": position
                ]
            )
        }
    }

    // MARK: - Downloads -

    struct Downloads {
        static func started(content: Content) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Download started",
                parameters: [
                    "content": content.rawValue
                ]
            )
        }

        static func cancelled(content: Content) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Download cancelled",
                parameters: [
                    "content": content.rawValue
                ]
            )
        }

        static func deleted(content: Content, source: DeleteDownloadSource) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Download deleted",
                parameters: [
                    "content": content.rawValue,
                    "source": source.rawValue
                ]
            )
        }

        static func deleteDownloadsConfirmationInteracted(content: Content, isConfirmed: Bool) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Delete downloads confirmation interacted",
                parameters: [
                    "content": content.rawValue,
                    "result": isConfirmed ? "yes" : "no"
                ]
            )
        }

        static var downloadsScreenOpened = AnalyticsEvent(name: "Downloads screen opened")

        enum Content: String {
            case course
            case section
            case lesson
            case step
        }

        enum DeleteDownloadSource: String {
            case syllabus
            case downloads
        }
    }

    // MARK: - Search -

    struct Search {
        static var started = AnalyticsEvent(name: "Course search started")

        static func searched(query: String, position: Int, suggestion: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Course searched",
                parameters: [
                    "query": query,
                    "position": position,
                    "suggestion": suggestion
                ]
            )
        }
    }

    // MARK: - Notifications -

    struct Notifications {
        static var screenOpened = AnalyticsEvent(name: "Notifications screen opened")

        static func receivedForeground(notificationType: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Foreground notification received",
                parameters: [
                    "notification_type": notificationType
                ]
            )
        }

        static func receivedInactive(notificationType: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Inactive notification received",
                parameters: [
                    "notification_type": notificationType
                ]
            )
        }

        static func defaultAlertShown(source: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Default notification alert shown",
                parameters: [
                    "source": source
                ]
            )
        }

        static func defaultAlertInteracted(source: String, result: InteractionResult) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Default notification alert interacted",
                parameters: [
                    "source": source,
                    "result": result.rawValue
                ]
            )
        }

        static func customAlertShown(source: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Custom notification alert shown",
                parameters: [
                    "source": source
                ]
            )
        }

        static func customAlertInteracted(source: String, result: InteractionResult) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Custom notification alert interacted",
                parameters: [
                    "source": source,
                    "result": result.rawValue
                ]
            )
        }

        static func preferencesAlertShown(source: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Preferences notification alert shown",
                parameters: [
                    "source": source
                ]
            )
        }

        static func preferencesAlertInteracted(source: String, result: InteractionResult) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Preferences notification alert interacted",
                parameters: [
                    "source": source,
                    "result": result.rawValue
                ]
            )
        }

        static func preferencesPushPermissionChanged(result: InteractionResult) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Preferences push permission changed",
                parameters: [
                    "result": result.rawValue
                ]
            )
        }

        enum InteractionResult: String {
            case yes
            case no
        }
    }

    // MARK: - Home -

    struct Home {
        static var opened = AnalyticsEvent(name: "Home screen opened")
    }

    // MARK: - Catalog -

    struct Catalog {
        static var opened = AnalyticsEvent(name: "Catalog screen opened")

        struct Category {
            static func opened(categoryID: Int, categoryNameEn: String) -> AnalyticsEvent {
                AnalyticsEvent(
                    name: "Category opened ",
                    parameters: [
                        "category_id": categoryID,
                        "category_name_en": categoryNameEn
                    ]
                )
            }
        }
    }

    // MARK: - CourseList -

    struct CourseList {
        static var showAllClicked = AnalyticsEvent(name: "Course list show all clicked")

        static func opened(ID: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Course list opened",
                parameters: [
                    "list_id": ID
                ]
            )
        }
    }

    // MARK: - Profile -

    struct Profile {
        static func opened(state: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Profile screen opened",
                parameters: [
                    "state": state
                ]
            )
        }

        static var editOpened = AnalyticsEvent(name: "Profile edit screen opened")

        static var editSaved = AnalyticsEvent(name: "Profile edit saved")
    }

    // MARK: - Certificates -

    struct Certificates {
        static var opened = AnalyticsEvent(name: "Certificates screen opened")
    }

    // MARK: - Achievements -

    struct Achievements {
        static func opened(isPersonal: Bool) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Achievements screen opened",
                parameters: [
                    "is_personal": isPersonal
                ]
            )
        }

        static func popupOpened(source: String, kind: String, level: Int? = nil) -> AnalyticsEvent {
            popupEvent(name: "Achievement popup opened", source: source, kind: kind, level: level)
        }

        static func popupShared(source: String, kind: String, level: Int? = nil) -> AnalyticsEvent {
            popupEvent(name: "Achievement share pressed", source: source, kind: kind, level: level)
        }

        private static func popupEvent(
            name: String,
            source: String,
            kind: String,
            level: Int? = nil
        ) -> AnalyticsEvent {
            AnalyticsEvent(
                name: name,
                parameters: [
                    "source": source,
                    "achievement_kind": kind,
                    "achievement_level": level as Any
                ]
            )
        }
    }

    // MARK: - Settings -

    struct Settings {
        static var opened = AnalyticsEvent(name: "Settings screen opened")

        static func stepFontSizeSelected(size: String) -> AnalyticsEvent {
            AnalyticsEvent(name: "Font size selected", parameters: ["size": size])
        }
    }

    // MARK: - CoursePreview -

    struct CoursePreview {
        static func opened(courseID: Int, courseTitle: String, isPaid: Bool) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Course preview screen opened",
                parameters: [
                    "course": courseID,
                    "title": courseTitle,
                    "is_paid": isPaid
                ]
            )
        }
    }

    // MARK: - Sections -

    struct Sections {
        static func opened(courseID: Int, courseTitle: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Sections screen opened",
                parameters: [
                    "course": courseID,
                    "title": courseTitle
                ]
            )
        }
    }

    // MARK: - Lessons -

    struct Lessons {
        static func opened(sectionID: Int?) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Lessons screen opened",
                parameters: [
                    "section": sectionID as Any
                ]
            )
        }
    }

    // MARK: - CourseReviews -

    struct CourseReviews {
        static func opened(courseID: Int, courseTitle: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Course reviews screen opened",
                parameters: [
                    "course": courseID,
                    "title": courseTitle
                ]
            )
        }

        static func writePressed(courseID: Int, courseTitle: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Create course review pressed",
                parameters: [
                    "course": courseID,
                    "title": courseTitle
                ]
            )
        }

        static func editPressed(courseID: Int, courseTitle: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Edit course review pressed",
                parameters: [
                    "course": courseID,
                    "title": courseTitle
                ]
            )
        }

        static func created(courseID: Int, rating: Int) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Course review created",
                parameters: [
                    "course": courseID,
                    "rating": rating
                ]
            )
        }

        static func updated(courseID: Int, fromRating: Int, toRating: Int) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Course review updated",
                parameters: [
                    "course": courseID,
                    "from_rating": fromRating,
                    "to_rating": toRating
                ]
            )
        }

        static func deleted(courseID: Int, rating: Int) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Course review deleted",
                parameters: [
                    "course": courseID,
                    "rating": rating
                ]
            )
        }
    }

    // MARK: - Discussions -

    struct Discussions {
        enum DiscussionsSource: String {
            case discussion
            case reply
            case `default`
        }

        static func opened(source: DiscussionsSource) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Discussions screen opened",
                parameters: [
                    "source": source.rawValue
                ]
            )
        }
    }

    // MARK: - Stories -

    struct Stories {
        static func storyOpened(id: Int) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Story opened",
                parameters: [
                    "id": id
                ]
            )
        }

        static func storyPartOpened(id: Int, position: Int) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Story part opened",
                parameters: [
                    "id": id,
                    "position": position
                ]
            )
        }

        static func buttonPressed(id: Int, position: Int) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Story button pressed",
                parameters: [
                    "id": id,
                    "position": position
                ]
            )
        }

        enum StoryCloseType: String {
            case cross, swipe, automatic
        }

        static func storyClosed(id: Int, type: StoryCloseType) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Story closed",
                parameters: [
                    "id": id,
                    "type": type.rawValue
                ]
            )
        }
    }

    // MARK: - PersonalDeadlines -

    struct PersonalDeadlines {
        static func created(weeklyLoadHours: Int) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Personal deadline created",
                parameters: [
                    "hours": weeklyLoadHours
                ]
            )
        }

        static var buttonClicked = AnalyticsEvent(name: "Personal deadline schedule button pressed")
    }

    // MARK: - Video -

    struct Video {
        static var continuedInBackground = AnalyticsEvent(name: "Video played in background")

        static func changedSpeed(source: String, target: String) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Video rate changed",
                parameters: [
                    "source": source,
                    "target": target
                ]
            )
        }
    }

    // MARK: - AdaptiveRating -

    struct AdaptiveRating {
        static func opened(course: Int) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Adaptive rating opened",
                parameters: ["course": course]
            )
        }
    }

    // MARK: - Run Code -

    struct RunCode {
        static func launched(stepID: Step.IdType) -> AnalyticsEvent {
            AnalyticsEvent(
                name: "Run code launched",
                parameters: ["step_id": stepID]
            )
        }
    }

    // MARK: - Continue User Activity -

    struct ContinueUserActivity {
        static func spotlightItemTapped(deepLinkRoute: DeepLinkRoute) -> AnalyticsEvent {
            let type: String = {
                switch deepLinkRoute {
                case .lesson:
                    return "lesson"
                case .notifications:
                    return "notifications"
                case .discussions:
                    return "discussions"
                case .solutions:
                    return "solutions"
                case .profile:
                    return "profile"
                case .syllabus:
                    return "syllabus"
                case .catalog:
                    return "catalog"
                case .home:
                    return "home"
                case .course:
                    return "course"
                case .coursePromo:
                    return "coursePromo"
                }
            }()

            return AnalyticsEvent(
                name: "Spotlight item tapped",
                parameters: ["type": type]
            )
        }
    }
}
