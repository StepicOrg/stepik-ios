//
//  AdaptiveStepsPresenter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 07.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

enum AdaptiveStepsViewState {
    case connectionError
    case coursePassed
    case normal
}

protocol AdaptiveStepsView: class {
    var state: AdaptiveStepsViewState { get set }
    
    func swipeCardUp()
    func swipeCardLeft()
    func swipeCardRight()
    func updateTopCardControl(stepState: AdaptiveStepState)
    func updateTopCard(cardState: StepCardView.CardState)
    func initCards()
    
    func showHud(withStatus: String)
    func hideHud()
}

class AdaptiveStepsPresenter {
    weak var view: AdaptiveStepsView?
    var currentStepPresenter: AdaptiveStepPresenter?
    
    var isKolodaPresented = false
    var isJoinedCourse = false
    var isRecommendationLoaded = false
    var isCurrentCardDone = false
    
    var lastReaction: Reaction? {
        didSet {
            if lastReaction != nil {
                switch lastReaction! {
                case .maybeLater:
                    AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.Reaction.hard)
                    break
                case .neverAgain:
                    AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.Reaction.easy)
                    break
                default:
                    return
                }
            }
        }
    }
    
    var course: Course?
    var lesson: Lesson?
    var step: Step?
    
    lazy var aboutCourseController: UIViewController = {
        let vc = ControllerHelper.instantiateViewController(identifier: "AdaptiveCourseInfo", storyboardName: "AdaptiveMain") as! AdaptiveCourseViewController
        vc.course = self.course
        return vc
    }()
    
    init(view: AdaptiveStepsView) {
        self.view = view
    }
    
    func refreshContent() {
        if !isKolodaPresented {
            isKolodaPresented = true
            if !AuthInfo.shared.isAuthorized {
                presentAuthViewController()
            } else {
                self.joinAndLoadCourse(completion: {
                    self.view?.initCards()
                })
            }
        }
    }
    
    func getNewRecommendation(for course: Course, success: @escaping (Step) -> (Void)) {
        isRecommendationLoaded = false
        
        performRequest({
            // Get recommended lesson
            ApiDataDownloader.recommendations.getRecommendedLessonId(course: course.id, success: { recommendedLessonId in
                // Got nil as recommended lesson -> course passed
                guard let recommendedLessonId = recommendedLessonId else {
                    self.view?.state = .coursePassed
                    return
                }
                
                ApiDataDownloader.lessons.retrieve(ids: [recommendedLessonId], existing: [], refreshMode: .update, success: { (newLessonsImmutable) -> Void in
                    let lesson = newLessonsImmutable.first
                    
                    if let lesson = lesson, let stepId = lesson.stepsArray.first {
                        self.lesson = lesson
                        
                        // Get steps in recommended lesson
                        ApiDataDownloader.steps.retrieve(ids: [stepId], existing: [], refreshMode: .update, success: { (newStepsImmutable) -> Void in
                            let step = newStepsImmutable.first
                            
                            if let step = step {
                                guard let progressId = step.progressId else {
                                    print("invalid progress id")
                                    return
                                }
                                
                                // Get progress: if step is passed -> skip it
                                ApiDataDownloader.progresses.retrieve(ids: [progressId], existing: [], refreshMode: .update, success: { progresses in
                                    let progress = progresses.first
                                    if progress != nil && progress!.isPassed {
                                        print("step already passed -> getting new recommendation")
                                        self.sendReactionAndGetNewLesson(reaction: .solved, success: success)
                                    } else {
                                        self.isRecommendationLoaded = true
                                        success(step)
                                    }
                                }, error: { (error) -> Void in
                                    print("failed getting step progress -> step with unknown progress")
                                    self.isRecommendationLoaded = true
                                    success(step)
                                })
                            }
                        }, error: { (error) -> Void in
                            print("failed downloading steps data in Next")
                            self.view?.state = .connectionError
                        })
                    }
                }, error: { (error) -> Void in
                    print("failed downloading lessons data in Next")
                    self.view?.state = .connectionError
                })
            }, error: { error in
                print(error)
                self.view?.state = .connectionError
            })
        }, error: { error in
            print("failed performing API request -> force logout")
            self.logout()
        })
    }
    
    
    fileprivate func sendReactionAndGetNewLesson(reaction: Reaction, success: @escaping (Step) -> (Void)) {
        guard let course = course,
            let userId = AuthInfo.shared.userId,
            let lessonId = lesson?.id else {
                return
        }
        
        performRequest({
            ApiDataDownloader.recommendations.sendRecommendationReaction(user: userId, lesson: lessonId, reaction: reaction, success: {
                self.getNewRecommendation(for: course, success: { step in
                    success(step)
                })
            }, error: { error in
                print("failed sending reaction: \(error)")
                self.view?.state = .connectionError
            })
        }, error: { error in
            print("failed performing API request -> force logout")
            self.logout()
        })
    }
    
    fileprivate func joinAndLoadCourse(completion: @escaping () -> ()) {
        self.view?.showHud(withStatus: NSLocalizedString("LoadingCourse", comment: ""))
        performRequest({
            ApiDataDownloader.courses.retrieve(ids: [StepicApplicationsInfo.adaptiveCourseId], existing: [], refreshMode: .update, success: { (coursesImmutable) -> Void in
                self.course = coursesImmutable.first
                
                guard let course = self.course else {
                    print("course not found")
                    return
                }
                
                if !course.enrolled {
                    self.isJoinedCourse = true
                    
                    self.view?.showHud(withStatus: NSLocalizedString("JoiningCourse", comment: ""))
                    _ = AuthManager.sharedManager.joinCourseWithId(course.id, success: {
                        self.view?.hideHud()
                        self.course?.enrolled = true
                        print("success joined course -> loading cards")
                        
                        completion()
                    }, error: {error in
                        self.view?.hideHud()
                        print("failed joining course: \(error) -> show placeholder")
                        self.view?.state = .connectionError
                    })
                } else {
                    self.view?.hideHud()
                    print("already joined target course -> loading cards")
                    
                    self.isJoinedCourse = true
                    completion()
                }
            }, error: { (error) -> Void in
                self.view?.hideHud()
                print("failed downloading course data -> show placeholder")
                self.view?.state = .connectionError
            })
        }, error: { error in
            self.view?.hideHud()
            print("failed performing API request -> force logout")
            self.logout()
        })
    }
    
    fileprivate func presentAuthViewController() {
        let vc = ControllerHelper.getAuthController() as! AuthNavigationViewController
        vc.canDismiss = false
        vc.success = { [weak self] in
            self?.joinAndLoadCourse(completion: {
                // Present tutorial after log in
                let isTutorialNeeded = !UserDefaults.standard.bool(forKey: "isTutorialShown")
                
                if isTutorialNeeded {
                    let tutorialVC = ControllerHelper.instantiateViewController(identifier: "AdaptiveTutorial", storyboardName: "AdaptiveMain") as! AdaptiveTutorialViewController
                    (self?.view as? UIViewController)?.present(tutorialVC, animated: true, completion: nil)
                    UserDefaults.standard.set(true, forKey: "isTutorialShown")
                }
                
                self?.view?.initCards()
            })
        }
        (view as? UIViewController)?.present(vc, animated: false, completion: nil)
    }
    
    func logout() {
        AuthInfo.shared.token = nil
        AuthInfo.shared.user = nil
        
        self.presentAuthViewController()
    }
    
    func updateCard(_ card: StepCardView) -> StepCardView {
        card.delegate = self
        card.cardState = .loading
        
        DispatchQueue.global().async { [weak self] in
            guard let course = self?.course else {
                return
            }
            
            let successHandler: (Step) -> (Void) = { step in
                guard let lesson = self?.lesson else {
                    return
                }
                
                self?.step = step
                DispatchQueue.main.async {
                    let currentStepViewController = ControllerHelper.instantiateViewController(identifier: "AdaptiveStepViewController", storyboardName: "AdaptiveMain") as? AdaptiveStepViewController
                    guard let stepViewController = currentStepViewController,
                        let step = self?.step else {
                            print("stepVC init failed")
                            return
                    }

                    let adaptiveStepPresenter = AdaptiveStepPresenter(view: stepViewController, step: step)
                    adaptiveStepPresenter.observer = self
                    stepViewController.presenter = adaptiveStepPresenter
                    self?.currentStepPresenter = adaptiveStepPresenter
                    
                    (self?.view as? UIViewController)?.addChildViewController(stepViewController)
                    card.addContentSubview(stepViewController.view)
                    card.updateLabel(self?.lesson?.title ?? "")
                }
            }
            
            if self?.lastReaction == nil {
                // First recommendation -> just get it
                print("getting first recommendation...")
                self?.getNewRecommendation(for: course, success: successHandler)
            } else {
                // Next recommendation -> send reaction before
                print("last reaction: \((self?.lastReaction)!), getting new recommendation...")
                self?.sendReactionAndGetNewLesson(reaction: (self?.lastReaction)!, success: successHandler)
            }
        }
            
        return card
    }
    
    func goToAppStore() {
        // TODO: move url somewhere (maybe to plist?)
        if let url = URL(string: "itms-apps://itunes.apple.com/ru/developer/stepik/id1236410565"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    func tryAgain() {
        lastReaction = nil
        view?.state = .normal
        
        // Two cases:
        // Course is nil -> invalid state, refresh
        // Course is initialized, but user is not joined -> load and join it again
        if course == nil || !isJoinedCourse {
            print("course or user enrollment has invalid state -> join and load course again")
            self.joinAndLoadCourse(completion: {
                self.view?.initCards()
            })
            return
        }
        
        // Course is initialized, user is joined, just temporary troubles -> only reload koloda
        print("connection troubles -> trying again")
        view?.initCards()
    }
}


extension AdaptiveStepsPresenter: StepCardViewDelegate {
    func onControlButtonClick(for state: AdaptiveStepState) {
        switch state {
        case .unsolved:
            currentStepPresenter?.submit()
            break
        case .wrong:
            currentStepPresenter?.retry()
            break
        case .successful:
            lastReaction = .solved
            view?.swipeCardUp()
            break
        }
    }
}

extension AdaptiveStepsPresenter: AdaptiveStepObserver {
    func stepSubmissionDidCorrect() {
        view?.updateTopCardControl(stepState: .successful)
    }
    
    func stepSubmissionDidWrong() {
        view?.updateTopCardControl(stepState: .wrong)
    }
    
    func stepSubmissionDidRetry() {
        view?.updateTopCardControl(stepState: .unsolved)
    }
    
    func contentLoadingDidFail() {
        view?.state = .connectionError
    }
    
    func contentLoadingDidComplete() {
        view?.updateTopCard(cardState: .normal)
    }
}
