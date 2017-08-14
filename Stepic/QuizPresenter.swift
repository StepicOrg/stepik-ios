//
//  QuizPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class QuizPresenter {
    
    weak var delegate: QuizControllerDelegate?
    
    var view: QuizView?
    var step: Step!
    var submissionsAPI: SubmissionsAPI = ApiDataDownloader.submissions
    var attemptsAPI: AttemptsAPI = ApiDataDownloader.attempts
    var userActivitiesAPI: UserActivitiesAPI = ApiDataDownloader.userActivities
    
    init(view: QuizView, step: Step, delegate: QuizControllerDelegate, submissionsAPI: SubmissionsAPI = ApiDataDownloader.submissions, attemptsAPI: AttemptsAPI = ApiDataDownloader.attempts) {
        self.view = view
        self.step = step
        self.delegate = delegate
        self.submissionsAPI = submissionsAPI
        self.attemptsAPI = attemptsAPI
    }
    
    var submission: Submission?
    var attempt: Attempt?
    
    
    
}

enum QuizState {
    case submit
    //submissionCount set to nil means that count has not been counted yet
    case limitedSubmit(submissionCount: Int?, isEditable: Bool)
    case tryAgain
    case error
    case loading
}

protocol QuizView {
    //Quiz content
    func display(dataset: Dataset)
    func display(reply: Reply)
    func set(state: QuizState)
    func set(correct: Bool)
    func showPeerReviewWarning()
    func display(hint: String?)
    
    //Streaks
    func suggestStreak(controller: UIViewController)
    func showStreaksSettingsNotificationAlert()
    func selectStreakNotificationTime(picker: UIViewController)
    
    //Rate
    func showRateAlert(controller: UIViewController)
}
