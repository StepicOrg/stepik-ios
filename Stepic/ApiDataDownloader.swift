//
//  ApiDataDownloader.swift
//  Stepic
//
//  Created by Alexander Karpov on 15.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import Alamofire
import CoreData
import SwiftyJSON
import UIKit

final class ApiDataDownloader {
    static let assignments = AssignmentsAPI()
    static let attempts = AttemptsAPI()
    static let auth = AuthAPI()
    static let certificates = CertificatesAPI()
    static let comments = CommentsAPI()
    static let courseReviewSummaries = CourseReviewSummariesAPI()
    static let courses = CoursesAPI()
    static let discussionProxies = DiscussionProxiesAPI()
    static let discussionThreads = DiscussionThreadsAPI()
    static let enrollments = EnrollmentsAPI()
    static let lastSteps = LastStepsAPI()
    static let lessons = LessonsAPI()
    static let notifications = NotificationsAPI()
    static let notificationsStatusAPI = NotificationStatusesAPI()
    static let profiles = ProfilesAPI()
    static let progresses = ProgressesAPI()
    static let queries = QueriesAPI()
    static let recommendations = RecommendationsAPI()
    static let search = SearchResultsAPI()
    static let sections = SectionsAPI()
    static let stepics = StepicsAPI()
    static let steps = StepsAPI()
    static let submissions = SubmissionsAPI()
    static let units = UnitsAPI()
    static let userActivities = UserActivitiesAPI()
    static let users = UsersAPI()
    static let views = ViewsAPI()
    static let votes = VotesAPI()
    static let devices = DevicesAPI()
}

enum RefreshMode {
    case delete
    case update
}
