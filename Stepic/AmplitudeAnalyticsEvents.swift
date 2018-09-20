//
//  AmplitudeAnalyticsEvents.swift
//  Stepic
//
//  Created by Ostrenkiy on 19.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

struct AmplitudeAnalyticsEvents {
    struct Launch {
        static var firstTime = AnalyticsEvent(name: "Launch first time")
        static var sessionStart = AnalyticsEvent(name: "Session start")
    }

    struct Onboarding {
        static func screenOpened(screen: Int) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Onboarding screen opened",
                parameters: [
                    "screen": screen
                ]
            )
        }

        static func closed(screen: Int) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Onboarding closed",
                parameters: [
                    "screen": screen
                ]
            )
        }

        static let completed = AnalyticsEvent(name: "Onboarding completed")
    }

    struct SignIn {
        static func loggedIn(source: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Logged in",
                parameters: [
                    "source": source
                ]
            )
        }
    }

    struct SignUp {
        static func registered(source: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Registered",
                parameters: [
                    "source": source
                ]
            )
        }
    }

    struct Course {
        static func joined(source: String, courseID: Int, courseTitle: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Course joined",
                parameters: [
                    "source": source,
                    "course": courseID,
                    "title": courseTitle
                ]
            )
        }

        static func unsubscribed(courseID: Int, courseTitle: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Course unsubscribed",
                parameters: [
                    "course": courseID,
                    "title": courseTitle
                ]
            )
        }

        static func continuePressed(source: String, courseID: Int, courseTitle: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Continue course pressed",
                parameters: [
                    "source": source,
                    "course": courseID,
                    "title": courseTitle
                ]
            )
        }
    }

    struct Steps {
        static func submissionMade(step: Int, type: String, language: String? = nil) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Submission made",
                parameters: [
                    "step": step,
                    "type": type,
                    "language": language as Any
                ]
            )
        }

        static func stepOpened(step: Int, type: String, number: Int? = nil) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Step opened",
                parameters: [
                    "step": step,
                    "type": type,
                    "number": number as Any
                ]
            )
        }
    }

    struct Downloads {
        static func started(content: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Download started",
                parameters: [
                    "content": content
                ]
            )
        }

        static func cancelled(content: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Download cancelled",
                parameters: [
                    "content": content
                ]
            )
        }

        static func deleted(content: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Download deleted",
                parameters: [
                    "content": content
                ]
            )
        }

        static var downloadsScreenOpened = AnalyticsEvent(name: "Downloads screen opened")
    }

    struct Search {
        static var started = AnalyticsEvent(name: "Course search started")

        static func searched(query: String, position: Int, suggestion: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Course searched",
                parameters: [
                    "query": query,
                    "position": position,
                    "suggestion": suggestion
                ]
            )
        }
    }

    struct Notifications {
        static var screenOpened = AnalyticsEvent(name: "Notifications screen opened")
    }

    struct Home {
        static var opened = AnalyticsEvent(name: "Home screen opened")
    }

    struct Catalog {
        static var opened = AnalyticsEvent(name: "Catalog screen opened")
        struct Category {
            static func opened(categoryID: Int, categoryNameEn: String) -> AnalyticsEvent {
                return AnalyticsEvent(
                    name: "Category opened ",
                    parameters: [
                        "category_id": categoryID,
                        "category_name_en": categoryNameEn
                    ]
                )
            }
        }
    }

    struct CourseList {
        static func opened(ID: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Course list opened",
                parameters: [
                    "list_id": ID
                ]
            )
        }
    }

    struct Profile {
        static func opened(state: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Profile screen opened",
                parameters: [
                    "state": state
                ]
            )
        }
    }

    struct Certificates {
        static var opened = AnalyticsEvent(name: "Certificates screen opened")
    }

    struct Achievements {
        static func opened(isPersonal: Bool) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Achievements screen opened",
                parameters: [
                    "is_personal": isPersonal
                ]
            )
        }
    }

    struct Settings {
        static var opened = AnalyticsEvent(name: "Settings screen opened")
    }

    struct CoursePreview {
        static func opened(courseID: Int, courseTitle: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Course preview screen opened",
                parameters: [
                    "course": courseID,
                    "title": courseTitle
                ]
            )
        }
    }

    struct Sections {
        static func opened(courseID: Int, courseTitle: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Sections screen opened",
                parameters: [
                    "course": courseID,
                    "title": courseTitle
                ]
            )
        }
    }

    struct Lessons {
        static func opened(sectionID: Int?) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Lessons screen opened",
                parameters: [
                    "section": sectionID as Any
                ]
            )
        }
    }

    struct Discussions {
        static var opened: AnalyticsEvent = AnalyticsEvent(name: "Discussions screen opened")
    }

    struct Stories {
        static func storyOpened(id: Int) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Story opened",
                parameters: [
                    "id": id
                ]
            )
        }

        static func storyPartOpened(id: Int, position: Int) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Story part opened",
                parameters: [
                    "id": id,
                    "position": position
                ]
            )
        }

        static func buttonPressed(id: Int, position: Int) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Button pressed",
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
            return AnalyticsEvent(
                name: "Story closed",
                parameters: [
                    "id": id,
                    "type": type.rawValue
                ]
            )
        }
    }
}
