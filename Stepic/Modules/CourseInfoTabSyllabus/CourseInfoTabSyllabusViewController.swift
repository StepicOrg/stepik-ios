//
//  CourseInfoTabSyllabusViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 14/11/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class CourseInfoTabSyllabusViewController: UIViewController {
    override func loadView() {
        self.view = CourseInfoTabSyllabusView(frame: UIScreen.main.bounds)
    }
}
