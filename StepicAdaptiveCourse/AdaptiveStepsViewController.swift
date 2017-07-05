//
//  AdaptiveStepsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Koloda
import SVProgressHUD

class AdaptiveStepsViewController: UIViewController {
    
    @IBOutlet weak var userMenuButton: UIBarButtonItem!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var navigationBar: UINavigationBar!

    fileprivate var isJoinedCourse = false
    fileprivate var isRecommendationLoaded = false
    fileprivate var isKolodaPresented = false
    fileprivate var isCurrentCardDone = false
    fileprivate var lastReaction: Reaction?
    
    var placeholderState: PlaceholderState? = nil {
        didSet {
            self.placeholderView.isHidden = placeholderState == nil
            self.kolodaView.isHidden = placeholderState != nil
        }
    }
    
    var course: Course!
    var recommendedLesson: Lesson?
    var step: Step?

    lazy var placeholderView: UIView = {
        let v = PlaceholderView()
        self.view.insertSubview(v, aboveSubview: self.view)
        v.align(to: self.kolodaView)
        v.delegate = self
        v.datasource = self
        v.backgroundColor = UIColor.white
        return v
    }()
    
    lazy var alertController: UIAlertController = { [weak self] in
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        alertController.addAction(cancelAction)
        
        let aboutCourseAction = UIAlertAction(title: NSLocalizedString("AboutCourse", comment: ""), style: .default) { action in
            let vc = ControllerHelper.instantiateViewController(identifier: "AdaptiveCourseInfo", storyboardName: "AdaptiveMain") as! AdaptiveCourseViewController
            vc.course = self?.course
            
            self?.present(vc, animated: true)
        }
        alertController.addAction(aboutCourseAction)
        
        return alertController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage(named: "shadow-pixel")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isKolodaPresented {
            isKolodaPresented = true
            if !AuthInfo.shared.isAuthorized {
                registerAndLogIn()
            } else {
                self.joinAndLoadCourse(completion: {
                    self.initKoloda()
                })
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func getNewRecommendation(for course: Course, success: @escaping (Step) -> (Void)) {
        isRecommendationLoaded = false
        
        performRequest({
            // Get recommended lesson
            ApiDataDownloader.recommendations.getRecommendedLessonId(course: course.id, success: { recommendedLessonId in
                // Got nil as recommended lesson -> course passed
                guard let recommendedLessonId = recommendedLessonId else {
                    self.placeholderState = .coursePassed
                    return
                }
                
                ApiDataDownloader.lessons.retrieve(ids: [recommendedLessonId], existing: [], refreshMode: .update, success: { (newLessonsImmutable) -> Void in
                    let lesson = newLessonsImmutable.first
                    
                    if let lesson = lesson, let stepId = lesson.stepsArray.first {
                        self.recommendedLesson = lesson
                        
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
                            self.placeholderState = .connectionError
                        })
                    }
                }, error: { (error) -> Void in
                    print("failed downloading lessons data in Next")
                    self.placeholderState = .connectionError
                })
            }, error: { error in
                print(error)
                self.placeholderState = .connectionError
            })
        }, error: { error in
            print("failed performing API request -> force logout")
            self.logout()
        })
    }
    
    fileprivate func sendReactionAndGetNewLesson(reaction: Reaction, success: @escaping (Step) -> (Void)) {
        guard let course = course,
            let userId = AuthInfo.shared.userId,
            let lessonId = recommendedLesson?.id else {
                return
        }
        
        performRequest({
            ApiDataDownloader.recommendations.sendRecommendationReaction(user: userId, lesson: lessonId, reaction: reaction, success: {
                self.getNewRecommendation(for: course, success: { step in
                    success(step)
                })
            }, error: { error in
                print("failed sending reaction: \(error)")
                self.placeholderState = .connectionError
            })
        }, error: { error in
            print("failed performing API request -> force logout")
            self.logout()
        })
    }
    
    @IBAction func onUserMenuButtonClick(_ sender: Any) {
        alertController.popoverPresentationController?.barButtonItem = userMenuButton
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func joinAndLoadCourse(completion: @escaping () -> ()) {
        SVProgressHUD.show(withStatus: NSLocalizedString("LoadingCourse", comment: ""))
        performRequest({
            ApiDataDownloader.courses.retrieve(ids: [StepicApplicationsInfo.adaptiveCourseId], existing: [], refreshMode: .update, success: { (coursesImmutable) -> Void in
                self.course = coursesImmutable.first
                
                guard let course = self.course else {
                    print("course not found")
                    return
                }
                
                if !course.enrolled {
                    self.isJoinedCourse = true
                    
                    SVProgressHUD.show(withStatus: NSLocalizedString("JoiningCourse", comment: ""))
                    _ = AuthManager.sharedManager.joinCourseWithId(course.id, success: {
                        SVProgressHUD.dismiss()
                        self.course.enrolled = true
                        print("success joined course -> loading cards")
                        
                        completion()
                    }, error: {error in
                        SVProgressHUD.dismiss()
                        print("failed joining course: \(error) -> show placeholder")
                        self.placeholderState = .connectionError
                    })
                } else {
                    SVProgressHUD.dismiss()
                    print("already joined target course -> loading cards")
                    
                    self.isJoinedCourse = true
                    completion()
                }
            }, error: { (error) -> Void in
                SVProgressHUD.dismiss()
                print("failed downloading course data -> show placeholder")
                self.placeholderState = .connectionError
            })
        }, error: { error in
            SVProgressHUD.dismiss()
            print("failed performing API request -> force logout")
            self.logout()
        })
    }
    
    fileprivate func initKoloda() {
        if kolodaView.delegate == nil {
            kolodaView.dataSource = self
            kolodaView.delegate = self
        } else {
            kolodaView.reloadData()
        }
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
                // TODO: Maybe show placeholder?
                print("user registration failed")
                self.registerAdaptiveUser(success: success)
            })
        }, error: { error in
            // TODO: Maybe show placeholder?
            print("user registration failed: \(error)")
            self.registerAdaptiveUser(success: success)
        })
    }
    
    fileprivate func logIn(with email: String, password: String, success: @escaping ((Void) -> Void)) {
        performRequest({
            AuthManager.sharedManager.logInWithUsername(email, password: password, success: { token in
                AuthInfo.shared.token = token
                
                ApiDataDownloader.stepics.retrieveCurrentUser(success: { user in
                    AuthInfo.shared.user = user
                    User.removeAllExcept(user)
                    
                    success()
                }, error: { error in
                    print("successfully signed in, but could not get user")
                    // TODO: Maybe show placeholder?
                    self.logIn(with: email, password: password, success: success)
                })
            }, failure: { error in
                print("successfully registered, but login failed: \(error)")
                // TODO: Maybe show placeholder?
                self.logIn(with: email, password: password, success: success)
            })
        }, error: { error in
            // TODO: Maybe show placeholder?
            print("user log in failed: \(error)")
            self.logIn(with: email, password: password, success: success)
        })
    }
    
    fileprivate func launchOnboarding() {
        // Present tutorial after log in
        let isTutorialNeeded = !UserDefaults.standard.bool(forKey: "isTutorialShown")
        
        if isTutorialNeeded {
            let tutorialVC = ControllerHelper.instantiateViewController(identifier: "AdaptiveTutorial", storyboardName: "AdaptiveMain") as! AdaptiveTutorialViewController
            self.present(tutorialVC, animated: true, completion: nil)
            UserDefaults.standard.set(true, forKey: "isTutorialShown")
        }
        
        self.initKoloda()
    }
    
    fileprivate func registerAndLogIn() {
        let credentials = Sync.shared.restoreAccountCredentials()
        print("restored account from iCloud: email = \(credentials.email ?? ""), password = \(credentials.password ?? "")")
        
        if let restoredEmail = credentials.email, let restoredPassword = credentials.password {
            print("log in with restored account, email = \(restoredEmail)")
            logIn(with: restoredEmail, password: restoredPassword) {
                self.joinAndLoadCourse {
                    self.launchOnboarding()
                }
            }
        } else {
            registerAdaptiveUser { email, password in
                Sync.shared.saveAccountCredentials(email: email, password: password)
                self.logIn(with: email, password: password) {
                    self.joinAndLoadCourse {
                        self.launchOnboarding()
                    }
                }
            }
        }
    }
    
    func logout() {
        AuthInfo.shared.token = nil
        AuthInfo.shared.user = nil
        
        self.registerAndLogIn()
    }
    
    func swipeSolvedCard() {
        self.lastReaction = .solved
        
        isCurrentCardDone = true
        kolodaView.swipe(.up)
        isCurrentCardDone = false
    }
    
    enum PlaceholderState {
        case connectionError
        case coursePassed
    }
}

extension AdaptiveStepsViewController: KolodaViewDelegate {
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        if direction == .right {
            AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.Reaction.easy)
        } else if direction == .left {
            AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.Reaction.hard)
        }
        
        kolodaView.resetCurrentCardIndex()
    }
    
    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool {
        
        if direction == .right {
            self.lastReaction = .neverAgain
        } else if direction == .left {
            self.lastReaction = .maybeLater
        }
        
        return true
    }
    
    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return isCurrentCardDone ? [.up, .left, .right] : [.left, .right]
    }
    
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return true
    }
}

extension AdaptiveStepsViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return 2
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        if index > 0 {
            let card = Bundle.main.loadNibNamed("StepReversedCardView", owner: self, options: nil)?.first as? StepReversedCardView
            return card!
        } else {
            let card = Bundle.main.loadNibNamed("StepCardView", owner: self, options: nil)?.first as? StepCardView
            card?.hideContent()
            
            // Smooth appearance animation
            card?.alpha = 0.5
            UIView.animate(withDuration: 0.2, animations: {
                card?.alpha = 1.0
            }, completion: { _ in
                card?.loadingView.isHidden = false
            })
            
            DispatchQueue.global().async { [weak self] in
                guard let course = self?.course else {
                    return
                }
                
                let successHandler: (Step) -> (Void) = { step in
                    guard let lesson = self?.recommendedLesson else {
                        return
                    }
                    
                    self?.step = step
                    DispatchQueue.main.async {
                        card?.loadingView.isHidden = true
                        card?.step = step
                        card?.course = course
                        card?.lesson = lesson
                        card?.showContent()
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
            
            return card!
        }
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("CardOverlayView", owner: self, options: nil)?.first as? CardOverlayView
    }
}


extension AdaptiveStepsViewController: PlaceholderViewDataSource {
    func placeholderImage() -> UIImage? {
        guard let placeholderState = self.placeholderState else {
            return nil
        }
        
        switch placeholderState {
        case .connectionError:
            return Images.noWifiImage.size100x100
        case .coursePassed:
            return Images.placeholders.coursePassed
        }
    }
    
    func placeholderButtonTitle() -> String? {
        guard let placeholderState = self.placeholderState else {
            return nil
        }
        
        switch placeholderState {
        case .connectionError:
            return NSLocalizedString("TryAgain", comment: "")
        case .coursePassed:
            return NSLocalizedString("GoToStepikAppStore", comment: "")
        }
    }
    
    func placeholderDescription() -> String? {
        guard let placeholderState = self.placeholderState else {
            return nil
        }
        
        switch placeholderState {
        case .connectionError:
            return nil
        case .coursePassed:
            return NSLocalizedString("NoRecommendations", comment: "")
        }
    }
    
    func placeholderStyle() -> PlaceholderStyle {
        return stepicPlaceholderStyle
    }
    
    func placeholderTitle() -> String? {
        guard let placeholderState = self.placeholderState else {
            return nil
        }
        
        switch placeholderState {
        case .connectionError:
            return NSLocalizedString("ConnectionErrorText", comment: "")
        case .coursePassed:
            return NSLocalizedString("CoursePassed", comment: "")
        }
    }
}

extension AdaptiveStepsViewController: PlaceholderViewDelegate {
    func placeholderButtonDidPress() {
        guard let placeholderState = self.placeholderState else {
            return
        }
        
        switch placeholderState {
        case .connectionError:
            tryAgain()
        case .coursePassed:
            goToAppStore()
        }
    }
    
    fileprivate func goToAppStore() {
        // TODO: move url somewhere (maybe to plist?)
        if let url = URL(string: "itms-apps://itunes.apple.com/ru/developer/stepik/id1236410565"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    fileprivate func tryAgain() {
        lastReaction = nil
        placeholderState = nil
        
        // Two cases:
        // Course is nil -> invalid state, refresh
        // Course is initialized, but user is not joined -> load and join it again
        if course == nil || !isJoinedCourse {
            print("course or user enrollment has invalid state -> join and load course again")
            self.joinAndLoadCourse(completion: {
                self.initKoloda()
            })
            return
        }
        
        // Course is initialized, user is joined, just temporary troubles -> only reload koloda
        print("connection troubles -> trying again")
        initKoloda()
    }
}

