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
        guard let course = course else {
            return
        }
        
        let stepVC = UIStoryboard(name: "AdaptiveMain", bundle: nil).instantiateViewController(withIdentifier: "AdaptiveStepViewController") as! AdaptiveStepViewController
        stepVC.course = course
        self.present(stepVC, animated: true, completion: nil)
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
