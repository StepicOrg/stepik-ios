//
//  AdaptiveCourseViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD

class AdaptiveCourseViewController: UIViewController {

    var course: Course!
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var courseCoverImage: UIImageView!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var courseSummaryLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.courseNameLabel.text = course.title
        self.courseSummaryLabel.text = course.summary
        self.courseCoverImage.sd_setImage(with: URL(string: course.coverURLString))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadCourse()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onDismissButtonClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func updateCourseProgress(_ reset: Bool = false) {
        guard let course = self.course else {
            return
        }
        
        if reset || course.progress == nil {
            self.progressLabel.text = "- / -"
            self.progressBar.progress = 0.0
            return
        }
        
        if let p = course.progress {
            let percentage = p.numberOfSteps != 0 ? Double(p.numberOfStepsPassed) / Double(p.numberOfSteps) : 1
            self.progressLabel.text = "\(p.numberOfStepsPassed) / \(p.numberOfSteps)"
            self.progressBar.progress = Float(percentage)
        }
    }
    
    fileprivate func loadCourse() {
        performRequest({
            ApiDataDownloader.courses.retrieve(ids: [self.course.id], existing: [], refreshMode: .update, success: { (coursesImmutable) -> Void in
                self.course = coursesImmutable.first
                
                guard let course = self.course else {
                    print("course not found")
                    return
                }
                
                self.courseNameLabel.text = course.title
                self.courseSummaryLabel.text = course.summary
                self.courseCoverImage.sd_setImage(with: URL(string: course.coverURLString))

                self.loadCourseProgress()
            }, error: { (error) -> Void in
                print("failed downloading courses data in Next")
            })
        }, error: { error in
            print("failed performing API request -> dismiss and logout")
            self.dismiss(animated: false) {
                if let vc = self.parent as? AdaptiveStepsViewController {
                    vc.presenter?.logout()
                }
            }
        })
    }
    
    fileprivate func loadCourseProgress() {
        guard let course = self.course, let progressId = course.progressId else {
            self.updateCourseProgress(true)
            return
        }
        
        ApiDataDownloader.progresses.retrieve(ids: [progressId], existing: [], refreshMode: .update, success: { progresses in
            guard let progress = progresses.first else {
                return
            }
            
            course.progress = progress
            self.updateCourseProgress()
        }, error: { error in
            print("failed loading progress for course")
        })
    }
}

