//
//  AdaptiveStepViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AdaptiveStepViewController: UIViewController {

    var course: Course?
    var recommendedLesson: Lesson?
    
    var quizVC: ChoiceQuizViewController?
    
    @IBOutlet weak var stepWebView: UIWebView!
    @IBOutlet weak var quizPlaceholderView: UIView!
    
    @IBOutlet weak var easyReactionButton: UIButton!
    @IBOutlet weak var hardReactionButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var quizPlaceholderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stepWebViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dimView: UIView!
    
    @IBAction func onEasyButtonClick(_ sender: AnyObject) {
        sendReactionAndGetNewLesson(reaction: .neverAgain)
    }
    
    @IBAction func onNextButtonClick(_ sender: AnyObject) {
        sendReactionAndGetNewLesson(reaction: .solved)
    }
    
    @IBAction func onHardButtonClick(_ sender: AnyObject) {
        sendReactionAndGetNewLesson(reaction: .maybeLater)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let course = course else {
            return
        }

        getNewRecommendation(for: course, success: { step in
            self.dimView.isHidden = true
            
            self.loadQuiz(for: step)
            self.loadStepHTML(for: step)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func loadStepHTML(for step: Step) {
        if let htmlText = step.block.text {
            let scriptsString = "\(Scripts.localTexScript)"
            var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: htmlText, width: Int(UIScreen.main.bounds.width))
            html = html.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            print("\(Bundle.main.bundlePath)")
            stepWebView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        }
    }
    
    fileprivate func loadQuiz(for step: Step) {
        if let quizVC = self.quizVC {
            quizVC.view.removeFromSuperview()
            quizVC.removeFromParentViewController()
        }
        
        self.quizVC = ChoiceQuizViewController(nibName: "QuizViewController", bundle: nil)
        
        guard let quizVC = self.quizVC else {
            print("quizVC init failed")
            return
        }
        quizVC.step = step
        quizVC.delegate = self
        
        self.addChildViewController(quizVC)
        self.quizPlaceholderView.addSubview(quizVC.view)
        quizVC.view.align(to: self.quizPlaceholderView)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    fileprivate func sendReactionAndGetNewLesson(reaction: Reaction) {
        guard let course = course,
            let userId = AuthInfo.shared.userId,
            let lessonId = recommendedLesson?.id else {
                return
        }
        
        dimView.isHidden = false
        performRequest({
            ApiDataDownloader.recommendations.sendRecommendationReaction(user: userId, lesson: lessonId, reaction: reaction, success: {
                self.getNewRecommendation(for: course, success: { step in
                    self.dimView.isHidden = true
                    
                    self.loadQuiz(for: step)
                    self.loadStepHTML(for: step)
                })
                }, error: { error in
                    print("failed sending reaction: \(error)")
                    self.dimView.isHidden = true
            })
            }, error: {
                //TODO: add error handling here - add logout like in other controllers
                error in
                print("failed performing API request")
        })
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
}

extension AdaptiveStepViewController: UIWebViewDelegate {
    func resetWebViewHeight(_ height: Float) {
        stepWebViewHeight.constant = CGFloat(height)
    }
    
    func getContentHeight(_ webView : UIWebView) -> Int {
        let height = Int(webView.stringByEvaluatingJavaScript(from: "document.body.scrollHeight;") ?? "0") ?? 0
        return height
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        resetWebViewHeight(Float(getContentHeight(webView)))
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        resetWebViewHeight(Float(getContentHeight(stepWebView)))
    }
}

extension AdaptiveStepViewController: QuizControllerDelegate {
    func needsHeightUpdate(_ newHeight: CGFloat, animated: Bool, breaksSynchronizationControl: Bool) {
        DispatchQueue.main.async {
            [weak self] in
            self?.quizPlaceholderViewHeight.constant = newHeight
            if animated {
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.view.layoutIfNeeded()
                }, completion: nil)
            } else {
                self?.view.layoutIfNeeded()
            }
            
        }
        
    }
}
