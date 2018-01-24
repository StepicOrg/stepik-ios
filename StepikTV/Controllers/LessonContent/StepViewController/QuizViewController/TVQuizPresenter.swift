//
//  QuizViewPresenter.swift
//  StepikTV
//
//  Created by Александр Пономарев on 22.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

/*
class QuizPresenter {

    weak var view: QuizView?

    private var step: Step
    private var submissionsAPI: SubmissionsAPI
    private var attemptsAPI: AttemptsAPI
    private var userActivitiesAPI: UserActivitiesAPI

    private var alwaysCreateNewAttemptOnRefresh: Bool


    init(view: QuizView, step: Step, alwaysCreateNewAttemptOnRefresh: Bool, submissionsAPI: SubmissionsAPI, attemptsAPI: AttemptsAPI, userActivitiesAPI: UserActivitiesAPI) {
        self.view = view
        self.step = step
        self.submissionsAPI = submissionsAPI
        self.attemptsAPI = attemptsAPI
        self.userActivitiesAPI = userActivitiesAPI
        self.alwaysCreateNewAttemptOnRefresh = alwaysCreateNewAttemptOnRefresh
    }

    private var submissionsLeft: Int? {
        didSet {
            self.view?.update(limit: submissionLimit)
        }
    }

    private var submissionLimit: SubmissionLimitation? {
        var limit: SubmissionLimitation?
        if step.hasSubmissionRestrictions {
            limit = SubmissionLimitation(count: submissionsLeft, isEditable: step.canEdit)
        }
        return limit
    }

    func refreshAttempt() {
        let forceCreate = alwaysCreateNewAttemptOnRefresh

        //self.view?.showLoading(visible: true)
        performRequest({
            [weak self] in
            guard let s = self else { return }

            if forceCreate {
                print("force create new attempt")
                s.createNewAttempt(completion: {
                    [weak self] in
                    //self?.view?.showLoading(visible: false)
                    }, error: {
                        [weak self] in
                        //self?.view?.showLoading(visible: false)
                        //self?.view?.showConnectionError()
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
                    _ = s.submissionsAPI.retrieve(stepName: s.step.block.name, attemptId: currentAttempt.id!, success: {
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
            submit(reply: reply, completion: {
                [weak self] in
                self?.view?.showLoading(visible: false)
                }, error: {
                    [weak self]
                    _ in
                    self?.view?.showLoading(visible: false)
                    self?.view?.showConnectionError()
            })
        }
    }

    private func submit(reply: Reply, completion: @escaping (() -> Void), error errorHandler: @escaping ((String) -> Void)) {
        let id = attempt!.id!
        performRequest({
            [weak self] in
            guard let s = self else { return }
            _ = s.submissionsAPI.create(stepName: s.step.block.name, attemptId: id, reply: reply, success: {
                [weak self]
                submission in
                guard let s = self else { return }

                if let codeReply = reply as? CodeReply {
                    AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Submission.created, parameters: ["type": s.step.block.name, "language": codeReply.languageName])
                } else {
                    AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Submission.created, parameters: ["type": s.step.block.name])
                }

                s.submission = submission
                s.checkSubmission(submission.id!, time: 0, completion: completion)
                }, error: {
                    errorText in
                    errorHandler(errorText)
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



} */
