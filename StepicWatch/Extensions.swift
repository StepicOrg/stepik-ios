//
//  Extensions.swift
//  Stepic
//
//  Created by Anton Kondrashov on 11/03/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

@available(iOS 9.0, *)
extension WatchSessionSender.Name {
    static let RequestCourses = WatchSessionSender.Name("RequestCourses")
    static let Courses = WatchSessionSender.Name("Courses")
}

@available(iOS 9.0, *)
extension WatchSessionSender.Name {
    static let Metainfo = WatchSessionSender.Name("Metainfo")
    static func Metainfo(courseId: Int) -> WatchSessionSender.Name {
        return WatchSessionSender.Name(Metainfo.rawValue + "-\(courseId)")
    }
}
