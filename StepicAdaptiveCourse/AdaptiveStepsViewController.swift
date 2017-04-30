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

    fileprivate var isRecommendationLoaded = false
    fileprivate var isKolodaPresented = false
    fileprivate var isCurrentCardDone = false
    fileprivate var lastReaction: Reaction?
    public var isWarningHidden: Bool = true {
        didSet {
            self.warningView.isHidden = isWarningHidden
            self.kolodaView.isHidden = !isWarningHidden
        }
    }
    
    var course: Course!
    var recommendedLesson: Lesson?
    var step: Step?
    
    let warningViewTitle = NSLocalizedString("ConnectionErrorText", comment: "")

    lazy var warningView: UIView = {
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
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let aboutCourseAction = UIAlertAction(title: "О курсе", style: .default) { action in
            let vc = ControllerHelper.instantiateViewController(identifier: "AdaptiveCourseInfo", storyboardName: "AdaptiveMain") as! AdaptiveCourseViewController
            vc.course = self?.course
            
            self?.present(vc, animated: true)
        }
        alertController.addAction(aboutCourseAction)
        
        let destroyAction = UIAlertAction(title: "Выйти", style: .destructive) { action in
            AuthInfo.shared.token = nil
            AuthInfo.shared.user = nil
            
            self?.presentAuthViewController()
        }
        alertController.addAction(destroyAction)
        
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
                presentAuthViewController()
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
            ApiDataDownloader.recommendations.getRecommendedLessonId(course: course.id, success: { recommendedLessonId in
                ApiDataDownloader.lessons.retrieve(ids: [recommendedLessonId], existing: [], refreshMode: .update, success: { (newLessonsImmutable) -> Void in
                    let lesson = newLessonsImmutable.first
                    
                    if let lesson = lesson, let stepId = lesson.stepsArray.first {
                        self.recommendedLesson = lesson
                        ApiDataDownloader.steps.retrieve(ids: [stepId], existing: [], refreshMode: .update, success: { (newStepsImmutable) -> Void in
                            let step = newStepsImmutable.first
                            
                            if let step = step {
                                guard let progressId = step.progressId else {
                                    print("invalid progress id")
                                    return
                                }
                                
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
                                self.isWarningHidden = false
                        })
                    }
                    }, error: { (error) -> Void in
                        print("failed downloading lessons data in Next")
                        self.isWarningHidden = false
                })
                }, error: { error in
                    print(error)
                    self.isWarningHidden = false
                })
            }, error: {
                //TODO: add error handling here - add logout like in other controllers
                error in
                print("failed performing API request")
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
                    self.isWarningHidden = false
            })
            }, error: {
                //TODO: add error handling here - add logout like in other controllers
                error in
                print("failed performing API request")
        })
    }
    
    @IBAction func onUserMenuButtonClick(_ sender: Any) {
        alertController.popoverPresentationController?.barButtonItem = userMenuButton
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func joinAndLoadCourse(completion: @escaping () -> ()) {
        SVProgressHUD.show(withStatus: "Загружаем курс...")
        performRequest({
            ApiDataDownloader.courses.retrieve(ids: [StepicApplicationsInfo.adaptiveCourseId], existing: [], refreshMode: .update, success: { (coursesImmutable) -> Void in
                self.course = coursesImmutable.first
                
                guard let course = self.course else {
                    print("course not found")
                    return
                }
                
                if !course.enrolled {
                    SVProgressHUD.show(withStatus: "Записываемся на курс...")
                    _ = AuthManager.sharedManager.joinCourseWithId(course.id, success: {
                        SVProgressHUD.dismiss()
                        self.course.enrolled = true
                        print("success joined course -> loading cards")
                        
                        completion()
                    }, error: {error in
                        SVProgressHUD.dismiss()
                        print("failed joining course: \(error)")
                    })
                } else {
                    SVProgressHUD.dismiss()
                    print("already joined target course -> loading cards")
                    
                    completion()
                }
            }, error: { (error) -> Void in
                SVProgressHUD.dismiss()
                
                print("failed downloading course data")
            })
        }, error: { error in
            SVProgressHUD.dismiss()
            
            print("failed performing API request")
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
    
    fileprivate func presentAuthViewController() {
        let vc = ControllerHelper.getAuthController() as! AuthNavigationViewController
        vc.canDismiss = false
        vc.success = { [weak self] in
            self?.joinAndLoadCourse(completion: {
                // Present tutorial after log in
                let isTutorialNeeded = !UserDefaults.standard.bool(forKey: "isTutorialShown")
                
                if isTutorialNeeded {
                    let tutorialVC = ControllerHelper.instantiateViewController(identifier: "AdaptiveTutorial", storyboardName: "AdaptiveMain") as! AdaptiveTutorialViewController
                    self?.present(tutorialVC, animated: true, completion: nil)
                    UserDefaults.standard.set(true, forKey: "isTutorialShown")
                }
                
                self?.initKoloda()
            })
        }
        self.present(vc, animated: false, completion: nil)
    }
}

extension AdaptiveStepsViewController: KolodaViewDelegate {
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
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
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        guard let card = koloda.viewForCard(at: index) as? StepCardView else {
            return
        }

        guard isRecommendationLoaded, let lesson = self.recommendedLesson, let step = self.step else {
            print("recommendation not loaded yet")
            return
        }
        
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "AdaptiveStepViewController") as? AdaptiveStepViewController {
            vc.dismissHandler = { [weak card] in
                guard let card = card else {
                    return
                }
                
                card.showContent()
                UIView.animate(withDuration: 0.3, animations: {
                    card.transform = CGAffineTransform.identity
                })
            }
            vc.successHandler = { [weak card, weak koloda] in
                guard let card = card, let koloda = koloda else {
                    return
                }
                
                self.lastReaction = .solved
                
                card.showContent()
                UIView.animate(withDuration: 0.3, animations: {
                    card.transform = CGAffineTransform.identity
                }, completion: { _ in
                    self.isCurrentCardDone = true
                    koloda.swipe(.up)
                    self.isCurrentCardDone = false
                })
            }
            vc.recommendedLesson = lesson
            vc.step = step
            vc.course = self.course
            
            card.hideContent()
            UIView.animate(withDuration: 0.3, animations: {
                card.transform = CGAffineTransform.init(scaleX: 2, y: 2)
            }, completion: { completed in
                self.present(vc, animated: false, completion: nil)
            })
        }
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
            card?.addPattern()
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
                        card?.updateContent(title: lesson.title, text: step.block.text, step: step, completion: {
                            card?.loadingView.isHidden = true
                            card?.showContent()
                        })
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
        return Images.noWifiImage.size100x100
    }
    
    func placeholderButtonTitle() -> String? {
        return NSLocalizedString("TryAgain", comment: "")
    }
    
    func placeholderDescription() -> String? {
        return nil
    }
    
    func placeholderStyle() -> PlaceholderStyle {
        return stepicPlaceholderStyle
    }
    
    func placeholderTitle() -> String? {
        return warningViewTitle
    }
}

extension AdaptiveStepsViewController: PlaceholderViewDelegate {
    func placeholderButtonDidPress() {
        print("trying again after connection troubles...")
        lastReaction = nil
        isWarningHidden = true
        initKoloda()
    }
}

