//
//  FindCoursesViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit

class FindCoursesViewController: CoursesViewController {

//    let TAB_NUMBER = 1
    
    override func viewDidLoad() {
        loadEnrolled = nil
        loadFeatured = true
        super.viewDidLoad()
    }
}