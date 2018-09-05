//
//  CourseListsCollectionViewModelAdapter.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 04.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension CourseListsCollectionViewModel {
    init(courseList: CourseListModel) {
        self.title = courseList.title
        self.summary = courseList.description
        self.courseList = CollectionCourseListType(ids: courseList.coursesArray)
    }
}
