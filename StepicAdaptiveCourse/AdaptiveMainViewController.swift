//
//  AdaptiveMainViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import SVProgressHUD

class AdaptiveMainViewController: UIViewController {

    var course: Course?
    
    var isLoggedIn: Bool = false {
        didSet {
            if isLoggedIn {
                toggleUserMenuButton(true)
                startLearningButton.setTitle("Записаться на курс", for: .normal)
            } else {
                toggleUserMenuButton(false)
                updateCourseProgress(true)
                startLearningButton.setTitle("Войти", for: .normal)
            }
        }
    }
    
    var isEnrolledIn: Bool = false {
        didSet {
            if isEnrolledIn {
                startLearningButton.setTitle("Учиться", for: .normal)
            } else {
                if isLoggedIn {
                    startLearningButton.setTitle("Записаться на курс", for: .normal)
                }
            }
        }
    }
    
    @IBOutlet weak var userMenuButton: UIBarButtonItem!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var courseCoverImage: UIImageView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var courseSummaryLabel: UILabel!
    @IBOutlet weak var aboutCourseButton: UIButton!
    @IBOutlet weak var startLearningButton: UIButton!
    
    lazy var alertController: UIAlertController = { [weak self] in
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Выйти", style: .destructive) { action in
            AuthInfo.shared.token = nil
            AuthInfo.shared.user = nil
            
            self?.isLoggedIn = false
        }
        alertController.addAction(destroyAction)
        
        return alertController
    }()
    
    
    @IBAction func onUserMenuButtonClick(_ sender: Any) {
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onAboutCourseButtonClick(_ sender: Any) {
        let courseVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CoursePreviewViewController") as! CoursePreviewViewController
        courseVC.course = course
        courseVC.automaticallyAdjustsScrollViewInsets = false
        
        self.navigationController?.pushViewController(courseVC, animated: true)
    }
    
    @IBAction func onStartLearningButtonClick(_ sender: AnyObject) {
        if !isLoggedIn {
            presentAuthViewController()
            return
        }
        
        guard let course = self.course else {
            return
        }
        
        if !isEnrolledIn {
            SVProgressHUD.show()
            startLearningButton.isEnabled = false
            
            _ = AuthManager.sharedManager.joinCourseWithId(course.id, success: {
                SVProgressHUD.showSuccess(withStatus: "")
                self.startLearningButton.isEnabled = true
                
                self.isEnrolledIn = true
                self.loadCourse()
            }, error: {error in
                print("failed joining course: \(error)")
            })
            
            return
        }
        
        
        let stepVC = UIStoryboard(name: "AdaptiveMain", bundle: nil).instantiateViewController(withIdentifier: "AdaptiveStepsViewController") as! AdaptiveStepsViewController
        stepVC.course = course
        self.present(stepVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage(named: "shadow-pixel")
        
        // TODO: fix it
        AuthInfo.shared.user = nil
        
        if !AuthInfo.shared.isAuthorized {
            presentAuthViewController()
        } else {
            isLoggedIn = true
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadCourse()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func showCourseInfo() {
        self.loadingIndicator.stopAnimating()
        [self.courseNameLabel, self.courseSummaryLabel, self.courseCoverImage, self.aboutCourseButton].forEach { $0.isHidden = false }
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
    
    fileprivate func presentAuthViewController() {
        let vc = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "AuthNavigation") as! AuthNavigationViewController
        vc.success = { [weak self] in
            self?.isLoggedIn = true
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    fileprivate func loadCourse() {
        performRequest({
            ApiDataDownloader.courses.retrieve(ids: [StepicApplicationsInfo.adaptiveCourseId], existing: [], refreshMode: .update, success: { (coursesImmutable) -> Void in
                self.course = coursesImmutable.first
                
                guard let course = self.course else {
                    print("course not found")
                    return
                }
                
                self.courseNameLabel.text = course.title
                self.courseSummaryLabel.text = course.summary
                self.courseCoverImage.sd_setImage(with: URL(string: course.coverURLString))
                self.isEnrolledIn = course.enrolled
                
                self.showCourseInfo()
                
                self.loadCourseProgress()
            }, error: { (error) -> Void in
                print("failed downloading courses data in Next")
            })
        }, error: { error in
            print("failed performing API request")
        })
    }
    
    fileprivate func loadCourseProgress() {
        guard let course = self.course, let progressId = course.progressId else {
            self.updateCourseProgress(true)
            return
        }
        
        performRequest({
            ApiDataDownloader.progresses.retrieve(ids: [progressId], existing: [], refreshMode: .update, success: { progresses in
                guard let progress = progresses.first else {
                    return
                }
                
                course.progress = progress
                self.updateCourseProgress()
            }, error: { error in
                print("failed loading progress for course")
            })
        }, error: { error in
            print("failed performing API request")
        })
    }
    
    fileprivate func toggleUserMenuButton(_ on: Bool) {
        if on {
            userMenuButton.isEnabled = true
            userMenuButton.tintColor = UIColor.stepicGreenColor()
        } else {
            userMenuButton.isEnabled = false
            userMenuButton.tintColor = UIColor.clear
        }
    }

}
