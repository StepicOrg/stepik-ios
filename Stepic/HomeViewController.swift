//
//  HomeViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 16.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "enrolledEmbed" {
            guard let dvc = segue.destination as? CourseListHorizontalViewController else {
                return
            }
            dvc.presenter = CourseListPresenter(view: dvc, limit: 6, listType: CourseListType.enrolled, colorMode: .dark, coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI(), reviewSummariesAPI: CourseReviewSummariesAPI())
        }
        if segue.identifier == "popularEmbed" {
            guard let dvc = segue.destination as? CourseListHorizontalViewController else {
                return
            }
            dvc.presenter = CourseListPresenter(view: dvc, limit: 6, listType: CourseListType.popular, colorMode: .light, coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI(), reviewSummariesAPI: CourseReviewSummariesAPI())
        }
    }

}
