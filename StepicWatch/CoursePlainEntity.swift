//
//  CourseEntity.swift
//  StepticWatches
//
//  Created by Alexander Zimin on 17/12/2016.
//  Copyright © 2016 Alexander Zimin. All rights reserved.
//

import Foundation
import CoreGraphics

#if !os(tvOS)
    @available(iOS 9.0, *)
    extension WatchSessionSender.Name {
        static let RequestCourses = WatchSessionSender.Name("RequestCourses")
        static let Courses = WatchSessionSender.Name("Courses")
    }
#endif

struct CoursePlainEntity: DataConvertable {
  var id: Int
  var name: String
  var metainfo: String
  var imageURL: String
  var firstDeadline: TimeInterval
  var secondDeadline: TimeInterval

  var firstDeadlineDate: Date {
    return Date(timeIntervalSince1970: firstDeadline)
  }

  var secondDeadlineDate: Date {
    return Date(timeIntervalSince1970: secondDeadline)
  }

  var deadlineDates: [Date] {
    var result: [Date] = []

    if firstDeadline > 0 || secondDeadline > 0 {
      if Date().compare(firstDeadlineDate) == ComparisonResult.orderedAscending {
        result.append(firstDeadlineDate)
      }

      if Date().compare(secondDeadlineDate) == ComparisonResult.orderedAscending {
        result.append(secondDeadlineDate)
      }
    }

    return result
  }

  init(id: Int, name: String, metainfo: String, imageURL: String, firstDeadlineDate: Date?, secondDeadlineDate: Date?) {
    self.id = id
    self.name = name
    self.metainfo = metainfo
    self.imageURL = imageURL
    self.firstDeadline = firstDeadlineDate?.timeIntervalSince1970 ?? 0
    self.secondDeadline = secondDeadlineDate?.timeIntervalSince1970 ?? 0
  }

  init(dictionary: [String: AnyObject]) {
    self.id = dictionary["id"] as! Int
    self.name = dictionary["name"] as! String
    self.metainfo = dictionary["metainfo"] as! String
    self.imageURL = dictionary["imageURL"] as! String
    self.firstDeadline = dictionary["firstDeadline"] as! TimeInterval
    self.secondDeadline = dictionary["secondDeadline"] as! TimeInterval
  }

  func toDictionary() -> [String: AnyObject] {
    return ["id": id as AnyObject,
            "name": name as AnyObject,
            "metainfo": metainfo as AnyObject,
            "imageURL": imageURL as AnyObject,
            "firstDeadline": firstDeadline as AnyObject,
            "secondDeadline": secondDeadline as AnyObject]
  }
}
