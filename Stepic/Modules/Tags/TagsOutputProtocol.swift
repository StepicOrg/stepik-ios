//
//  TagsOutputProtocol.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol TagsOutputProtocol: class {
    func presentCourseList(type: TagCourseListType)
}
