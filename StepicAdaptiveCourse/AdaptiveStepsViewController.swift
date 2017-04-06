//
//  AdaptiveStepsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Koloda

class AdaptiveStepsViewController: UIViewController {
    
    @IBOutlet weak var kolodaView: KolodaView!

    fileprivate var isCurrentCardDone = false
    fileprivate var lastReaction: Reaction?

    var course: Course!
    var recommendedLesson: Lesson?
    var step: Step?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func getNewRecommendation(for course: Course, success: @escaping (Step) -> (Void)) {
        performRequest({
            ApiDataDownloader.recommendations.getRecommendedLessonId(course: course.id, success: { recommendedLessonId in
                ApiDataDownloader.sharedDownloader.getLessonsByIds([recommendedLessonId], deleteLessons: [], refreshMode: .update, success: { (newLessonsImmutable) -> Void in
                    let lesson = newLessonsImmutable.first
                    
                    if let lesson = lesson, let stepId = lesson.stepsArray.first {
                        self.recommendedLesson = lesson
                        ApiDataDownloader.sharedDownloader.getStepsByIds([stepId], deleteSteps: [], refreshMode: .update, success: { (newStepsImmutable) -> Void in
                            let step = newStepsImmutable.first
                            
                            if let step = step {
                                success(step)
                            }
                            }, failure: { (error) -> Void in
                                print("failed downloading steps data in Next")
                        })
                    }
                    }, failure: { (error) -> Void in
                        print("failed downloading lessons data in Next")
                })
                }, error: { error in print(error) })
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
            })
            }, error: {
                //TODO: add error handling here - add logout like in other controllers
                error in
                print("failed performing API request")
        })
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
        
        if direction == .left {
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
        
        guard let lesson = self.recommendedLesson, let step = self.step else {
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
        return 3
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let card = Bundle.main.loadNibNamed("StepCardView", owner: self, options: nil)?.first as? StepCardView
        if index > 0 {
            card?.hideContent()
        } else {
            card?.hideContent()
            card?.loadingView.isHidden = false
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
                        card?.updateContent(title: lesson.title, text: step.block.text, completion: {
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
        }
        return card!
    }
}
