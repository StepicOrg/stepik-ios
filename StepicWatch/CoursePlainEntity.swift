//
//  CourseEntity.swift
//  StepticWatches
//
//  Created by Alexander Zimin on 17/12/2016.
//  Copyright © 2016 Alexander Zimin. All rights reserved.
//

import Foundation
import CoreGraphics

@available(iOS 9.0, *)
extension WatchSessionSender.Name {
  static let RequestCourses = WatchSessionSender.Name("RequestCourses")
  static let Courses = WatchSessionSender.Name("Courses")
}

struct CoursePlainEntity: DataConvertable {
  var id: Int
  var name: String
  var metainfo: String
  var imageURL: String
  var deadline: TimeInterval

  var hasDeadline: Bool {
    return deadline != 0
  }

  var deadlineDate: Date? {
    if !hasDeadline {
      return nil
    }
    return Date(timeIntervalSince1970: deadline)
  }

  init(id: Int, name: String, metainfo: String, imageURL: String, deadlineDate: Date?) {
    self.id = id
    self.name = name
    self.metainfo = metainfo
    self.imageURL = imageURL
    self.deadline = deadlineDate?.timeIntervalSince1970 ?? 0
  }

  init(dictionary: [String: AnyObject]) {
    self.id = dictionary["id"] as! Int
    self.name = dictionary["name"] as! String
    self.metainfo = dictionary["metainfo"] as! String
    self.imageURL = dictionary["imageURL"] as! String
    self.deadline = dictionary["dealine"] as! TimeInterval
  }

  func toDictionary() -> [String: AnyObject] {
    return ["id": id as AnyObject,
            "name": name as AnyObject,
            "metainfo": metainfo as AnyObject,
            "imageURL": imageURL as AnyObject,
            "dealine": deadline as AnyObject]
  }
}
