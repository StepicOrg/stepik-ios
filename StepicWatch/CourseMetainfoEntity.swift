//
//  CourseMetainfoEntity.swift
//  Stepic
//
//  Created by Alexander Zimin on 19/12/2016.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

@available(iOS 9.0, *)
extension WatchSessionSender.Name {
  static let Metainfo = WatchSessionSender.Name("Metainfo")
  static func Metainfo(courseId: Int) -> WatchSessionSender.Name {
    return WatchSessionSender.Name(Metainfo.rawValue + "\(courseId)")
  }
}

struct CourseMetainfoContainer: DataConvertable {
  var courseId: Int
  var metainfo: [CourseMetainfoEntity]

  init(courseId: Int,  metainfo: [CourseMetainfoEntity] = []) {
    self.courseId = courseId
    self.metainfo = metainfo
  }

  init(dictionary: [String: AnyObject]) {
    self.courseId = dictionary["courseId"] as! Int
    self.metainfo = Array<CourseMetainfoEntity>.fromData(data: dictionary["metainfo"] as! Data)
  }

  func toDictionary() -> [String: AnyObject] {
    return ["courseId": courseId as AnyObject,
            "metainfo": metainfo.toData() as AnyObject]
  }
}

struct CourseMetainfoEntity: DataConvertable {
  var title: String
  var subtitle: String

  init(title: String, subtitle: String) {
    self.title = title
    self.subtitle = subtitle
  }

  init(dictionary: [String: AnyObject]) {
    self.title = dictionary["title"] as! String
    self.subtitle = dictionary["subtitle"] as! String
  }

  func toDictionary() -> [String: AnyObject] {
    return ["title": title as AnyObject,
            "subtitle": subtitle as AnyObject]
  }
}
