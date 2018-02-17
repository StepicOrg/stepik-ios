//
//  ApiDataDownloader.swift
//  Stepic
//
//  Created by Alexander Karpov on 15.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class ApiDataDownloader {
    static let devices = DevicesAPI()
    static let discussionProxies = DiscussionProxiesAPI()
    static let comments = CommentsAPI()
    static let votes = VotesAPI()
    static let stepics = StepicsAPI()
    static let units = UnitsAPI()
    static let userActivities = UserActivitiesAPI()
    static let recommendations = RecommendationsAPI()
    static let lastSteps = LastStepsAPI()
    static let courses = CoursesAPI()
    static let sections = SectionsAPI()
    static let lessons = LessonsAPI()
    static let users = UsersAPI()
    static let submissions = SubmissionsAPI()
    static let search = SearchResultsAPI()
    static let views = ViewsAPI()
    static let steps = StepsAPI()
    static let assignments = AssignmentsAPI()
    static let certificates = CertificatesAPI()
    static let profiles = ProfilesAPI()
    static let queries = QueriesAPI()
    static let notifications = NotificationsAPI()
    static let courseReviewSummaries = CourseReviewSummariesAPI()
    static let enrollments = EnrollmentsAPI()
    static let attempts = AttemptsAPI()
    static let progresses = ProgressesAPI()
    static let auth = AuthAPI()
    #if !os(tvOS)
        static let notificationsStatusAPI = NotificationStatusesAPI()
    #endif
}

enum RefreshMode {
    case delete, update
}
