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
            let dvc = segue.destination as? CourseListHorizontalViewController
            dvc?.listType = CourseListType.enrolled
            dvc?.limit = 6
        }
        if segue.identifier == "popularEmbed" {
            let dvc = segue.destination as? CourseListHorizontalViewController
            dvc?.listType = CourseListType.popular
            dvc?.limit = 6
        }
    }

}
