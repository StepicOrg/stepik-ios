//
//  CourseListViewDelegate.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol CourseListViewDelegate: class {
    func courseListViewDidPaginationRequesting(_ courseListView: CourseListView)
}
