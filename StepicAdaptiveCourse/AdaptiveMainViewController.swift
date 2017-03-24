//
//  AdaptiveMainViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class AdaptiveMainViewController: UIViewController {

    var course: Course?
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var startLearningButton: UIButton!
    
    @IBAction func onStartLearningButtonClick(_ sender: AnyObject) {
        performRequest({
            ApiDataDownloader.sharedDownloader.getLessonsByIds([37012], deleteLessons: [], refreshMode: .update, success: { (newLessonsImmutable) -> Void in
                let lesson = newLessonsImmutable.first
                
                if let lesson = lesson, let stepId = lesson.stepsArray.first {
                    performRequest({
                        ApiDataDownloader.sharedDownloader.getStepsByIds([stepId], deleteSteps: [], refreshMode: .update, success: { (newStepsImmutable) -> Void in
                            let step = newStepsImmutable.first
                            
                            if let step = step {
                                //let vc = ChoiceQuizViewController(nibName: "QuizViewController", bundle: nil)
                                //self.present(vc, animated: true, completion: nil)
                            }
                            }, failure: { (error) -> Void in
                                print("failed downloading steps data in Next")
                        })
                        }, error: {
                            print("failed performing API request")
                    })
                }
                }, failure: { (error) -> Void in
                    print("failed downloading lessons data in Next")
            })
            }, error: {
                print("failed performing API request")
        })
    }
    
    @IBAction func onLogoutButtonClick(_ sender: AnyObject) {
        AuthInfo.shared.token = nil
        UIThread.performUI {
            self.performSegue(withIdentifier: "openStartScreen", sender: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.courseInfoDidLoad), name: NSNotification.Name(rawValue: "courseInfoDidLoad"), object: nil)
        //ChoiceQuizViewController
        performRequest({
            ApiDataDownloader.sharedDownloader.getCoursesByIds([StepicApplicationsInfo.adaptiveCourseId], deleteCourses: Course.getAllCourses(), refreshMode: .update, success: { (coursesImmutable) -> Void in
                self.course = coursesImmutable.first
                
                guard let course = self.course else {
                    print("course not found")
                    return
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "courseInfoDidLoad"), object: nil)
                self.courseNameLabel.text = course.title
            }, failure: { (error) -> Void in
                print("failed downloading courses data in Next")
            })
            }, error: {
                print("failed performing API request")
        })
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func courseInfoDidLoad() {
        courseNameLabel.isHidden = false
        loadingIndicator.stopAnimating()
        startLearningButton.isEnabled = true
    }

}
