//
//  CourseListCollectionOutputProtocol.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol CourseListCollectionOutputProtocol: class {
    func presentCourseList(
        presentationDescription: CourseList.PresentationDescription,
        type: CollectionCourseListType
    )
}
