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
}

class AdaptiveStepsPresenter {
    let recommendationsBatchSize = 10
    let nextRecommendationsBatch = 5
    
    weak var view: AdaptiveStepsView?
    var currentStepPresenter: AdaptiveStepPresenter?
    
    // TODO: optimize DI
    private var coursesAPI: CoursesAPI?
    private var stepsAPI: StepsAPI?
    private var lessonsAPI: LessonsAPI?
    private var progressesAPI: ProgressesAPI?
    private var stepicsAPI: StepicsAPI?
    private var recommendationsAPI: RecommendationsAPI?
    
    var isKolodaPresented = false
    var isJoinedCourse = false
    var isRecommendationLoaded = false
    var isCurrentCardDone = false
    var isOnboardingPassed = false
    
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
    var currentLesson: Lesson?
    var recommendedLessons: [Lesson] = []
    var step: Step?
    
    lazy var aboutCourseController: UIViewController = {
        let vc = ControllerHelper.instantiateViewController(identifier: "AdaptiveCourseInfo", storyboardName: "AdaptiveMain") as! AdaptiveCourseViewController
        vc.course = self.course
        return vc
    }()
    
    init(coursesAPI: CoursesAPI, stepsAPI: StepsAPI, lessonsAPI: LessonsAPI, progressesAPI: ProgressesAPI, stepicsAPI: StepicsAPI, recommendationsAPI: RecommendationsAPI, view: AdaptiveStepsView) {
        self.coursesAPI = coursesAPI
        self.stepsAPI = stepsAPI
        self.lessonsAPI = lessonsAPI
        self.progressesAPI = progressesAPI
        self.stepicsAPI = stepicsAPI
        self.recommendationsAPI = recommendationsAPI
        self.view = view
    }
    
    func refreshContent() {
        if !isKolodaPresented {
            // Show cards (empty or not)
            view?.initCards()
            isKolodaPresented = true
            
            // Check authorization
            if !AuthInfo.shared.isAuthorized {
                print("user not authorized -> register new user")
                
                registerAdaptiveUser { email, password in
                    self.logIn(with: email, password: password) {
                        self.joinAndLoadCourse {
                            // Reload cards (we can get recommendations now)
                            self.view?.initCards()
                        }
                    }
                }
            } else {
                print("user authorized -> load course")
                self.joinAndLoadCourse(completion: {
                    self.view?.initCards()
                })
            }
            
            // Launch onboarding
            launchOnboarding()
        }
    }
    
    fileprivate func getStep(for recommendedLesson: Lesson, success: @escaping (Step) -> (Void)) {
        if let stepId = recommendedLesson.stepsArray.first {
            // Get steps in recommended lesson
            stepsAPI?.retrieve(ids: [stepId], existing: [], refreshMode: .update, success: { (newStepsImmutable) -> Void in
                let step = newStepsImmutable.first
                if let step = step {
                    self.isRecommendationLoaded = true
                    success(step)
                }
            }, error: { (error) -> Void in
                print("failed downloading steps data in Next")
                self.view?.state = .connectionError
            })
        }
    }
    
    fileprivate func loadRecommendations(for course: Course, count: Int, success: @escaping ([Lesson]) -> (Void)) {
        performRequest({
            self.recommendationsAPI?.getRecommendedLessonsId(course: course.id, count: count, success: { recommendations in
                if recommendations.isEmpty {
                    success([])
                    return
                }
                
                self.lessonsAPI?.retrieve(ids: recommendations, existing: [], refreshMode: .update, success: { (newLessonsImmutable) -> Void in
                    success(newLessonsImmutable)
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
    
    fileprivate func getNewRecommendation(for course: Course, success: @escaping (Step) -> (Void)) {
        isRecommendationLoaded = false
        
        if recommendedLessons.count == 0 {
            print("recommendations not loaded yet -> loading \(recommendationsBatchSize) lessons...")
            // Recommendations not loaded yet
            loadRecommendations(for: course, count: recommendationsBatchSize, success: { recommendedLessons in
                self.recommendedLessons = recommendedLessons
                print("loaded batch with \(recommendedLessons.count) lessons")
                
                // Got empty array as recommendation -> course passed
                if recommendedLessons.isEmpty {
                    self.view?.state = .coursePassed
                    return
                }
                
                let lessonsIds = self.recommendedLessons.map { $0.id }
                self.lessonsAPI?.retrieve(ids: lessonsIds, existing: [], refreshMode: .update, success: { (newLessonsImmutable) -> Void in
                    self.recommendedLessons = newLessonsImmutable
                    
                    let lesson = self.recommendedLessons.first
                    self.recommendedLessons.remove(at: 0)
                    
                    if let lesson = lesson {
                        self.currentLesson = lesson
                        self.getStep(for: lesson, success: { step in
                            success(step)
                        })
                    }
                    
                }, error: { (error) -> Void in
                    print("failed downloading lessons data in Next")
                    self.view?.state = .connectionError
                })
            })
        } else {
            print("recommendations loaded (count = (\(self.recommendedLessons.count)), using loaded lesson...")
            let lesson = self.recommendedLessons.first
            self.recommendedLessons.remove(at: 0)
            
            if let lesson = lesson {
                self.currentLesson = lesson
                self.getStep(for: lesson, success: { step in
                    success(step)
                    
                    // Load next batch
                    if self.recommendedLessons.count <= self.nextRecommendationsBatch {
                        print("recommendations loaded, loading next \(self.recommendationsBatchSize) lessons...")
                        self.loadRecommendations(for: course, count: self.recommendationsBatchSize, success: { recommendedLessons in
                            let existingLessons = self.recommendedLessons.map { $0.id }
                            recommendedLessons.forEach { lesson in
                                if !existingLessons.contains(lesson.id) {
                                    self.recommendedLessons.append(lesson)
                                }
                            }
                        })
                    }
                    
                })
            }
        }
    }
    
    fileprivate func sendReaction(reaction: Reaction, success: @escaping () -> (Void)) {
        guard let userId = AuthInfo.shared.userId,
            let lessonId = currentLesson?.id else {
                return
        }
        
        performRequest({
            self.recommendationsAPI?.sendRecommendationReaction(user: userId, lesson: lessonId, reaction: reaction, success: {
                success()
            }, error: { error in
                print("failed sending reaction: \(error)")
                self.view?.state = .connectionError
            })
        }, error: { error in
            print("failed performing API request -> force logout")
            self.logout()
        })
    }
    
    fileprivate func registerAdaptiveUser(success: @escaping ((String, String) -> Void)) {
        let firstname = StringHelper.generateRandomString(of: 6)
        let lastname = StringHelper.generateRandomString(of: 6)
        let email = "adaptive_\(StepicApplicationsInfo.adaptiveCourseId)_ios_\(Int(Date().timeIntervalSince1970))\(StringHelper.generateRandomString(of: 5))@stepik.org"
        let password = StringHelper.generateRandomString(of: 16)
        
        performRequest({
            AuthManager.sharedManager.signUpWith(firstname, lastname: lastname, email: email, password: password, success: {
                print("new user registered: \(email):\(password)")
                success(email, password)
            }, error: { error, registrationErrorInfo in
                print("user registration failed")
                self.view?.state = .connectionError
            })
        }, error: { error in
            print("user registration failed: \(error)")
            self.view?.state = .connectionError
        })
    }
    
    fileprivate func logIn(with email: String, password: String, success: @escaping ((Void) -> Void)) {
        performRequest({
            AuthManager.sharedManager.logInWithUsername(email, password: password, success: { token in
                AuthInfo.shared.token = token
                
                self.stepicsAPI?.retrieveCurrentUser(success: { user in
                    AuthInfo.shared.user = user
                    User.removeAllExcept(user)
                    
                    success()
                }, error: { error in
                    print("successfully signed in, but could not get user")
                    self.view?.state = .connectionError
                })
            }, failure: { error in
                print("successfully registered, but login failed: \(error)")
                self.view?.state = .connectionError
            })
        }, error: { error in
            print("user log in failed: \(error)")
            self.view?.state = .connectionError
        })
    }
    
    fileprivate func launchOnboarding() {
        let isOnboardingNeeded = !UserDefaults.standard.bool(forKey: "isOnboardingShown")
        
        if !isOnboardingPassed && isOnboardingNeeded {
            let vc = ControllerHelper.instantiateViewController(identifier: "AdaptiveOnboardingViewController", storyboardName: "AdaptiveMain") as! AdaptiveOnboardingViewController
            vc.presenter = AdaptiveOnboardingPresenter(view: vc)
            
            (view as? UIViewController)?.present(vc, animated: false, completion: {
                self.isOnboardingPassed = true
            })
            UserDefaults.standard.set(true, forKey: "isOnboardingShown")
        } else {
            isOnboardingPassed = true
        }
    }
    
    fileprivate func joinAndLoadCourse(completion: @escaping () -> ()) {
        performRequest({
            self.coursesAPI?.retrieve(ids: [StepicApplicationsInfo.adaptiveCourseId], existing: [], refreshMode: .update, success: { (coursesImmutable) -> Void in
                self.course = coursesImmutable.first
                
                guard let course = self.course else {
                    print("course not found")
                    return
                }
                
                if !course.enrolled {
                    self.isJoinedCourse = true
                    
                    _ = AuthManager.sharedManager.joinCourseWithId(course.id, success: {
                        self.course?.enrolled = true
                        print("success joined course -> loading cards")
                        
                        completion()
                    }, error: {error in
                        print("failed joining course: \(error) -> show placeholder")
                        self.view?.state = .connectionError
                    })
                } else {
                    print("already joined target course -> loading cards")
                    
                    self.isJoinedCourse = true
                    completion()
                }
            }, error: { (error) -> Void in
                print("failed downloading course data -> show placeholder")
                self.view?.state = .connectionError
            })
        }, error: { error in
            print("failed performing API request -> force logout")
            self.logout()
        })
    }
    
    // TODO: new user after logout?
    func logout() {
        AuthInfo.shared.token = nil
        AuthInfo.shared.user = nil
        
        view?.state = .normal
        
        recommendedLessons = []
        
        refreshContent()
    }
    
    func updateCard(_ card: StepCardView) -> StepCardView {
        card.delegate = self
        card.cardState = .loading
        
        DispatchQueue.global().async { [weak self] in
            guard let course = self?.course else {
                return
            }
            
            let successHandler: (Step) -> (Void) = { step in
                self?.step = step
                DispatchQueue.main.async {
                    let currentStepViewController = ControllerHelper.instantiateViewController(identifier: "AdaptiveStepViewController", storyboardName: "AdaptiveMain") as? AdaptiveStepViewController
                    guard let stepViewController = currentStepViewController,
                        let step = self?.step else {
                            print("stepVC init failed")
                            return
                    }

                    let adaptiveStepPresenter = AdaptiveStepPresenter(view: stepViewController, step: step)
                    adaptiveStepPresenter.delegate = self
                    stepViewController.presenter = adaptiveStepPresenter
                    self?.currentStepPresenter = adaptiveStepPresenter
                    
                    (self?.view as? UIViewController)?.addChildViewController(stepViewController)
                    card.addContentSubview(stepViewController.view)
                    card.updateLabel(self?.currentLesson?.title ?? "")
                }
            }
            
            // If onboarding not passed yet, just show card, but skip data loading
            if self?.isOnboardingPassed ?? false {
                if self?.lastReaction == nil {
                    // First recommendation -> just get it
                    print("getting first recommendation...")
                    self?.getNewRecommendation(for: course, success: successHandler)
                } else {
                    // Next recommendation -> send reaction before
                    print("last reaction: \((self?.lastReaction)!), getting new recommendation...")
                    self?.sendReaction(reaction: (self?.lastReaction)!, success: { [weak self] in
                        self?.getNewRecommendation(for: course, success: successHandler)
                    })
                }
            }
        }
            
        return card
    }
    
    func goToAppStore() {
        if let link = Bundle.main.infoDictionary?["AppStoreMoreLink"] as? String,
           let url = URL(string: link),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    func tryAgain() {
        isKolodaPresented = false
        lastReaction = nil
        view?.state = .normal
        
        // 1. User not authorized -> register and log in
        // 2. Course is nil -> invalid state, refresh
        // 3. Course is initialized, but user is not joined -> load and join it again
        if course == nil || !isJoinedCourse {
            refreshContent()
            return
        }
        
        // 4. Course is initialized, user is joined, just temporary troubles -> only reload koloda
        print("connection troubles -> trying again")
        view?.initCards()
    }
}


extension AdaptiveStepsPresenter: StepCardViewDelegate {
    func onControlButtonClick() {
        switch currentStepPresenter?.state ?? .unsolved {
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

extension AdaptiveStepsPresenter: AdaptiveStepDelegate {
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
