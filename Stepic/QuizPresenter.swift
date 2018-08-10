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
    weak var dataSource: QuizControllerDataSource?
    weak var view: QuizView?

    var step: Step
    var submissionsAPI: SubmissionsAPI
    var attemptsAPI: AttemptsAPI
    var userActivitiesAPI: UserActivitiesAPI
    var alwaysCreateNewAttemptOnRefresh: Bool

    #if !os(tvOS)
        var streaksNotificationSuggestionManager: NotificationSuggestionManager?
    #endif

    var state: QuizState = .nothing {
        didSet {
            view?.set(state: state)
        }
    }

    var stepUrl: String {
        guard let lesson = step.lesson else {
            return ""
        }
        return "\(StepicApplicationsInfo.stepicURL)/lesson/\(lesson.slug)/step/\(step.position)?from_mobile_app=true"
    }

    init(view: QuizView, step: Step, dataSource: QuizControllerDataSource, alwaysCreateNewAttemptOnRefresh: Bool, submissionsAPI: SubmissionsAPI, attemptsAPI: AttemptsAPI, userActivitiesAPI: UserActivitiesAPI) {
        self.view = view
        self.step = step
        self.dataSource = dataSource
        self.submissionsAPI = submissionsAPI
        self.attemptsAPI = attemptsAPI
        self.userActivitiesAPI = userActivitiesAPI
        self.alwaysCreateNewAttemptOnRefresh = alwaysCreateNewAttemptOnRefresh
    }

    #if !os(tvOS)
    convenience init(view: QuizView, step: Step, dataSource: QuizControllerDataSource, alwaysCreateNewAttemptOnRefresh: Bool, submissionsAPI: SubmissionsAPI, attemptsAPI: AttemptsAPI, userActivitiesAPI: UserActivitiesAPI, streaksNotificationSuggestionManager: NotificationSuggestionManager) {
        self.init(view: view, step: step, dataSource: dataSource, alwaysCreateNewAttemptOnRefresh: alwaysCreateNewAttemptOnRefresh, submissionsAPI: submissionsAPI, attemptsAPI: attemptsAPI, userActivitiesAPI: userActivitiesAPI)
        self.streaksNotificationSuggestionManager = streaksNotificationSuggestionManager
    }
    #endif

    private var submissionLimit: SubmissionLimitation? {
        var limit: SubmissionLimitation?
        if step.hasSubmissionRestrictions {
            limit = SubmissionLimitation(count: submissionsLeft, isEditable: step.canEdit)
        }
        return limit
    }

    var submission: Submission? {
        didSet {
            guard let dataset = attempt?.dataset, let dataSource = dataSource else {
                return
            }

            guard let submission = submission else {
                switch self.state {
                case .attempt:
                    return
                default:
                    self.state = .attempt
                    self.view?.update(limit: submissionLimit)
                    view?.display(dataset: dataset)
                    return
                }
            }

            switch (submission.status ?? "evaluation") {
            case "evaluation":
                break

            case "correct":
                self.state = .submission(showsTryAgain: true)
                self.view?.update(limit: submissionLimit)
                if let reply = submission.reply {
                    view?.display(reply: reply, hint: submission.hint, status: .correct)
                }

                if !step.hasReview {
                    // FIXME: Replace two different notifications with one from NSNotification.Name extension
                    #if os(tvOS)
                    NotificationCenter.default.post(name: .stepUpdated, object: nil, userInfo: ["id": step.position])
                    #else
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: StepDoneNotificationKey), object: nil, userInfo: ["id": step.id])
                    #endif
                    DispatchQueue.main.async {
                        [weak self] in
                        self?.step.progress?.isPassed = true
                        CoreDataHelper.instance.save()
                    }
                } else {
                    view?.showPeerReviewWarning()
                }

                delegate?.submissionDidCorrect()
                break

            case "wrong":
                self.state = .submission(showsTryAgain: dataSource.needsToRefreshAttemptWhenWrong)
                self.view?.update(limit: submissionLimit)
                if let reply = submission.reply {
                    view?.display(reply: reply, hint: submission.hint, status: .wrong)
                }
                delegate?.submissionDidWrong()
                break
            default:
                break
            }
        }
    }

    var attempt: Attempt? {
        didSet {
            guard let attempt = attempt,
                let dataset = attempt.dataset else {
                print("Attempt should never be nil")
                return
            }

            self.state = .attempt
            self.view?.update(limit: submissionLimit)
            view?.display(dataset: dataset)
            if let cachedReply = ReplyCache.shared.getReply(forStepId: step.id, attemptId: attempt.id) {
                view?.display(reply: cachedReply)
            }
            checkSubmissionRestrictions()
        }
    }

    private var submissionsCount: Int? {
        didSet {
            guard let maxSubmissionsCount = step.maxSubmissionsCount, let submissionsCount = submissionsCount else {
                return
            }
            let left = maxSubmissionsCount - submissionsCount
            submissionsLeft = left
        }
    }

    private var submissionsLeft: Int? {
        didSet {
            self.view?.update(limit: submissionLimit)
        }
    }

    func refreshAttempt() {
        let forceCreate = alwaysCreateNewAttemptOnRefresh

        self.view?.showLoading(visible: true)
        performRequest({
            [weak self] in
            guard let s = self else { return }

            if forceCreate {
                print("force create new attempt")
                s.createNewAttempt(completion: {
                    [weak self] in
                    self?.view?.showLoading(visible: false)
                }, error: {
                    [weak self] in
                    self?.view?.showLoading(visible: false)
                    self?.view?.showConnectionError()
                })
                return
            }

            _ = s.attemptsAPI.retrieve(stepName: s.step.block.name, stepId: s.step.id, success: {
                [weak self]
                attempts, _ in
                guard let s = self else { return }
                if attempts.count == 0 || attempts[0].status != "active" {
                    //Create attempt
                    s.createNewAttempt(completion: {
                        [weak self] in
                        self?.view?.showLoading(visible: false)
                    }, error: {
                        [weak self] in
                        self?.view?.showLoading(visible: false)
                        self?.view?.showConnectionError()
                    })
                } else {
                    //Get submission for attempt
                    let currentAttempt = attempts[0]
                    s.attempt = currentAttempt
                    _ = s.submissionsAPI.retrieve(stepName: s.step.block.name, attemptId: currentAttempt.id, success: {
                        [weak self]
                        submissions, _ in
                        guard let s = self else { return }
                        if submissions.count == 0 {
                            s.submission = nil
                            //There are no current submissions for attempt
                        } else {
                            //Displaying the last submission
                            s.submission = submissions[0]
                        }
                        s.view?.showLoading(visible: false)
                    }, error: {
                        _ in
                        s.view?.showLoading(visible: false)
                        print("failed to get submissions")
                        //TODO: Test this
                    })
                }
            }, error: {
                _ in
                s.view?.showLoading(visible: false)
                s.view?.showError(visible: true)
                //TODO: Test this
            })
        }, error: {
            [weak self]
            error in
            if error == PerformRequestError.noAccessToRefreshToken {
                self?.view?.logout {
                    [weak self] in
                    self?.refreshAttempt()
                }
            }
        })
    }

    private func createNewAttempt(completion: (() -> Void)? = nil, error: (() -> Void)? = nil) {
        print("creating attempt for step id -> \(self.step.id) name -> \(self.step.block.name)")
        performRequest({
            [weak self] in
            guard let s = self else { return }
            _ = s.attemptsAPI.create(stepName: s.step.block.name, stepId: s.step.id, success: {
                [weak self]
                attempt in
                guard let s = self else { return }
                s.attempt = attempt
                s.submission = nil
                completion?()
            }, error: {
                errorText in
                print(errorText)
                error?()
                //TODO: Test this
            })
        }, error: {
            [weak self]
            error in
            if error == PerformRequestError.noAccessToRefreshToken {
                self?.view?.logout {
                    [weak self] in
                    self?.refreshAttempt()
                }
            }
        })

    }

    private func checkSubmissionRestrictions() {
        if step.hasSubmissionRestrictions {
            retrieveSubmissionsCount(page: 1, success: {
                [weak self]
                count in
                self?.submissionsCount = count
                }, error: {
                    _ in
                    print("failed to get submissions count")
            })
        }
    }

    private func retrieveSubmissionsCount(page: Int, success: @escaping ((Int) -> Void), error: @escaping ((String) -> Void)) {
        _ = submissionsAPI.retrieve(stepName: step.block.name, stepId: step.id, page: page, success: {
            [weak self]
            submissions, meta in
            guard let s = self else { return }

            let count = submissions.count
            if meta.hasNext {
                s.retrieveSubmissionsCount(page: page + 1, success: {
                    nextPagesCnt in
                    success(count + nextPagesCnt)
                    return
                }, error: {
                    errorMsg in
                    error(errorMsg)
                    return
                })
            } else {
                success(count)
                return
            }
            }, error: {
                errorMsg in
                error(errorMsg)
                return
        })
    }

    private func submit() {
        //To view!!!!!!!!
//        submissionPressedBlock?()
        AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Submission.submit, parameters: self.view?.submissionAnalyticsParams)
        if let reply = self.dataSource?.getReply() {
            self.view?.showLoading(visible: true)
            submit(reply: reply, completion: { [weak self] in
                self?.view?.showLoading(visible: false)
            }, error: { [weak self] error in
                self?.view?.showLoading(visible: false)

                if !(self?.submissionLimit?.canSubmit ?? true) {
                    self?.showNoSubmissionsLeftError()
                } else if error is NetworkError {
                    self?.view?.showConnectionError()
                }
            })
        }
    }

    private func submit(reply: Reply, completion: @escaping (() -> Void), error errorHandler: @escaping ((Error) -> Void)) {
        guard let id = attempt?.id else { return }
        performRequest({
            [weak self] in
            guard let s = self else { return }
            _ = s.submissionsAPI.create(stepName: s.step.block.name, attemptId: id, reply: reply, success: {
                [weak self]
                submission in

                guard let strongSelf = self else {
                    return
                }

                AnalyticsUserProperties.shared.incrementSubmissionsCount()
                strongSelf.submissionsCount = (strongSelf.submissionsCount ?? 0) + 1

                if let codeReply = reply as? CodeReply {
                    AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Submission.created, parameters: ["type": strongSelf.step.block.name, "language": codeReply.languageName])
                    AmplitudeAnalyticsEvents.Steps.submissionMade(step: strongSelf.step.id, type: strongSelf.step.block.name, language: codeReply.languageName).send()
                } else {
                    AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Submission.created, parameters: ["type": strongSelf.step.block.name])
                    AmplitudeAnalyticsEvents.Steps.submissionMade(step: strongSelf.step.id, type: strongSelf.step.block.name).send()
                }

                strongSelf.submission = submission
                strongSelf.checkSubmission(submission.id, time: 0, completion: completion)
            }, error: { error in
                errorHandler(error)
                //TODO: test this
            })
        }, error: {
            [weak self]
            error in
            if error == PerformRequestError.noAccessToRefreshToken {
                self?.view?.logout {
                    [weak self] in
                    self?.refreshAttempt()
                }
            }
        })
    }

    private func retrySubmission() {
        view?.showLoading(visible: true)

        AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Submission.newAttempt, parameters: nil)

        self.delegate?.submissionDidRetry()

        createNewAttempt(completion: {
            [weak self] in
            self?.view?.showLoading(visible: false)
            }, error: {
                [weak self] in
                self?.view?.showLoading(visible: false)
                self?.view?.showConnectionError()
        })
    }

    //Measured in seconds
    private let checkTimeStandardInterval = 0.5

    private func checkCorrect() {
        var positionPercentageString: String? {
            if let cnt = step.lesson?.stepsArray.count {
                let res = String(format: "%.02f", cnt != 0 ? Double(step.position) / Double(cnt) : -1)
                print(res)
                return res
            }
            return nil
        }

        #if !os(tvOS)
            if RoutingManager.rate.submittedCorrect() {
                self.view?.showRateAlert()
                return
            }

            guard let streaksManager = streaksNotificationSuggestionManager, streaksManager.canShowAlert(context: .streak, after: .submission) else {
                return
            }
	#endif

        guard let user = AuthInfo.shared.user else {
            return
        }

        _ = userActivitiesAPI.retrieve(user: user.id, success: {
            [weak self]
            activity in
            guard activity.currentStreak > 0 else {
                return
            }

            #if !os(tvOS)
                self?.streaksNotificationSuggestionManager?.didShowAlert(context: .streak)
            #endif
            self?.view?.suggestStreak(streak: activity.currentStreak)
        }, error: {
            _ in
        })
    }

    private func checkSubmission(_ id: Int, time: Int, completion: (() -> Void)? = nil) {
        delay(checkTimeStandardInterval * Double(time), closure: {
            [weak self] in
            guard self != nil else { return }
            performRequest({
                [weak self] in
                guard let s = self else { return }
                _ = s.submissionsAPI.retrieve(stepName: s.step.block.name, submissionId: id, success: {
                    submission in
                    print("did get submission id \(id), with status \(String(describing: submission.status))")
                    if submission.status == "evaluation" {
                        s.checkSubmission(id, time: time + 1, completion: completion)
                    } else {
                        s.submission = submission
                        if submission.status == "correct" {
                            s.checkCorrect()
                        }
                        completion?()
                    }
                }, error: {
                    _ in
                    s.submission = nil
                    completion?()
                    //TODO: test this
                })
            }, error: {
                [weak self]
                error in
                if error == PerformRequestError.noAccessToRefreshToken {
                    self?.view?.logout {
                        [weak self] in
                        self?.refreshAttempt()
                    }
                }
            })
        })
    }

    func submitPressed() {
        switch state {
        case .attempt :
            if submissionLimit?.canSubmit ?? true {
                submit()
            } else {
                showNoSubmissionsLeftError()
            }
        case let .submission(showsTryAgain):
            if submissionLimit?.canSubmit ?? true {
                if showsTryAgain {
                    self.view?.showLoading(visible: true)
                    retrySubmission()
                } else {
                    submit()
                }
            }
        case .nothing:
            break
        }
    }

    func peerReviewPressed() {
        view?.showPeerReview(urlString: stepUrl)
    }

    func onDisappear() {
        switch state {
        case .attempt:
            if let attemptId = attempt?.id {
                ReplyCache.shared.set(reply: dataSource?.getReply(), forStepId: step.id, attemptId: attemptId)
            }
        default:
            break
        }
    }

    private func showNoSubmissionsLeftError() {
        view?.showError(message: NSLocalizedString("NoSubmissionsLeft", comment: ""))
        view?.update(limit: submissionLimit)
    }
}

struct SubmissionLimitation {
    var count: Int?
    var isEditable: Bool

    init(count: Int?, isEditable: Bool) {
        self.count = count
        self.isEditable = isEditable
    }

    var canSubmit: Bool {
        return (count ?? 0) > 0 || isEditable
    }
}

enum QuizState {
    case attempt
    case submission(showsTryAgain: Bool)
    case nothing
}

enum SubmissionStatus: String {
    case correct = "correct"
    case wrong = "wrong"
    case evaluation = "evaluation"
}

protocol QuizView: class {
    //Quiz content
    func display(dataset: Dataset)
    func display(reply: Reply, hint: String?, status: SubmissionStatus)
    func display(reply: Reply)
    func set(state: QuizState)
    func update(limit: SubmissionLimitation?)
    func showError(visible: Bool)
    func showError(message: String)
    func showLoading(visible: Bool)
    func showConnectionError()

    //Peer review
    func showPeerReviewWarning()
    func showPeerReview(urlString: String)

    //Streaks
    func suggestStreak(streak: Int)

    //Rate
    func showRateAlert()

    //Navigation
    func logout(onClose: (() -> Void)?)

    var submissionAnalyticsParams: [String: Any]? { get }
}
