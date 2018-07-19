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
        static func joined(source: String, course: Int, courseName: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Course joined",
                parameters: [
                    "source": source,
                    "course": course,
                    "course_name": courseName
                ]
            )
        }

        static func unsubscribed(course: Int, courseName: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Course unsubscribed",
                parameters: [
                    "course": course,
                    "course_name": courseName
                ]
            )
        }

        static func continuePressed(source: String, course: Int, courseName: String) -> AnalyticsEvent {
            return AnalyticsEvent(
                name: "Continue course pressed",
                parameters: [
                    "source": source,
                    "course": course,
                    "course_name": courseName
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
                    "number": number
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
    }

    struct Search {
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
}
